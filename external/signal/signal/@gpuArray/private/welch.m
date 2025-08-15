function varargout = welch(x,esttype,varargin)
%WELCH Welch spectral estimation method on the GPU.
%   [Pxx,F] = WELCH(X,WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE,TRACE,ESTTYPE)
%   [Pxx,F] = WELCH({X},WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE,TRACE,'psd')
%   [Pxx,F] = WELCH({X},WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE,TRACE,'ms')
%   [Pxy,F] = WELCH({X,Y},WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE,'cpsd')
%   [Txy,F] = WELCH({X,Y},WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE,'tfe')
%   [Txy,F] = WELCH({X,Y},WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE,'tfeh2')
%   [Cxy,F] = WELCH({X,Y},WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE,'mscohere')
%   [...,F] = WELCH({X,Y},WINDOW,NOVERLAP,NFFT,Fs,...'mimo')
%   [Pxx,F,Pxxc] = WELCH(...)
%   [Pxx,F,Pxxc] = WELCH(...,'ConfidenceLevel',P)
%
%   Inputs:
%      see "help pwelch" for complete description of all input arguments.
%      ESTTYPE - is a string specifying the type of estimate to return, the
%                choices are: psd, cpsd, tfe, tfeh2, and mscohere.
%
%   Outputs:
%      Depends on the input string ESTTYPE:
%      Pxx - Power Spectral Density (PSD) estimate, or
%      MS  - Mean-square spectrum, or
%      Pxy - Cross Power Spectral Density (CPSD) estimate, or
%      Txy - Transfer Function Estimate (TFE), or
%      Cxy - Magnitude Squared Coherence.
%      F   - frequency vector, in Hz if Fs is specified, otherwise it has
%            units of rad/sample
%
%   See also WELCH, GPUARRAY, GPUARRAY/PWELCH.

%   Copyright 2019-2020 The MathWorks, Inc.

narginchk(2,11);
nargoutchk(0,3);

% Parse input arguments.
[x,~,~,y,~,win,winName,winParam,noverlap,k1,L,options] = ...
    signal.internal.spectral.welchparse(x,esttype,varargin{:});
% Make sure that the default window argument is sent to the GPU
win = gpuArray(win);
% Cast to enforce precision rules
options.nfft = signal.internal.sigcasttofloat(options.nfft,'double',...
    'WELCH','NFFT','allownumeric');
noverlap = signal.internal.sigcasttofloat(noverlap,'double','WELCH',...
    'NOVERLAP','allownumeric');
options.Fs = signal.internal.sigcasttofloat(options.Fs,'double','WELCH',...
    'Fs','allownumeric');
k = double(k1);

% In-memory welch uses signal.internal.sigcheckfloattype but it
% relies on isa(x, datatype). Performing input validation here.
coder.internal.errorIf(~isfloat(x), 'signal:sigcheckfloattype:InvalidInput3',...
    'double/single', underlyingType(x));
if ~isempty(y)
    % Two input signals.
    coder.internal.errorIf(~isfloat(y), 'signal:sigcheckfloattype:InvalidInput3',...
        'double/single', underlyingType(y));
end

% Cast to enforce precision rules. Both x and window are gpuArray, y can be
% empty (one input signal) or a gpuArray (two input signals).
isXSingle = isUnderlyingType(x,'single');
isYSingle = ~isempty(y) && isUnderlyingType(y,'single');
isWinSingle = isUnderlyingType(win,'single');
if isXSingle || isYSingle || isWinSingle
    x = single(x);
    y = single(y);
    win = single(win);
end

% Frequency vector was specified, return and plot two-sided PSD
freqVectorSpecified = false;
nrow = 1;
if length(options.nfft) > 1
    freqVectorSpecified = true;
    [~,nrow] = size(options.nfft);
end
% Record if input x is a vector for backwards compatibility
isVectorX = isvector(x);

