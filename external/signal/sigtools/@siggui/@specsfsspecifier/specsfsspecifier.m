function h = specsfsspecifier(defaultUnits, defaultFs)
%SPECSFSSPECIFIER Custom fsspecifier for specs frames

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.

narginchk(0,2);

% Call builtin constructor
h = siggui.specsfsspecifier;

% Determine list of all possible units
allUnits = set(h, 'Units');

if nargin < 1 , defaultUnits = allUnits{2}; end
if nargin < 2 , defaultFs    = '48000';     end

% Set the defaults
set(h, 'Version', 1.0);
set(h, 'Units', defaultUnits);
set(h, 'Value', defaultFs);

settag(h);

% [EOF]
