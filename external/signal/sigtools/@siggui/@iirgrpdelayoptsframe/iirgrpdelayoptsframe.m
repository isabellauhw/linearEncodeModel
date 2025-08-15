function h = iirgrpdelayoptsframe(varargin)
%IIRGRPDELAYOPTSFRAME  Constructor for the options frame
%
%   DENSITYFACTOR   -   Value for the density factor
%   MAXPOLERADIUS   -   Value for Max Pole Radius
%   INITDEN         -   Initial guess at denominator
%   NAME            -   Name

%   Author(s): Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

%  Builtin-in constructor
h = siggui.iirgrpdelayoptsframe;

% Set the version and tag
set(h, 'Version', 1.0);
set(h, 'MaxPoleRadius', '.99');
settag(h);

% [EOF]
