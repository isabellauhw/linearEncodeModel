function enable_listener(this, varargin)
%ENABLE_LISTENER   Listener to the enable property.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h = get(this, 'Handles');

set(this, 'Handles', rmfield(h, {'denominator_lbl', 'scalevalues_lbl'}));

sigcontainer_enable_listener(this, varargin{:});

set(this, 'Handles', h);

if strcmpi(this.DenomOrdSource, 'specify')
    enab = this.Enable;
else
    enab = 'Off';
end

setenableprop(h.denominator_lbl, enab);

if strcmpi(this.ScaleVOrdSource, 'specify')
    enab = this.Enable;
else
    enab = 'Off';
end

setenableprop(h.scalevalues_lbl, enab);

% [EOF]
