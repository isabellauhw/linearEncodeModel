function disableparameter(hDlg, tag)
%DISABLEPARAMETER Disable a parameter by it's tag

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

if ~ischar(tag)
    error(message('signal:siggui:parameterdlg:disableparameter:MustBeAString'));
end

tags = get(hDlg.Parameter, 'Tag');

indx = find(strcmpi(tag, tags), 1);

if isempty(indx)
    error(message('signal:siggui:parameterdlg:disableparameter:NotSupported'));
end

dparams = get(hDlg, 'DisabledParameters');

% Only use store the string if it is not already in the vector.
if isempty(find(strcmpi(tag, dparams), 1))
    dparams = {dparams{:}, tag};
end

set(hDlg, 'DisabledParameters', dparams);

% [EOF]