% Compute the periodogram power spectrum of each segment and average always
% compute the whole power spectrum, we force Fs = 1 to get a PS not a PSD

% Initialize
if freqVectorSpecified
    nFreqs = length(options.nfft);
    if strcmpi(options.range,'onesided')
        coder.internal.warning('signal:welch:InconsistentRangeOption');
    end
    options.range = 'twosided';
else
    nFreqs = options.nfft(1);
end
% Cast to enforce precision rules
xProto = subsref(x, substruct('()', {[]}));

% First check x and y must be vectors and matrices
validateattributes(x,{'numeric'},{'2d'},'X');
nChX = size(x,2);
if ~isempty(y)
    validateattributes(y,{'numeric'},{'2d'},'Y');
    nChY = size(y,2);
end

method = "plus";
cmethod = @plus;

switch esttype
    case {'ms','power','psd'}
        % Place x into columns according to the window size and overlap
        x = parallel.internal.gpu.extractWindows(x,length(win),noverlap);
        % Combining method
        if options.maxhold
            method = "max";
            isAvgMethod = false;
            [Pxx,w,units] = localComputeSpectraGPU(x,[],win,...
                options,esttype,k,isAvgMethod,freqVectorSpecified);
        elseif options.minhold
            method = "min";
            isAvgMethod = false;
            [Pxx,w,units] = localComputeSpectraGPU(x,[],win,...
                options,esttype,k,isAvgMethod,freqVectorSpecified);
        else
            isAvgMethod = true;
            [Pxx,w,units] = localComputeSpectraGPU(x,[],win,...
                options,esttype,k,isAvgMethod,freqVectorSpecified);
        end
        
    case 'cpsd'
        % Maximum number of samples in the subset of channels of each input
        % to process at a time. If a single channel has more samples, it
        % will be processed at once, it's not further divided into smaller
        % segments.
        maxNumSamples = 2e6;
        numChannelsInSubsetX = max(1,floor(maxNumSamples/size(x,1)));
        numChannelsInSubsetY = max(1,floor(maxNumSamples/size(y,1)));
        numChannelsInSubset = min(numChannelsInSubsetX, numChannelsInSubsetY);
        
        [numChannels, chindx, chindy] = localChannelIdx(x,y,options.MIMO);
        
        numSubsets = ceil(numChannels/numChannelsInSubset);
        Pxx = zeros(0,'like',xProto);
        for ii = 1:numSubsets
            % Extract subset of channels to process from chindx and chindy
            subsetIdx = (ii-1)*numChannelsInSubset + 1: min(ii*numChannelsInSubset, numChannels);
            subsetX = subsref(x, substruct('()', {':', chindx(subsetIdx)}));
            subsetY = subsref(y, substruct('()', {':', chindy(subsetIdx)}));
            
            % Place x and y into columns according to the window size and
            % overlap.
            subsetX = parallel.internal.gpu.extractWindows(subsetX,length(win),noverlap);
            subsetY = parallel.internal.gpu.extractWindows(subsetY,length(win),noverlap);
            
            if ii ~= 1
                P = localComputeSpectraGPU(subsetX,subsetY,win,...
                    options,esttype,k,[],freqVectorSpecified);
            else
                % Request w and units only once
                [P,w,units] = localComputeSpectraGPU(subsetX,subsetY,win,...
                    options,esttype,k,[],freqVectorSpecified);
            end
            Pxx = [Pxx, P]; %#ok<AGROW>
        end
        % y will never be empty for 'tfe','tfe2','mscohere'. isempty(y) is
        % a guard for coder size inference.
        
    case 'tfe'
        LminusOverlap = L-noverlap;
        xStart = 1:LminusOverlap:k*LminusOverlap;
        xEnd   = xStart+L-1;
        if options.MIMO
            [numChanxy, chindy, chindx] = localChannelIdx(y,x,options.MIMO);
            [numChanxx, chindx1, chindx2] = localChannelIdx(x,x,options.MIMO);
            Sxx = zeros(nFreqs,numChanxx,class(x));
            Sxy = zeros(nFreqs,numChanxy,class(x));
            [Pxx,w,units] = localComputeSpectra(Sxx,x(:,chindx1),x(:,chindx2),xStart,xEnd,win,...
                options,esttype,k,cmethod,freqVectorSpecified);
            % Cross PSD.  The frequency vector and xunits are not used.
            if ~isempty(y)
                Pxy = localComputeSpectra(Sxy,y(:,chindy),x(:,chindx),xStart,xEnd,win,...
                    options,esttype,k,cmethod,freqVectorSpecified);
            else
                Pxy = zeros(0,class(x));
            end
        else
            numChan = max(size(x,2),size(y,2));
            Sxx = zeros(nFreqs,numChan,class(x));
            Sxy = zeros(nFreqs,numChan,class(x));
            [Pxx,w,units] = localComputeSpectra(Sxx,x,[],xStart,xEnd,win,...
                options,esttype,k,cmethod,freqVectorSpecified);
            % Cross PSD.  The frequency vector and xunits are not used.
            if ~isempty(y)
                Pxy = localComputeSpectra(Sxy,y,x,xStart,xEnd,win,...
                    options,esttype,k,cmethod,freqVectorSpecified);
            else
                Pxy = zeros(0,class(x));
            end
        end
        
        if options.MIMO && size(x,2) > 1
            Pxx = localComputeMIMO(x,y,Pxx,Pxy,[],'tfe');
        else
            Pxx = bsxfun(@rdivide, Pxy, Pxx);
        end
        
    case 'tfeh2'
        LminusOverlap = L-noverlap;
        xStart = 1:LminusOverlap:k*LminusOverlap;
        xEnd   = xStart+L-1;
        if options.MIMO
            [numChanxy, chindx, chindy] = localChannelIdx(x,y,options.MIMO);
            [numChanyy, chindy1, chindy2] = localChannelIdx(y,y,options.MIMO);
            Syy = zeros(nFreqs,numChanyy,class(x));
            Sxy = zeros(nFreqs,numChanxy,class(x));
            if ~isempty(y)
                [Pyy,w,units] = localComputeSpectra(Syy,y(:,chindy1),y(:,chindy2),xStart,xEnd,win,...
                    options,esttype,k,cmethod,freqVectorSpecified);
                % Cross PSD.  The frequency vector and xunits are not used.
                Pxy = localComputeSpectra(Sxy,x(:,chindx),y(:,chindy),xStart,xEnd,win,...
                    options,esttype,k,cmethod,freqVectorSpecified);
            else
                Pyy = zeros(0,class(x));
                Pxy = zeros(0,class(x));
                w = [];
                units = '';
            end
        else
            numChan = max(size(x,2),size(y,2));
            Syy = zeros(nFreqs,numChan,class(x));
            Sxy = zeros(nFreqs,numChan,class(x));
            if ~isempty(y)
                [Pyy,w,units] = localComputeSpectra(Syy,y,[],xStart,xEnd,win,...
                    options,esttype,k,cmethod,freqVectorSpecified);
                % Cross PSD.  The frequency vector and xunits are not used.
                Pxy = localComputeSpectra(Sxy,x,y,xStart,xEnd,win,...
                    options,esttype,k,cmethod,freqVectorSpecified);
            else
                Pyy = zeros(0,class(x));
                Pxy = zeros(0,class(x));
                w = [];
                units = '';
            end
        end
        
        if options.MIMO && size(x,2) > 1
            Pxx = localComputeMIMO(x,y,[],Pxy,Pyy,'tfeh2');
        else
            Pxx = bsxfun(@rdivide, Pyy, Pxy);
        end
        
    case 'mscohere'
        % Note: (Sxy1+Sxy2)/(Sxx1+Sxx2) != (Sxy1/Sxy2) + (Sxx1/Sxx2)
        % ie, we can't push the computation of Cxy into computeperiodogram
        
        % Maximum number of samples in the subset of channels of each input
        % to process at a time. If a single channel has more samples, it
        % will be processed at once, it's not further divided into smaller
        % segments.
        maxNumSamples = 2e6;
        
        % Pxx
        Pxx = zeros(0,'like',xProto);
        numChannelsInSubsetX = max(1,floor(maxNumSamples/size(x,1)));
        [numChannelsXX, chindx1, chindx2] = localChannelIdx(x,x,options.MIMO);
        numSubsetsXX = ceil(numChannelsXX/numChannelsInSubsetX);
        for ii = 1:numSubsetsXX
            % Extract subset of channels to process from chindx1 and
            % chindx2.
            subsetIdx = (ii-1)*numChannelsInSubsetX + 1: min(ii*numChannelsInSubsetX, numChannelsXX);
            subsetX1 = subsref(x, substruct('()', {':', chindx1(subsetIdx)}));
            subsetX2 = subsref(x, substruct('()', {':', chindx2(subsetIdx)}));
            
            % Place x into columns according to the window size and
            % overlap.
            subsetX1 = parallel.internal.gpu.extractWindows(subsetX1,length(win),noverlap);
            subsetX2 = parallel.internal.gpu.extractWindows(subsetX2,length(win),noverlap);
            
            if ii ~= 1
                Px = localComputeSpectraGPU(subsetX1,subsetX2,win,...
                    options,esttype,k,[],freqVectorSpecified);
            else
                % Request w and units only once
                [Px,w,units] = localComputeSpectraGPU(subsetX1,subsetX2,win,...
                    options,esttype,k,[],freqVectorSpecified);
            end
            Pxx = [Pxx, Px]; %#ok<AGROW>
        end
        
        % Pyy - Welch Periodogram for default combination and MIMO.
        Pyy = zeros(0,'like',xProto);
        numChannelsInSubsetY = max(1,floor(maxNumSamples/size(y,1)));
        [numChannelsYY, chindy1, chindy2] = localChannelIdx(y,y,false);
        numSubsetsYY = ceil(numChannelsYY/numChannelsInSubsetY);
        for ii = 1:numSubsetsYY
            % Extract subset of channels to process from chindy1 and
            % chindy2.
            subsetIdx = (ii-1)*numChannelsInSubsetY + 1: min(ii*numChannelsInSubsetY, numChannelsYY);
            subsetY1 = subsref(y, substruct('()', {':', chindy1(subsetIdx)}));
            subsetY2 = subsref(y, substruct('()', {':', chindy2(subsetIdx)}));
            
            % Place y into columns according to the window size and
            % overlap.
            subsetY1 = parallel.internal.gpu.extractWindows(subsetY1,length(win),noverlap);
            subsetY2 = parallel.internal.gpu.extractWindows(subsetY2,length(win),noverlap);
            
            Py = localComputeSpectraGPU(subsetY1,subsetY2,win,...
                    options,esttype,k,[],freqVectorSpecified);
            Pyy = [Pyy, Py]; %#ok<AGROW>
        end
        
        % Pxy
        numChannelsInSubset = min(numChannelsInSubsetX, numChannelsInSubsetY);
        [numChannelsXY, chindx, chindy] = localChannelIdx(x,y,options.MIMO);
        numSubsetsXY = ceil(numChannelsXY/numChannelsInSubset);
        Pxy = zeros(0,'like',xProto);
        for ii = 1: numSubsetsXY
            % Extract subset of channels to process from chindx and
            % chindy.
            subsetIdx = (ii-1)*numChannelsInSubset + 1: min(ii*numChannelsInSubset, numChannelsXY);
            subsetX = subsref(x, substruct('()', {':', chindx(subsetIdx)}));
            subsetY = subsref(y, substruct('()', {':', chindy(subsetIdx)}));
            
            % Place x and y into columns according to the window size and
            % overlap.
            subsetX = parallel.internal.gpu.extractWindows(subsetX,length(win),noverlap);
            subsetY = parallel.internal.gpu.extractWindows(subsetY,length(win),noverlap);
            
            P = localComputeSpectraGPU(subsetX,subsetY,win,...
                options,esttype,k,[],freqVectorSpecified);
            Pxy = [Pxy, P]; %#ok<AGROW>
        end
        
        if options.MIMO && nChX > 1
            Pxx = localComputeMIMO(Pxx,Pxy,Pyy,nChX,nChY,'mscohere');
        else
            Pxx = (abs(Pxy).^2)./(Pxx.*Pyy); % Cxy
        end
        
    otherwise
        Pxx = zeros(0,'like',x);
        w = [];
        method = "";
        
