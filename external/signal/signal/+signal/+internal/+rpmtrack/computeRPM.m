function [rpm,tOut] = computeRPM(Sx,Fx,Tx,Px,opts)
% Compute RPM using the coarse-fine method
% opts is a structure containing all required parameters

fs = opts.Fs;
order = opts.Order;
points = opts.SortedPoints;
powPen = opts.PowerPenalty;
freqPen = opts.FrequencyPenalty;
% Align time vector, start time and end time so that they have the same
% time origin
initT = opts.TimeVector(1); % initial time instance
t = opts.TimeVector-initT; % aligned time vector
if isrow(t)
    t = t.';
end
startT = opts.StartTime-initT; % aligned start time
endT = opts.EndTime-initT; % aligned end time

% Find the time and frequency indexes of the points and truncate the time
% vectors
[ptIdx,pfIdx,stIdxInT,etIdxInT,truncT,stIdxInTx,etIdxInTx,truncTx] = ...
    findPointIndexAndTruncateTimeVectors(points,initT,t,Tx,Fx,startT,endT);

if strcmpi(opts.Method,'stft')
    % Compute coarse RPM by finding a coarse estimate of the instantaneous
    % frequency (IF) and interpolate it to obtain a coarse RPM estimate of
    % the length of the signal in the interval startT and endT.
    coarseIF = coarseTFRidge(Sx,Fx,Px,ptIdx,pfIdx,powPen,freqPen,stIdxInTx,...
        etIdxInTx,'stft');
    coarseRPM = interp1(truncTx,coarseIF*60/order,truncT,'linear','extrap');
    
    % Interpolation may cause coarseRPM to be bigger than 60*Nyquist rate
    % or be negative, so in these cases, those values are replaced by the
    % Nyquist rate or 0, respectively
    coarseRPM(coarseRPM <= 0) = eps(class(coarseRPM));
    coarseRPM(coarseRPM/60 >= fs/2) = fs/2-eps(class(coarseRPM));
    
    % Extract order waveform for the signal defined between start time and
    % end time using Vold-Kalman filter. When the number of samples between
    % start time and end time is bigger than 3e4, we use the SegmentLength
    % parameter of ORDERWAVEFORM to reduce memory requirements and
    % computation time. Note that if the signal length within start time
    % and end time is bigger than 5e4, ORDERWAVEFORM warns.
    if (etIdxInT-stIdxInT > 3e4)
        orderWF = orderwaveform(opts.DataVector(stIdxInT:etIdxInT),fs,...
            coarseRPM,order,'SegmentLength',2e4);
    else
        orderWF = orderwaveform(opts.DataVector(stIdxInT:etIdxInT),fs,...
            coarseRPM,order);
    end
    
    % Fine RPM estimate
    [Sowf,Fowf,Towf] = pspectrum(orderWF,fs,'spectrogram',...
        'FrequencyResolution',opts.FrequencyResolution);
    
    % tfridge function does not support single precision. Cast to double if
    % needed.
    if opts.IsSingle
        Sowf = double(Sowf);
    end
    
    % Find the ridge of orderWF in its time-frequency representation Sowf
    fineIF = tfridge(Sowf,Fowf,freqPen/10,'NumRidges',1);
    
    if opts.IsSingle
        fineIF = single(fineIF);
    end
    % In order for Towf to have the same time origin as startT, startT must
    % be added to Towf
    rpm = interp1(Towf+startT,fineIF*60/order,truncT,'linear','extrap');
    rpm(rpm <= 0) = eps(class(coarseRPM));
else
    % Extract the FSST of the ridge order waveform
    Sowf = coarseTFRidge(Sx,Fx,Px,ptIdx,pfIdx,powPen,freqPen,stIdxInTx,...
        etIdxInTx,'fsst');
    
    if opts.IsSingle
        Sowf = double(Sowf);
    end
    
    % Fine RPM estimate
    % Find the ridge of orderWF in its time-frequency representation Sowf
    fineIF = tfridge(Sowf,Fx,freqPen/10,'NumRidges',1);
    
    if opts.IsSingle
        fineIF = single(fineIF);
    end
    
    rpm = 60*fineIF/order;
    rpm = rpm(stIdxInT:etIdxInT);
end


% Output time vector
tOut = truncT + initT;

end




%==========================================================================
function [ptIdx,pfIdx,stIdxInT,etIdxInT,truncT,stIdxInTx,etIdxInTx,truncTx] = ...
    findPointIndexAndTruncateTimeVectors(points,initT,t,Tx,Fx,startT,endT)
