function s = getdesignpanelstate(this)
%GETDESIGNPANELSTATE Get the designpanelstate.

%   Copyright 1999-2015 The MathWorks, Inc.

s = eqrip_getdesignpanelstate(this);

s.Components{2}.Tag    = 'fdadesignpanel.hpweight';
s.Components{2}.Wpass1 = sprintf('%g', this.Wpass1);
s.Components{2}.Wstop  = sprintf('%g', this.Wstop);
s.Components{2}.Wpass2 = sprintf('%g', this.Wpass2);

% [EOF]
