function s = getdesignpanelstate(this)
%GETDESIGNPANELSTATE   Get the designpanelstate.

%   Copyright 1999-2015 The MathWorks, Inc.

s.DesignMethod               = 'filtdes.butter';
s.Components{1}.Tag          = 'siggui.classiciiroptsframe';
s.Components{1}.MatchExactly = this.MatchExactly;

% [EOF]
