function [X,Tout,info] = computeSTFTmag2sig(Smag,opts)
%COMPUTESIGRECMAG computes signal reconstruction from
%magnitude. This function is internal use only. It may be removed in
%the future.

%   Copyright 2020 The MathWorks, Inc.
%#codegen

nfft = opts.FFTLength;
win = opts.Window;
noverlap = opts.OverlapLength;
maxIter = opts.MaxIterations;
method = opts.Method;
freqRange = opts.FrequencyRange;
alpha = opts.UpdateParameter;
epsVal = eps(opts.DataType);
relDiff = cast(inf,opts.DataType);
iter = 0;
normSmag = norm(Smag);

% initialize phase
if strcmpi(opts.InitializeMethod,'random')
    initialPhase = exp(1j*(2*pi*rand(size(Smag),opts.DataType)-pi));
    S = complex(Smag.*initialPhase);
elseif strcmpi(opts.InitializeMethod,'zeros')
    S = complex(Smag);
else % user input
    initialPhase = exp(1j*opts.InitialPhase);
    S = complex(Smag.*initialPhase);
end

% Progress display set-up
if coder.target('MATLAB') && opts.Display
    fprintf('#Iteration  |  Normalized Inconsistency  \n');
    formatstr = '  %5.0f     |        %8.4e \n';
end