end

% Compute confidence intervals if needed
if ~isnan(options.conflevel)
    if any(strcmpi(esttype,{'ms','power','psd'})) && method ~= "plus"
        % Always compute the confidence interval around the average
        % spectrum
        isAvgMethod = true;
        [avgPxx,w] = localComputeSpectraGPU(x,[],win,...
                options,esttype,k,isAvgMethod,freqVectorSpecified);
    else
        avgPxx = Pxx;
    end
    % Cast to enforce precision rules
    avgPxx = double(avgPxx);
    Pxxc = signal.internal.spectral.confInterval(options.conflevel, avgPxx, isreal(x), w, options.Fs, k);
elseif nargout>2
    if any(strcmpi(esttype,{'ms','power','psd'})) && method ~= "plus"
        % Always compute the confidence interval around the average
        % spectrum
        isAvgMethod = true;
        [avgPxx,w] = localComputeSpectraGPU(x,[],win,...
                options,esttype,k,isAvgMethod,freqVectorSpecified);
    else
        avgPxx = Pxx;
    end
    % Cast to enforce precision rules
    avgPxx = double(avgPxx);
    Pxxc = signal.internal.spectral.confInterval(0.95, avgPxx, isreal(x), w, options.Fs, k);
else
    Pxxc = [];
end

