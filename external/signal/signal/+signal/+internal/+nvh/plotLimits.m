function lim = plotLimits(lim)
%PLOTLIMITS Convenience plot limits
%   This function is for internal use only. It may be removed. 

%   Copyright 2017 The MathWorks, Inc.

% Define factor as a fraction of the lower limit
factor = 1e-4*lim(1);

% Update plot limits to give a margin and increase limits if needed
if abs(diff(lim))<2*factor
  lim(2) = lim(2) + factor;
  lim(1) = lim(1) - factor;
else
  lim = [-.1 .1]*abs(diff(lim))+lim;
end
  
end