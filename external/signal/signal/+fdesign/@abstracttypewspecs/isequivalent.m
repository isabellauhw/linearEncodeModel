function b = isequivalent(this, htest)
%ISEQUIVALENT   True if the object is equivalent.

%   Copyright 2005 The MathWorks, Inc.

[lastmsg, lastid] = lastwarn;
S = warning('off','MATLAB:structOnObject');
cleanObj = onCleanup(@() wCleanup(S,lastmsg,lastid));

if isa(htest, class(this)) && ...
        strcmpi(this.SpecificationType, htest.Specification)
    b = isequal(struct(this.CurrentSpecs), struct(htest.CurrentSpecs));
else
    b = false;
end

end

function [] = wCleanup(S,lastmsg,lastid)
  warning(S);
  lastwarn(lastmsg, lastid);
end
% [EOF]