if nargout==0 && coder.target('MATLAB')
    signal.internal.spectral.plotWelch(Pxx,w,Pxxc,esttype,noverlap,L,winName,winParam,units,options);
else
    if options.centerdc
        [Pxx, w, Pxxc] = signal.internal.spectral.psdcenterdc(Pxx, w, Pxxc, options, esttype);
    end
    
    % If the input is a vector and a row frequency vector was specified,
    % return output as a row vector for backwards compatibility.
    if nrow > 1 && isVectorX
        Pxx = Pxx.';
        w = w.';
    end
    
    % Cast to enforce precision rules
    % Only cast if output is requested, otherwise, plot using double
    % precision frequency vector.
    if isUnderlyingType(Pxx,'single')
        w = single(w);
    end
    
    % Reshape output if MIMO
    if options.MIMO
        switch lower(esttype)
            case {'tfe','tfeh2'}
                Pxx = reshape(Pxx,size(Pxx,1),nChY,nChX);
            case 'cpsd'
                Pxx = reshape(Pxx,size(Pxx,1),nChX,nChY);
        end
    end
    
    if nargout < 2
        varargout = {Pxx,w}; % Pxx=PSD, MEANSQUARE, CPSD, or TFE
    else
        varargout = {Pxx,w,Pxxc};
    end
    
