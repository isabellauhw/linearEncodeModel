function setGUIvals(this, eventData) %#ok
%SETGUIVALS Set the values in the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h = findhandle(this, whichframes(this));

if ~isempty(h)
    
    if strcmpi(this.DesignType, 'normal')
        str = {getString(message('signal:sigtools:fdadesignpanel:TheAttenuationAtCutoff')), getString(message('signal:sigtools:fdadesignpanel:FrequenciesIsFixedAt6DB')), ...
            getString(message('signal:sigtools:fdadesignpanel:halfThePassbandGain'))};
    else
        str = {getString(message('signal:sigtools:fdadesignpanel:Theattenuationatcutoffhalfthepassbandpower'))};
    end
    set(h, 'Comment', str, ...
    	'AllOptions', set(this, 'DesignType'), ...
        'currentSelection', get(this, 'DesignType'));
end

% [EOF]
