function siggui_setstate(hObj,s)
%SIGGUI_SETSTATE Set the state of the object

%   Copyright 2011-2017 The MathWorks, Inc.

narginchk(2,2);

if isfield(s, 'Tag'),  s = rmfield(s, 'Tag'); end
if isfield(s, 'Version'),  s = rmfield(s, 'Version'); end
if isfield(s, 'xp2wksp'), s = rmfield(s,'xp2wksp'); end

if ~isempty(s)
    set(hObj, s);
end

% [EOF]
