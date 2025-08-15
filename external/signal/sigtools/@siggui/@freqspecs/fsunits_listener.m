function fsunits_listener(h, eventData)
%FSUNITS_LISTENER Listens to the fsspecifier units property for autoupdating

%   Author(s): Z. Mecklai
%   Copyright 1988-2017 The MathWorks, Inc.

if strcmpi(get(eventData, 'NewValue'), 'normalized (0 to 1)')
    fc = 'w';
else
    fc = 'F';
end

lbls = get(h, 'Labels');

for i = 1:length(lbls)
    lbls{i}(1) = fc;
end

set(h, 'Labels', lbls);

% Only do this if auto updating is turned on
if strcmpi(get(h, 'autoupdate'), 'on')
    
    fsh = getcomponent(h, 'siggui.specsfsspecifier');
    % fsh = get(h,'fshandle');

    % Determine the sampling frequency
    fs = get(fsh, 'Value');
    
    % Get the original, new and all valid units
    origin = get(fsh, 'Units');
    target = get(eventData, 'NewValue');
    allUnits = set(fsh, 'Units');
    
    % Get the specification values
    values = get(h,'Values');
    
    % Convert the values
    newvalues = convertfrequnits(values, fs, origin, target, allUnits);
   
    % Set the new values
    set(h, 'Values', newvalues);
    
end

% [EOF]
