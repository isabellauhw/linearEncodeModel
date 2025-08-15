function reorderinputs = getreorderinputs(this)
%GETREORDERINPUTS   Returns the reorderinputs as a cell array.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

reorderinputs = {get(this, 'ReorderType')};

if strcmpi(reorderinputs{1}, 'custom')
    hc = getcomponent(this, 'custom');
    reorderinputs = getreorderinputs(hc);
end

% [EOF]