end

end

function [Pxx,w,units] = localComputeSpectraGPU(x,y,win,options,esttype,k,isAvgMethod,freqVectorSpecified)

if ~isempty(y)
    [Sxxk,w] = computeperiodogram({x,y},win,options.nfft,esttype,options.Fs);
    Sxx1 = sum(Sxxk, 2);
else
    [Sxxk,w] = computeperiodogram(x,win,options.nfft,esttype,options.Fs);
    if options.maxhold && ~isAvgMethod
        % cmethod1 = @(seg,nextseg) max(seg,real(k*nextseg));
        Sxx1 = max(real(k.*Sxxk), [], 2);
        Sxx1 = squeeze(Sxx1);
    elseif options.minhold && ~isAvgMethod
        % cmethod2 = @(seg,nextseg) min(seg,real(k*nextseg));
        Sxx1 = min(real(k.*Sxxk), [], 2);
        Sxx1 = squeeze(Sxx1);
    else
        Sxx1 = sum(Sxxk, 2);
    end
end

Sxx1 = Sxx1./k; % Average the sum of the periodograms

% Generate the freq vector directly in Hz to avoid roundoff errors due to
% conversions later.
if ~freqVectorSpecified
    w = psdfreqvec('npts',options.nfft, 'Fs',options.Fs);
