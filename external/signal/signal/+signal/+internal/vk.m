function [xrec,xAmp,pcgstruct] = vk(x,fs,F,r,fOrder,winLen,tol,maxit)
% Vold-Kalman filter
% x - input signal (NX1)
% fs - sampling frequency (scalar)
% F - frequency matrix, one row for each order (NXK)
% r - scaling factor (KX1). Larger values give more weight to the structural
%   equation, which means a smoother output.
% fOrder - filter order (1 or 2).
% winLen - segment length (if equal to length of x, uses only one segment)

%   Copyright 2016-2020 The MathWorks, Inc.
%#codegen

if nargin < 7 || isempty(tol)
    tol = 1e-3;
end
if nargin < 8 || isempty(maxit)
      maxit = 5e4;  % Default Maximum number of iterations for pcg
end

if ~coder.target('MATLAB')
    assert(nargout <= 2); % output pcgstruct is not supported in codegen  
    [xrec,xAmp] = signal.internal.codegenable.vk.vk(x,fs,F,r,fOrder,winLen,tol,maxit);
else
    x = x(:);
    xlen = length(x);
    sizeF = size(F);
    numOrd = sizeF(2);
 
    
    pcgstruct = {};
    % Break x into segment if winLen is less than xlen
    if ~(xlen == winLen)
        % Check to make sure window is not too long for x. Since hop is size
        % (winLen+1)/2, length for two overlaps is winLen + (winLen+1)/2
        if winLen + (winLen+1)/2 > xlen
            % Solve for winLen that produces xlen with formula above. We will make
            % sure that winLen is odd next.
            winLen = floor(2/3*(xlen-1/2));
        end
        
        % Make sure winLen is odd
        if ~mod(winLen,2)
            winLen = winLen - 1;
        end
        
        nhop = (winLen+1)/2;
        noverlap = winLen - nhop;
        
        % Allocate solution matrices
        xrec = zeros(sizeF,class(x));
        xAmp = zeros(sizeF,class(x));
        
        % Break in the input into segments and store in xin. To use the entire
        % input signal, the last segment (xlast) may be longer than the rest.
        [xin,xlast,colidx] = getSegments(x,xlen,winLen,noverlap);
        [nrows,ncols] = size(xin);
        nrowsLast = length(xlast);
        
        % Solve for each order waveform separately
        F_in = zeros(numOrd,size(xin,1),size(xin,2));
        F_inlast = zeros(numOrd,length(xlast));
        
        % Define windows
        winIn = hanning(winLen);
        winStart = winIn;
        winStart(1:(winLen+1)/2) = 1;
        winEnd = ones(nrowsLast,1);
        winEnd(1:(winLen+1)/2) = winIn(1:(winLen+1)/2);
        
        for j = 1:numOrd
            % Break the input frequency vector into segments corresponding to xin
            [F_in(j,:,:),F_inlast(j,:)] = getSegments(F(:,j),xlen,winLen,noverlap);
        end
        
        for i = 1:ncols
            % If this is the first or the last segment, use the modified hanning
            % window. Otherwise, use a hanning window.
            if i == 1
                win = winStart;
            else
                win = winIn;
            end
            % Use vk to solve for the waveform for this segment
            inds = colidx(i):colidx(i)+nrows-1;
            [x0,xMagPhase0,pcgstruct{end+1}] = ...
                computevk(xin(:,i),fs,squeeze(F_in(:,:,i))',r,fOrder,tol,maxit);
            
            % Add this segment to the reconstructed signal
            xrec(inds,:) = xrec(inds,:) + x0.*win;
            xAmp(inds,:) = xAmp(inds,:) + abs(xMagPhase0).*win;
        end
        
        % This is the last segment, which extends to the end of the
        % input. It is stored in a separate vector and has a different
        % size than the rest of the segments. Repeat the operations from
        % above, using the correct size.
        win = winEnd;
        [x0,xMagPhase0,pcgstruct{end+1}] = ...
            computevk(xlast,fs,F_inlast',r,fOrder,tol,maxit);
        xrec(colidx(end):end,:) = xrec(colidx(end):end,:) + x0.*win;
        xAmp(colidx(end):end,:) = xAmp(colidx(end):end,:) + abs(xMagPhase0).*win;
    else
        if length(x)>5e4
            warning(message('signal:rpmmap:WarnVKLongInput'));
        end
        [xrec,xMagPhase,pcgstruct] = computevk(x,fs,F,r,fOrder,tol,maxit);
        xAmp = abs(xMagPhase);
    end
end

%--------------------------------------------------------------------------
function [xrec,xMagPhase,pcgstruct] = computevk(x,Fs,F,r,fOrder,tol,maxit)
% x - input signal (NX1)
% Fs - sampling frequency (scalar)
% F - frequency matrix, one row for each order (NXK)
% r - scaling factor (KX1). Larger values give more weight to the structural
%   equation, which means a smoother output.
% fOrder - filter order (1 or 2).

x = x(:);
N = length(x);
K = size(F,2);

% Form structural equation matrix (depends on filter order)
if fOrder == 1
    numRows = N-2;
    S = spdiags([1 -2 1].*ones(N,1),...
        [0 1 2],numRows,N);
elseif fOrder == 2
    numRows = N-3;
    S = spdiags([1 -3 3 -1].*ones(N,1),...
        [0 1 2 3],numRows,N);
end

% Form a data equation matrix
C = exp(1i*2*pi*cumsum(F,1)/Fs);

% Form Least-squares system (K*N by K*N)
B0 = (S')*S;
clear S;
iB = find(B0);
A = spalloc(K*N,K*N,K*length(iB)+2*N*factorial(K-1));
b = zeros(K*N,1);

for i = 1:K
    irow = (1:N)+ N*(i-1);
    
    % Block diagonal components
    A(irow,irow) = r(i)^2*B0+ speye(N); %#ok<*SPRIX>
    
    % Off-diagonal components
    for j = i+1:K
        jrow = (1:N)+ N*(j-1);
        A(jrow,irow) = spdiags(conj(C(:,j)).*C(:,i),0,N,N);
        A(irow,jrow) = spdiags(conj(C(:,i)).*C(:,j),0,N,N);
    end
    
    % RHS
    b(irow) = conj(C(:,i)).*x;
end

clear B0;

% Create function handle for pre-conditioner
hIM = @(x) cumsum(cumsum(x),'reverse');

if fOrder == 1
    hM = @(x) hIM(hIM(x));
elseif fOrder == 2
    hM = @(x) hIM(hIM(hIM(x)));
end

% Solve system using pre-conditioned conjugate gradient method
% Use amplitude a sinusoid with same std as a guess
% Specify solution parameters and initial guess
x0 = double(std(x)/sqrt(2)*ones(K*N,1));
[X,pcgstruct.flag,pcgstruct.relres,pcgstruct.iter,pcgstruct.resvec] = pcg(A,b,tol,maxit,hM,[],x0);
if pcgstruct.flag
    warning(message('signal:rpmmap:VKPCGFlag',pcgstruct.flag));
end

% Construct time-domain waveforms
xMagPhase = 2*reshape(X,N,K);
xrec = real(xMagPhase.*C);
if isa(x,'single')
    xMagPhase = single(xMagPhase);
    xrec = single(xrec);
end

%--------------------------------------------------------------------------
function [xin,xlast,colindex] = getSegments(x,nx,nwin,noverlap)
% Determine the number of columns of the STFT output (i.e., the S output)
ncol = fix((nx-noverlap)/(nwin-noverlap));

colindex = 1 + (0:(ncol-1))*(nwin-noverlap);
rowindex = (1:nwin)';

% 'xin' should be of the same datatype as 'x'
xin = zeros(nwin,ncol-1,class(x)); %#ok<*ZEROLIKE>

% Put x into columns of xin with the proper offset
xin(:) = x(rowindex(:,ones(1,ncol-1))+colindex(ones(nwin,1),1:end-1)-1);

% Store the last segment in xlast to ensure all samples are used
xlast = x(colindex(end):end);

% LocalWords:  Vold NX fs NXK xlen xin xlast rpmmap VKPCG STFT
