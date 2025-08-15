function h = firceqripoptsframe(PBSlope, isMinPhase, invsinc, C, P)
%FIRCEQRIPOPTSFRAME  Constructor

%   Author(s): Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

% Call the builtin constructor
h = siggui.firceqripoptsframe;

if nargin > 0 , set(h, 'StopbandSlope', PBSlope) ; end
if nargin > 1 , set(h, 'IsMinPhase', isMinPhase) ; end
if nargin > 2 , set(h, 'IsInvSincPassBand', invsinc) ; end
if nargin > 3 , set(h, 'invSincFreqFactor', C) ; end
if nargin > 4 , set(h, 'invSincPower', P) ; end

% Set the tag
settag(h);

% Set the version
set(h, 'Version', 1.0);

% [EOF]
