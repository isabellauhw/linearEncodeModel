function this = textfreqspecs
%FREQSPECS is the constructor for the freqspecs object
%   FREQSPECS(UNITS, FS, Lbls, Values, Name)
%   UNITS   -   The default units for the units popup
%   FS      -   The sampling frequency
%   TEXT    -   The text to display under the freq specs
%   Name    -   The frame name (optional)

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.

narginchk(0,5);

% Built in constructor call
this = siggui.textfreqspecs;

% Create the FSSpecifier object and store it's handle
% We use FSspecifier's default constructor for now.
fsh = siggui.specsfsspecifier;
addcomponent(this, fsh);

settag(this);

% [EOF]