end
sxx1Proto = subsref(Sxx1, substruct('()', {[]}));
w = cast(w, 'like', real(sxx1Proto));

% Compute the 1-sided or 2-sided PSD [Power/freq] or mean-square [Power].
% Also, corresponding freq vector and freq units.
Sxx1 = squeeze(Sxx1);
[Pxx,w,units] = computepsd(Sxx1,w,options.range,options.nfft,options.Fs,esttype);
end

function [Pxx,w,units] = localComputeSpectra(Sxx,x,y,xStart,xEnd,win,options,esttype,k,cmethod,freqVectorSpecified)

w=[];
if ~isempty(y)
    Sxx1 = zeros(0,'like',1i*Sxx); %initialization
    for ii = 1:k
        [Sxxk,w] =  computeperiodogram({x(xStart(ii):xEnd(ii),:),...
            y(xStart(ii):xEnd(ii),:)},win,options.nfft,esttype,options.Fs);
        if ii == 1
            Sxx1 = cmethod(Sxx,Sxxk);
        else
            Sxx1  = cmethod(Sxx1,Sxxk);
        end
    end
    
else
    Sxx1 = zeros(0,class(Sxx)); %initialization
    for ii = 1:k
        [Sxxk,w] = computeperiodogram(x(xStart(ii):xEnd(ii),:),win,...
            options.nfft,esttype,options.Fs);
        if ii == 1
            % use Sxx for applying cmethod in first iteration
            Sxx1 = cmethod(Sxx,Sxxk);
        else
            % accumulate from the second iteration
            Sxx1  = cmethod(Sxx1,Sxxk);
        end
    end
end

Sxx1 = Sxx1./k; % Average the sum of the periodograms

% Generate the freq vector directly in Hz to avoid roundoff errors due to
% conversions later.
if ~freqVectorSpecified
    w = psdfreqvec('npts',options.nfft, 'Fs',options.Fs);
end

% Compute the 1-sided or 2-sided PSD [Power/freq] or mean-square [Power].
% Also, corresponding freq vector and freq units.
[Pxx,w,units] = computepsd(Sxx1,w,options.range,options.nfft,options.Fs,esttype);
end

function [numChan, chindx, chindy] = localChannelIdx(x,y,MIMO)
% Find the number of cross-spectra of the columns of x and y to compute,
% numChan, and the indices into the inputs x and y to compute each
% cross-spectrum. If MIMO is specified, every combination of the columns of
% x and y is needed. Otherwise, compute cross-spectra of column-wise pairs
% of column vectors in x and y.
Nx = size(x,2);
Ny = size(y,2);
if MIMO
    numChan = Nx*Ny;
    chindx = repmat(1:Nx,1,Ny);
    chindy1 = repmat(1:Ny,Nx,1);
    chindy = chindy1(:)';
else
    % Here, the number of channels in x and y is the same, or they are
    % different with one of them being equal to one. This is, cases of
    % multichannel signals with single-channel signals.
    numChan = max(Nx,Ny);
    chindx = 1:Nx;
    chindy = 1:Ny;
    if Nx ~= Ny
        if Nx == 1
            chindx = repmat(chindx,1,Ny);
        elseif Ny == 1
            chindy = repmat(chindy,1,Nx);
        end
    end
