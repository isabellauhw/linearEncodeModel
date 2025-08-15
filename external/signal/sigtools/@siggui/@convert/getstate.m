function state = getstate(hConvert)
%GETSTATE Returns the current state of the Convert Dialog
%   GETSTATE(hConvert) Returns the current state of the Convert Dialog.  This
%   state is the information necessary to recreate the current Convert Dialog.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

state.struct = get(hConvert,'TargetStructure');
state.filter = get(hConvert,'ReferenceFilter');

% [EOF]
