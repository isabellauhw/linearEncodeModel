function s = eqrip_getdesignpanelstate(this)
%EQRIP_GETDESIGNPANELSTATE   

%   Copyright 1999-2015 The MathWorks, Inc.

s.DesignMethod                = 'filtdes.remez';
s.Components{1}.Tag           = 'siggui.remezoptionsframe';
s.Components{1}.DensityFactor = sprintf('%g', this.DensityFactor);

% [EOF]
