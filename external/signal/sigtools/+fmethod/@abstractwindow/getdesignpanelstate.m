function s = getdesignpanelstate(this)
%GETDESIGNPANELSTATE   Get the designpanelstate.

%   Copyright 1999-2015 The MathWorks, Inc.

s.DesignMethod  = 'filtdes.fir1';

s.Components{1}.Tag = 'siggui.firwinoptionsframe';
if this.ScalePassband
    s.Scale         = 'On';
else
    s.Scale         = 'Off';
end

% [EOF]
