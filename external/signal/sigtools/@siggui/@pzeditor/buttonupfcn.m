function buttonupfcn(this)
%BUTTONUPFCN Function that is called when the button is released

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

if ~strcmpi(get(this, 'ButtonClickType'), 'Left'), return; end

% Make sure the limits are updated. 
% Don't update the limits when moving poles and zeros (see g1357482).
if ~strcmpi(get(this, 'Action'), 'Move Pole/Zero') 
  updatelimits(this);
end

send(this, 'NewFilter', handle.EventData(this, 'NewFilter'));

% [EOF]
