function [dt,units,timeScale] = getFSSTDurationAndUnits(Ts)
%GETFSSTDURATIONANDUNITS Returns the sampling interval and units format string
% The Units string is only for plotting.
% This function is for internal use only. It may be removed.

%   Copyright 2020 The MathWorks, Inc.
%#codegen

tsformat = Ts.Format;
% Use first character of format string to determine correct
% duration object method.
tsformat = tsformat(1);
% Using the same time units as engunits. Units in engunits are
% not localized.
% time_units = {'secs','mins','hrs','days','years'};
switch tsformat
    case 's'
        dt = seconds(Ts);
        units = 'sec';
        timeScale = 1;
    case 'm'
        dt = minutes(Ts);
        units = 'min';
        timeScale = 1/seconds(minutes(1));
    case 'h'
        dt = hours(Ts);
        units = 'hr';
        timeScale = 1/seconds(hours(1));
    case 'd'
        dt = days(Ts);
        units = 'day';
        timeScale = 1/seconds(days(1));
    case 'y'
        dt = years(Ts);
        units = 'year';
        timeScale = 1/seconds(years(1));
end
end