switch method
    case 'gla'
        % Griffin-Lim algorithm
        while (iter < maxIter && relDiff > opts.InconsistencyTolerance)
           x = istft(S,'Window',win,'OverlapLength',noverlap,'FFTLength',nfft,...
               'FrequencyRange',freqRange,'InputTimeDimension',opts.TimeDimension);
           % always assume real signal
           Sest = stft(real(x),'Window',win,'OverlapLength',noverlap,'FFTLength',nfft,...
               'FrequencyRange',freqRange,'OutputTimeDimension',opts.TimeDimension); 
           phaseEst = Sest./max(epsVal,abs(Sest));
           S = Smag.*phaseEst;
           relDiff = norm(Sest-S)/normSmag;
           iter = iter+1;
           if opts.Display && coder.target('MATLAB') && (iter ==1 || ~mod(iter,20)...
            || iter >= maxIter || relDiff <= opts.InconsistencyTolerance)
               fprintf(formatstr, iter, relDiff);
           end
        end
        [xrec,Tout] = istft(S,opts.TimeValue,'Window',win,'OverlapLength',noverlap,...
            'FFTLength',nfft,'FrequencyRange',freqRange,'InputTimeDimension',opts.TimeDimension);
    case 'fgla'
        % Fast Griffin-Lim algorithm        
        deltaS = complex(zeros(size(Smag),opts.DataType));
        while (iter < maxIter && relDiff > opts.InconsistencyTolerance)
           x = istft(S,'Window',win,'OverlapLength',noverlap,'FFTLength',nfft,...
               'FrequencyRange',freqRange,'InputTimeDimension',opts.TimeDimension);
           % always assume real signal
           Sest = stft(real(x),'Window',win,'OverlapLength',noverlap,'FFTLength',nfft,...
               'FrequencyRange',freqRange,'OutputTimeDimension',opts.TimeDimension);
           Stmp = Sest + deltaS*alpha;
           phaseEst = Stmp./max(epsVal,abs(Stmp));
           S = Smag.*phaseEst;
           deltaS = S-Sest;
           relDiff = norm(deltaS)/normSmag;
           iter = iter+1;
           if opts.Display && coder.target('MATLAB') && (iter ==1 || ~mod(iter,20)...
            || iter >= maxIter || relDiff <= opts.InconsistencyTolerance)
               fprintf(formatstr, iter, relDiff);
            end
        end
        [xrec,Tout] = istft(S,opts.TimeValue,'Window',win,'OverlapLength',noverlap,...
            'FFTLength',nfft,'FrequencyRange',freqRange,'InputTimeDimension',opts.TimeDimension);
    otherwise
        % Fast Griffin-Lim algorithm propoased by Le Roux
        if strcmpi(opts.TimeDimension,'downrows')
           S1 = permute(S,[2,1,3]);
           Smag1 = permute(Smag,[2,1,3]);
        else
           S1 = S;
           Smag1 = Smag;
        end
        
        % Change to onsided spectrum
        if ~strcmpi(opts.FrequencyRange,'onesided')
            Sonesided = signal.internal.stftmag2sig.formatSTFT(S1,opts,'forward');
            SmagOnesided = signal.internal.stftmag2sig.formatSTFT(Smag1,opts,'forward');
        else
            Sonesided = S1;
            SmagOnesided = Smag1;
        end
        
        normSmag = norm(SmagOnesided);
        
        if isempty(opts.TruncationOrder)
            L = cast(findTruncOrder(opts,Sonesided),opts.DataType);
        else
            L = cast(opts.TruncationOrder,opts.DataType);
        end
        
        coder.internal.errorIf(L>=size(Sonesided,1),'signal:stftmag2sig:InvalidTruncOrder',...
            L,size(Sonesided,1))
                
        T = cast(opts.WindowLength,opts.DataType);
        fshift = cast(T-noverlap,opts.DataType);
        interval = cast(-L:L,opts.DataType);
        expinterv = exp(-1i*2*pi*interval'*(0:(T-1))/nfft);
        Q = cast(fix(T/fshift),opts.DataType);
        windowprod = zeros(T,2*Q-1);
        for iQ = 1:Q
            index=1:(T-(iQ-1)*fshift);
            windowprod(index,iQ+Q-1) = win(index).*win(index+(iQ-1)*fshift);
        end
        windowprod(:,1:Q-1) = windowprod(:,end:-1:end-Q+2);
        weights=(expinterv*windowprod).*exp(-1i*2*pi*interval'*(-(Q-1):(Q-1))/Q);
        % Modified truncated
        weights(L+1,Q) = 0;
        weights(:,1:Q-1) = conj(weights(:,2*Q-1:-1:Q+1));
        if coder.target('MATLAB')
            idxTmp = (-(Q-1):(Q-1))'/Q.*(0:Q-1);
        else
            idxTmp = bsxfun(@times,(-(Q-1):(Q-1))'/Q,(0:Q-1));
        end
        timeCoeff = exp(1j*2*pi*idxTmp);
        Sest = Sonesided;
        weightsAll=bsxfun(@times,weights,shiftdim(timeCoeff,-1));
        phaseEst = complex(zeros(size(Sonesided),opts.DataType));
        
        Sext = complex(zeros(size(Sonesided,1)+(L)*2,size(Sonesided,2)+(Q-1)*2,opts.DataType));
        Sext(L+1:end-L,Q:end-Q+1) = Sonesided;
        
        while (iter < maxIter && relDiff > opts.InconsistencyTolerance)
            % Find large amplitudes
            index = find(SmagOnesided>= mean(SmagOnesided(:)));
            
            % Extend matrix            
            Sext(1:L,Q:end-Q+1) = conj(Sonesided(L+1:-1:2,:));
            % Even nfft
            if signalwavelet.internal.iseven(nfft)
                Sext(end-L+1:end,Q:end-Q+1) = conj(Sonesided(end-1:-1:end-L,:));
            else
                Sext(end-L+1:end,Q:end-Q+1) = conj(Sonesided(end:-1:end-L+1,:));
            end
            
            [inId,imId] = ind2sub(size(SmagOnesided),index);
            
            indNtmp = -(-L:L)+L;
            indMtmp = -(-(Q-1):(Q-1))+Q-1;
            
            
            for iIndex = 1:length(index)              
                in = inId(iIndex);
                im = imId(iIndex);     

                Sest(in,im) = sum(Sext(in+indNtmp,im+indMtmp).*...
                    weightsAll(:,:,mod(in-1,Q)+1),'all');
                phaseEst(in,im) = Sest(in,im)./abs(Sest(in,im));
                Sext(in+L,im+Q-1) = SmagOnesided(in,im)*phaseEst(in,im);
                Sonesided(in,im) = Sext(in+L,im+Q-1);
            end
            relDiff = norm(Sest-Sonesided)/normSmag;
            Sest = Sonesided;
            iter = iter+1;
            if opts.Display && coder.target('MATLAB') && (iter ==1 || ~mod(iter,20)...
            || iter >= maxIter || relDiff <= opts.InconsistencyTolerance)
                fprintf(formatstr, iter, relDiff);
            end
        end
        [xrec,Tout] = istft(Sonesided,opts.TimeValue,'Window',win,'OverlapLength',noverlap,...
            'FFTLength',nfft,'FrequencyRange','onesided');
        
        % Change back to specified frequency range
        if ~strcmpi(opts.FrequencyRange,'onesided')
            Sout = signal.internal.stftmag2sig.formatSTFT(Sonesided,opts,'inverse');
        else
            Sout = Sonesided;
        end
        
        if strcmpi(opts.TimeDimension,'downrows')
           S = permute(Sout(1:size(S,2),1:size(S,1)),[2,1,3]); 
        else
           S = Sout(1:size(S,1),1:size(S,2));
        end
end

X = real(xrec);

% Store results
info = struct('ExitFlag',0, ...
        'NumIterations',iter, ...
        'Inconsistency',relDiff, ...
        'ReconstructedPhase',angle(S), ...
        'ReconstructedSTFT',S);

% Specify stopping flag
if iter < opts.MaxIterations
    info.ExitFlag = 1;
end

% Show stopping information
if coder.target('MATLAB') && opts.Display
    switch info.ExitFlag
        case 0
            finalDisplayStr = getString(message('signal:stftmag2sig:MaxNumIterationHit', opts.MaxIterations));
        case 1
            finalDisplayStr = getString(message('signal:stftmag2sig:ToleranceHit', num2str(opts.InconsistencyTolerance)));
    end
    disp([newline finalDisplayStr newline]);
end

end

function L = findTruncOrder(opts,S)
% Decide the truncation length
H = zeros(size(S),opts.DataType);
H(1,1) = ones(1,opts.DataType);
FH = stft(real(istft(H,'Window',opts.Window,'OverlapLength',opts.OverlapLength,...
    'FFTLength',opts.FFTLength,'FrequencyRange','onesided','InputTimeDimension','acrosscolumn')), ...
    'Window',opts.Window,'OverlapLength',opts.OverlapLength,'FFTLength',opts.FFTLength,...
    'FrequencyRange','onesided','OutputTimeDimension','acrosscolumn');

tmpVec = FH(:,1);
absVec = abs(tmpVec);
L = sum(abs(absVec)>mean(abs(FH(:,1))));
end