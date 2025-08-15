function setcurrentvalue(hObj, cv)
%SETCURRENTVALUE Set the value of the current pole/zero

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

hc = get(hObj, 'CurrentRoots');

if isempty(hc)
    warning(message('signal:siggui:pzeditor:setcurrentvalue:noPoleZeroSelected'));
else
    setvalue(hc, cv);
end

% [EOF]
