function success = action(this)
%ACTION   Perform the action of the dialog.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

success = true;

this.isScaling = true;

try
    % Perform reordering and scaling operations.
    Hd = reorderandscale(this);

    % Generate MCODE first in case resetting the filter resets the settings.
    data.mcode  = genmcode(this);

    this.Filter = Hd;

    data.filter = Hd;

    send(this, 'NewFilter', ...
        sigdatatypes.sigeventdata(this, 'NewFilter', data));
catch ME %#ok<NASGU>
    success = false;
end

this.isScaling = false;

% [EOF]
