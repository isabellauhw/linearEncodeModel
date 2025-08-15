function this = freqspecswbw
%FREQSPECSWBW Construct a FREQSPECSWBW object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

this = siggui.freqspecswbw;

construct_ff(this);

addcomponent(this, siggui.selectorwvalues('', ...
    {'bandwidth','nonbw'},{'Bandwidth',this.nonBWLabel}, this.TransitionMode, ...
    {this.BandWidth, this.nonBW}));
addcomponent(this, siggui.labelsandvalues);

settag(this);
set(this, 'Labels', {'Fc'}, ...
    'Values', {'9600'}, ...
    'nonBWLabel', 'Rolloff', ...
    'Bandwidth', '1200', ...
    'nonBW', '.04');

% [EOF]
