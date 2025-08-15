function s = getdesignpanelstate(this)
%GETDESIGNPANELSTATE   Get the designpanelstate.

%   Copyright 1999-2015 The MathWorks, Inc.

s = eqrip_getdesignpanelstate(this);

s.Components{2}.Tag   = 'fdadesignpanel.lpweight';
s.Components{2}.Wpass = sprintf('%g', this.Wpass);
s.Components{2}.Wstop = sprintf('%g', this.Wstop);

% [EOF]
