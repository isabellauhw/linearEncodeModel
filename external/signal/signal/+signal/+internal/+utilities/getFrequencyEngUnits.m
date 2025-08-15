function [newValue, scaleFactor, unitsStr] = getFrequencyEngUnits(value)
%GETFREQUENCYENGUNITS helper function to get frequency engineering units
% This function is only for internal use

%   Copyright 2017 The MathWorks, Inc.
if (value == 0)
    scaleFactor = 1;
    unitsStr = 'Hz';
elseif (value < 1 / (60 * 60 * 24 * 365))
    scaleFactor = 60 * 60 * 24 * 365;
    unitsStr = getString(message('signal:utilities:utilities:CyclesPerYear'));
elseif (value < 1 / (60 * 60 * 24))
    scaleFactor = 60 * 60 * 24;
    unitsStr = getString(message('signal:utilities:utilities:CyclesPerDay'));
elseif (value < 1 / (60 * 60))
    scaleFactor = 60 * 60;
    unitsStr = getString(message('signal:utilities:utilities:CyclesPerHour'));
elseif (value < 1 / (60))
    scaleFactor = 60;
    unitsStr = getString(message('signal:utilities:utilities:CyclesPerMinute'));
elseif (value < 1)
    scaleFactor = 1000;
    unitsStr = 'mHz';
elseif (value < 1000)
    scaleFactor = 1;
    unitsStr = 'Hz';
elseif (value < 1000 * 1000)
    scaleFactor = 1 / 1000;
    unitsStr = 'kHz';
elseif (value < (1000 * 1000 * 1000))
    scaleFactor = 1 / (1000 * 1000);
    unitsStr = 'MHz';
elseif (value < (1000 * 1000 * 1000 * 1000))
    scaleFactor = 1 / (1000 * 1000 * 1000);
    unitsStr = 'GHz';
else
    scaleFactor = 1 / (1000 * 1000 * 1000 * 1000);
    unitsStr = 'THz';
end

newValue = value*scaleFactor;