end
end

function Pout = localComputeMIMO(Pxx,Pxy,Pyy,nIn,nOut,esttype)
% Compute the transfer function for a MIMO system. At each frequency, the
% transfer function H is given by H(f) = MPxy(f)/MPxx(f), where MPxy and
% MPxx are matrices reshaped from the columns of Pxy and Pxx. Note that Pxy
% is a misnomer here, since it is formed from the DFT of y times the
% complex conjugate of the DFT of x.

if coder.target('MATLAB')
    % Disable warnings for the case that Pxx is singular. This will avoid
    % repeated warnings.
    [msg0, id0] = lastwarn('');
    state(1) = warning('off','MATLAB:nearlySingularMatrix'); %#ok<*EMVDF>
    state(2) = warning('off','MATLAB:singularMatrix');
    cleanupObj = onCleanup(@()warning(state));
end

switch esttype
    case 'tfe'
        Pout = zeros(size(Pxy),'like',Pxy); %Txy
        for i = 1:size(Pxy,1)
            P = reshape(Pxy(i,:),nOut,nIn)/reshape(Pxx(i,:),nIn,nIn);
            Pout(i,:) = P(:);
        end
    case 'tfeh2'
        % Number of input and output channels are equal
        Pout = zeros(size(Pxy),'like',Pxy); %Txy
        for i = 1:size(Pxy,1)
            P = reshape(Pyy(i,:),nOut,nOut)/reshape(Pxy(i,:),nOut,nOut);
            Pout(i,:) = P(:);
        end
    case 'mscohere'
        pxyProto = cast([],"like",Pxy);
        realPxyProto = real(pxyProto);
        Pout = zeros(size(Pxx,1),nOut,'like',realPxyProto); %Cxy
        Pxx = reshape(Pxx,[],nIn,nIn);
        Pxx = permute(Pxx,[2,3,1]);
        
        for iOut = 1:nOut
            S = substruct('()',{':',(iOut-1)*nIn+1:(iOut-1)*nIn+nIn});
            Pyx0 = subsref(Pxy,S);
            Pxy0 = Pyx0.';
            Pyx0 = conj(Pyx0);
            Pyx0 = permute(Pyx0, [3, 2, 1]);
            Pxy0 = permute(Pxy0, [1, 3, 2]);
            Pyy0 = subsref(Pyy,substruct('()',{':',iOut}));
            Pyy0 = permute(Pyy0, [3, 2, 1]);
            
            PyxPxx = pagefun(@mrdivide, Pyx0, Pxx);
            PxyPyy = pagefun(@mrdivide, Pxy0, Pyy0);
            PoutTemp = real(pagefun(@mtimes, PyxPxx, PxyPyy));
            Pout = subsasgn(Pout,substruct('()', {':',iOut}), squeeze(PoutTemp));
        end
end

if coder.target('MATLAB')
    % Warn if a singular matrix warning occured. Reset lastwarn if no warnings
    % occured.
    [~,msgid] = lastwarn;
    if strcmp(msgid,'MATLAB:nearlySingularMatrix') || strcmp(msgid,'MATLAB:singularMatrix')
        coder.internal.warning('signal:welch:SingularMatrixMIMO');
    elseif isempty(msgid)
        lastwarn(msg0,id0);
    end
end

end
% [EOF]

% LocalWords:  Pxx NOVERLAP NFFT Fs SPECTRUMTYPE ESTTYPE Pxy Txy tfeh Cxy mimo
% LocalWords:  Pxxc Petre Stoica Monson allownumeric xunits Sxy Sxx
% LocalWords:  computeperiodogram conflevel MEANSQUARE cmethod periodograms
% LocalWords:  roundoff npts Manolakis Ingle Kagon Graw MPxy MPxx DFT occured
