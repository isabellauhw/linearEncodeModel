function this = gridlayout(varargin)
%GRIDLAYOUT   Construct a GRIDLAYOUT object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

% Call the default constructor.
this = siglayout.gridlayout;

abstractlayout_construct(this, varargin{:});

l = [ ...
        handle.listener(this, [this.findprop('Grid') this.findprop('VerticalGap') ...
        this.findprop('HorizontalGap')], 'PropertyPostSet', @lclupdate); ...
    ];
set(l, 'CallbackTarget', this);
set(this, 'UpdateListener', l);

% ----------------------------------------------------------
function lclupdate(this, eventData)

set(this, 'Invalid', true);

update(this);

% [EOF]