% Find point time and point frequency index in Tx and Fx respectively and
% truncate the time vector t and time vector Tx, over which the signal and
% map are defined, respectively, and find the start and end indexes of the
% truncated time vectors based on startT and endT
% Inputs:
%   points: Np-by-2 vector of sorted specified ridge points
%   initT: initial time
%   t: aligned time vector (aligned with respect to time origin 0)
%   Tx: aligned time vector in the map
%   Fx: frequency vector in the map
%   startT: specified start time which is aligned with respect to 0
%   endT: specified end time which is aligned with respect to 0
%
% Outputs:
%   ptIdx: point time indexes in Tx
%   pfIdx: point frequency indexes in Fx
%   stIdxInT: start time index in time vector t
%   etIdxInT: end time index in time vector t
%   truncT: truncated version of time vector t based on startT and endT
%   stIdxInTx: start time index in time vector Tx
%   etIdxInTx: end time index in time vector Tx
%   truncTx: truncated version of time vector Tx based on startT and endT


% Align the time instances of the points so that they have the same time
% origin as t, Tx, satrtT and endT
pT = points(:,1)'-initT;
% Find the indexes of the points' time in Tx
[~,ptIdx] = min(abs(Tx-pT));

% Find the indexes of the points' frequency in Fx
[~,pfIdx] = min(abs(Fx-(points(:,2)')));

% Find the unique points' times to avoid doing same calculations in
% coarseTFRidge function twice
[ptIdx,idx] = unique(ptIdx);
pfIdx = pfIdx(idx);

% Find the indexes corresponding to startT and endT in t
[~,setIdxInT] = min(abs(t-[startT,endT]),[],1);
stIdxInT = setIdxInT(1); % index corresponding to startT in t
etIdxInT = setIdxInT(2); % index corresponding to endT in t
truncT = t(stIdxInT:etIdxInT); % truncated time vector

% Find the indexes corresponding to startT and endT in Tx
[~,setIdxInTx] = min(abs(Tx-[startT,endT]));
stIdxInTx = setIdxInTx(1); % index corresponding to startT in Tx
etIdxInTx = setIdxInTx(2); % index corresponding to endT in Tx
truncTx = Tx(stIdxInTx:etIdxInTx); % truncated time vector 

end

%==========================================================================
%                           coarseTFRidge
%==========================================================================
function varargout = coarseTFRidge(S,F,pow_db,ptIdx,pfIdx,ppen,fpen,stIdx,etIdx,method)
%COARSETFRIDGE extracts the ridge corresponding to the specified points
% Inputs:
%   S: time-frequency map of the signal with size N-by-M
%   F: frequency vector of the map with length N
%   pow_db: power map in dB
%   ptIdx: points' time indexes which are aligned to the time origin 0
%   pfIdx: points' frequency indexes
%   ppen: power penalty in dB (scalar)
%   fpen: frequency penalty (scalar)
%   stIdx: index of the start time in the T vector (scalar)
%   etIdx: index of the end time in the T vector (scalar)
%   method: the method (stft or fsst)
%
%   Note that the start time and end time are already aligned to the time
%   origin 0, respectively. The vector T is the time vector at which the
%   map
% Outputs:
%    When the method is 'stft', the function returns the coarse estimate of
%    the instantaneous frequency which is proportional to the coarse
%    estimate of the RPM. The coarse RPM estimate is then fed to
%    orderwaveform function to extract the order waveform. However, when
%    the method is 'fsst', the function returns the extracted
%    time-frequency map which is actually the time-frequency representation
%    of the order waveform.
%

if strcmpi(method,'fsst')
    cachedS = S;
    S = abs(S.^2+eps);
end

% Only consider the TF values within the specified/default start time index
% (stIdx) and end time index (etIdx)
obsTInd = (stIdx:etIdx); % indexes of observation time interval
% Convert to -10*log10 energy
S = S(:,obsTInd);
S = S./sum(S(:));
S = -10*log10(abs(S)+eps);

% ALGORITHM CONSTANTS:
nFreqs = length(F); % number of frequency bins (N)
% Number of frequency bin indexes (nfbi) above and below of the ridge
% index, obtained in the previous step, is 3. Hence, the length of
% frequency bin index window over which the algorithm searches for the best
% ridge index is 7.
nfbi = 3;
% Convert fpen to a value that has the unit of frequency as the algorithm
% uses the ridge indexes.
fpen = 0.5*fpen*(F(2)-F(1));
% In order to index to the right time instance of the original map, we
% should adjust the index by adjTInd.
adjTIdx = stIdx-1;
% etIdx is the last time index for the 'Walk to the right' step in the
% following algorithm so it is added to ptIdx to reuse the code for this
% time index.
ptIdx = [ptIdx,etIdx];
% Since only TF values within the start time and end time are considered,
% the point time indexes must be adjusted according to the index of start
% time (stIdx)
ptIdx = ptIdx - adjTIdx;

% RIDGE EXTRACTION ALGORITHM:
% Pre-allocate frequency ridge index (ridgeIdx)
ridgeIdx = zeros(length(obsTInd),1);

% Walk to the right
for np = 1:length(ptIdx)-1
    % Window of frequency bin indexes around the frequency index of the
    % current point
    FBIW = (max(pfIdx(np)-nfbi,1):min(pfIdx(np)+nfbi,nFreqs-1));
    % Find the ridge index at the current point
    ridgeIdx(ptIdx(np),1) = findRidgeAtPoint(FBIW,S(FBIW,ptIdx(np)));
    
    % Window of frequency bin indexes around the ridge index of the
    % current specified point
    FBIW = (max(1,ridgeIdx(ptIdx(np),1)-nfbi):...
        min(ridgeIdx(ptIdx(np),1)+nfbi,nFreqs-1));
    % A two-step regularization in frequency is applied in order to find
    % the best ridge index for the time indexes between two consecutive
    % points' time indexes. So at each specified point, the ridge index
    % corresponding to the time index right before the time index of the
    % current point is obtained.
    if (ptIdx(np) == stIdx-adjTIdx)
        % Find the ridge index corresponding to the time index right after
        % the time index of the current point to avoid any indexing issues.
        ridgeIdx(ptIdx(np)+1,1) = findRidgeAtNeighbor(...
            ridgeIdx(ptIdx(np),1),FBIW,S(FBIW,ptIdx(np)+1),fpen);
        ptIdx(np) = stIdx-adjTIdx+1;
    elseif (ptIdx(np) < etIdx-adjTIdx)
        % Find the ridge index corresponding to the time index right before
        % the time index of the current point
        ridgeIdx(ptIdx(np)-1,1) = findRidgeAtNeighbor(...
            ridgeIdx(ptIdx(np),1),FBIW,S(FBIW,ptIdx(np)-1),fpen);
    end
    
    % Find the ridge indexes corresponding to the time indexes between two
    % consecutive point time indexes, i.e. ptIdx(np) and ptIdx(np+1)
    for nt = ptIdx(np)+1:ptIdx(np+1)
        ridgeIdx(nt) = findRidgeBetweenPoints(ridgeIdx(nt-1,1),...
            ridgeIdx(nt-2,1),nfbi,nFreqs,S(:,nt),pow_db(:,nt),...
            pow_db(ridgeIdx(nt-1,1),nt-1+adjTIdx),ppen,fpen);
    end
end

% Walk to the left of the very first point
if (ptIdx(1) == etIdx-adjTIdx)
    % Find the ridge index corresponding to the time index right before the
    % time index of the current point to avoid any indexing issues.
    FBIW = (max(1,ridgeIdx(ptIdx(1),1)-nfbi):...
        min(ridgeIdx(ptIdx(1),1)+nfbi,nFreqs-1));
    ridgeIdx(ptIdx(1)-1,1) = findRidgeAtNeighbor(...
        ridgeIdx(ptIdx(1),1),FBIW,S(FBIW,ptIdx(1)-1),fpen);
    ptIdx(1) = etIdx-1-adjTIdx;
end
for nt = ptIdx(1)-1:-1:1
    ridgeIdx(nt) = findRidgeBetweenPoints(ridgeIdx(nt+1,1),...
        ridgeIdx(nt+2,1),nfbi,nFreqs,S(:,nt),pow_db(:,nt),...
        pow_db(ridgeIdx(nt+1,1),nt+1+adjTIdx),ppen,fpen);
end

% output
if strcmpi(method, 'stft')
    varargout{1} = F(ridgeIdx);
else % fsst method
    extS = complex(zeros(size(cachedS),'like',cachedS));
    for n = stIdx:etIdx
        extS(ridgeIdx(n-adjTIdx),n) = cachedS(ridgeIdx(n-adjTIdx),n);
    end
    varargout{1} = extS;
end

end

%==========================================================================
function pri = findRidgeAtPoint(FBIW,S)
% Find the ridge index corresponding to the minimum value of the TF map
% around the current specified point
%
% Inputs:
%   FBIW: a 1-by-7 window of frequency bin indexes around the frequency
%   index of the specified point 
%   S: a 7-by-1 vector of the values of the TF map at FBIW
% Output:
%   pri: the ridge index of the current point
%
% This helps the algorithm be less prone to lie on a wrong ridge. It also
% causes the algorithm to be less sensitive to the cursor precision in
% case where the points are specified through the interactive plot.
[~,idx] = min(S);
pri = FBIW(idx);

end

%==========================================================================
function nri = findRidgeAtNeighbor(pri,FBIW,S,fpen)
% Find the ridge index of the current point's neighbor by applying a 1-step
% regularization in frequency
% Inputs:
%   pri: the ridge index of the current point obtained by findRidgeAtPoint
%   FBIW: a 1-by-7 window of frequency bin indexes around rip 
%   S: a 7-by-1 vector of the values of the TF map at FBIW
%   fpen: frequency penalty
% Output:
%   nri: the ridge index corresponding to the point's neighbor
%
[~,idx] = min(S+fpen*(FBIW'-pri).^2);
nri = FBIW(idx);

end

%==========================================================================
function bri = findRidgeBetweenPoints(ri1,ri2,nfbi,nFreqs,S,p,p1,ppen,fpen)
% Find the ridge index corresponding to the time indexes between two
% consecutive points' time indexes
%
% Inputs:
%   ri1: ridge index obtained at previous step
%   ri2: ridge index obtained one step before the step at which ri1 is
%        obtained
%   nfbi: number of frequency bin indexes
%   nFreqs: number of frequency bins (N)
%   S: an N-by-1 vector of TF map values at current time index
%   p: an N-by-1 vector of powers in dB at current time index
%   p1: value of power in dB at the previous time index and ri1 
%   ppen: power penalty in dB
%   fpen: frequency penalty
% 
% Output:
%   bri: ridge index corresponding to the time index between two
%        consecutive specified ridge points' time indexes
%

% Apply the slope method for selecting a better center for frequency bin
% window in the case where power penalty (ppen) is set to Inf. applySlope
% is a Boolean variable that determines if the algorithm should apply the
% slope method or not.
applySlope = (ppen == Inf);
% Slope between the two ridge indexes obtained previously at two
% consecutive time indexes
slope = ri1 - ri2;
FBIW = (max(1,ri1+applySlope*slope-nfbi):...
    min(ri1+applySlope*slope+nfbi,nFreqs-1));
% Due to the fact that slope is a rough estimate, it may causes the FBIW to
% become empty. In such a situation, the previously estimate ridge index
% (ri1) becomes the center of the window and slope is set to 0.
if isempty(FBIW)
    FBIW = (max(1,ri1-nfbi):min(ri1+nfbi,nFreqs-1));
    slope = 0;
end
% Find the best ridge index as the minimum value of the metric
[bestVal,idx] = min(S(FBIW,1)+fpen*(FBIW'-2*ri1+ri2).^2);
bri = FBIW(idx);

% To apply power penalty, first compute the difference between the power at
% current time index and recently estimated ridge index with the power at
% the previous time index and previously estimated ridge index (p1) in
% order to compare this difference with the power penalty (ppen). If the
% difference is less than the specified power penalty, return bri as the
% best ridge index. But if the difference is greater than the power
% penalty, then the algorithm increases the frequency bin window either
% from below or above depending upon the slope (slope) measured based on
% the two previously estimated ridge indexes (ri1 and ri2). If slope is
% positive (respectively negative), then the width of frequency bin index
% window (FBWI) is increased by adding 1 index to the top (respectively
% bottom). If slope is zero, the width of FBIW is increased by adding 2
% indexes, one to the top and one to the bottom.

% Maximum number of iterations, that the following while loop is going
% through in the case where power penalty is set to some finite value, is
% the number of frequency bins (nFreqs).
niter = 0; % iteration counter
while ((niter < nFreqs) && (abs(p(bri,1)-p1) > ppen))
    if (slope <= 0)
        bottomIdx = FBIW(1);
        % Find added frequency bin index to the bottom
        addedFBI = max(1,bottomIdx-1); 
        % Compute the metric for the added index
        val = S(addedFBI,1)+fpen*(addedFBI-2*ri1+ri2)^2;
        if ((val < bestVal) && (abs(p(addedFBI,1)-p1) <= ppen))
            bestVal = val;
            bri = addedFBI;
        end
        if (bottomIdx ~= 1)
            % If bottomIdx is equal to 1, do not add it to FBIW again
            FBIW = [addedFBI,FBIW]; %#ok
        end
    end
    if (slope >= 0)
        topIdx = FBIW(end);
        % Find added frequency bin index to the top
        addedFBI = min(topIdx+1,nFreqs-1); 
        % Compute the metric for the added index
        val = S(addedFBI,1)+fpen*(addedFBI-2*ri1+ri2)^2;
        if ((val < bestVal) && (abs(p(addedFBI,1)-p1) <= ppen))
            bestVal = val;
            bri = addedFBI;
        end
        if (topIdx ~= nFreqs-1)
            % If topIdx is equal to nFreqs, do not add it to FBIW again
            FBIW = [FBIW,addedFBI]; %#ok
        end
    end  
    niter = niter+1;
end
        
end

