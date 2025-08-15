function siggui_setstate(hObj,s)
%SIGGUI_SETSTATE Set the state of the object

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

if isfield(s, 'Tag'),  s = rmfield(s, 'Tag'); end
if isfield(s, 'Version'),  s = rmfield(s, 'Version'); end

if ~isempty(s)
    set(hObj, s);
end

% [EOF]
