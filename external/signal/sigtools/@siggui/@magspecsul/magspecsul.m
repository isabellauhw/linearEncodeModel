function h = magspecsul
%MAGSPECSUL Construct a MAGSPECSUL object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

h = siggui.magspecsul;
settag(h);

% Create the first labelsandvalues
hu = siggui.labelsandvalues;
settag(hu, 'Upper');

% Create the second labelsandvalues
hl = siggui.labelsandvalues;
settag(hl, 'Lower');

addcomponent(h, [hu hl]);

% [EOF]
