function [timeRes, segLen] = getWinDurationForAGivenRBW(desiredRBW,win,winParam,Fs,isKaiserBeta)
% getWinDurationForAGivenRBW Compute window duration for a given RBW value.
%   This function is for internal use only. It may be removed in the future.

%   Copyright 2015-2019 The MathWorks, Inc.

% If isKaiserBeta is true then the winParam input will be interpreted as
% Kaiser window beta parameter instead of a sidelobe attenuation value. If
% not specified this flag defaults to false. This input is irrelevant if
% win is not 'kaiser'.

% Segment length will depend on ENBW (which in turns depends on segment
% length). Thus, an initial ENBW is obtained using a segment length of
% 1000
%#codegen

if nargin < 5
  isKaiserBeta = false;
end 

ENBW = getENBW(1000, win, winParam, isKaiserBeta);

% Compute segment length
segLen = ceil(ENBW*Fs/desiredRBW);

% Iterate over segment length to minimize
% error between requested RBW and actual RBW:
count = 1;
segLenVect = zeros(100,1);
segLenVect(1) = segLen;
timeRes = 0;
computed_RBW = zeros(99,1);
while(count<100) % protect against very long convergence
  new_segLen = ceil(getENBW(ceil(segLen),win,winParam,isKaiserBeta) * Fs/ desiredRBW);
  err = abs(new_segLen - segLen);
  if (err == 0) % we have converged
    segLen = new_segLen;
    timeRes = segLen/Fs;
    break;
  end
  if ~any(segLenVect(1:count) == new_segLen)
    segLenVect(count+1,1) = new_segLen;
    segLen = new_segLen;
    count = count + 1;
  else
    % We hit a previously computed segment length. The sequence
    % will repeat. Break out and select the segment length that
    % minimizes the error    
    for ind=1:count
      % Get RBW corresponding to segLenVect(ind)
      computed_RBW(ind,1) = getENBW(segLenVect(ind,1),win,winParam,isKaiserBeta) * Fs / segLenVect(ind,1);
    end
    % Select segment length that minimizes absolute error between
    % actual and desired RBW:
    RBWErr = abs(desiredRBW -  computed_RBW(1:count,1));
    [~,ind_min] = min(RBWErr);
    segLen = segLenVect(ind_min,1);
    timeRes = segLen/Fs;
    break;
  end
end

if count == 100  
  coder.internal.error('signal:internal:getWinDurationForAGivenRBW:NoConvergence');
end
 %------------------------------------------------------------------------  
  function ENBW = getENBW(L, Win, winParam, isKaiserBeta)
  % Get window parameters based on a segment length L
  % The optional string argument 'beta' specifies that the value in
  % sideLobeAttn is the beta parameter. This was do to maintain backwards
  % compatibility.
    ENBW = 0; % pre initialize for coder inference
    switch lower(Win)
      case {'rectangular','rectwin'}
        ENBW = 1;
      case 'hann'
        w = hann(L);
        ENBW = (sum(w.^2)/sum(w)^2)*L;    
      case 'hamming'
        w = hamming(L);
        ENBW = (sum(w.^2)/sum(w)^2)*L;    
      case {'flat top', 'flattopwin'}        
        w = flattopwin(L);
        ENBW = (sum(w.^2)/sum(w)^2)*L; 
      case {'chebyshev','chebwin'}
        w = chebwin(L,winParam);
        ENBW = (sum(w.^2)/sum(w)^2)*L;
      case 'kaiser'
        if isKaiserBeta
          % Input winParam is actually kaiser beta
          beta = winParam;
        else
          % Input winParam is truly a sidelobe attenuation value so
          % convert it to beta
          beta = signal.internal.kaiserBeta(winParam);    
        end    
        w = kaiser(L,beta);
        ENBW = (sum(w.^2)/sum(w)^2)*L;
        
    end    
    
    
% LocalWords:  RBW sidelobe ENBW seg chebyshev
