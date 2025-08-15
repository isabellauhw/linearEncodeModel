function isUSFlag = isUniformlySpaced(tVec)
% ISUNIFORMLYSPACED checks if the time values in TVEC are uniformly spaced
% by comparing them to a line. TVEC values can be in seconds, durations or
% datetime.

% Copyright 2017 The MathWorks, Inc.

if isdatetime(tVec) || isduration(tVec)
  tVec = seconds(tVec);
end

% TESTUTVEC contains uniformly spaced time samples between the first and
% last time instances in the input TVEC. TESTUTVEC has the same size as
% TVEC.
tVec = tVec(:);
testUTVec = linspace(tVec(1),tVec(end),length(tVec))'; 
isUSFlag = (max(abs(tVec-testUTVec)./max(abs(tVec),[],1),[],1)<3*eps(class(tVec)));

end

% [EOF]