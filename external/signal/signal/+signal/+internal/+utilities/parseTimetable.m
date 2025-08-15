function [x, t, td] = parseTimetable(xt) %#codegen
%UTILPARSETIMETABLE  Utility function to convert timetable XT to duration
%vector T, data matrix X, original time vector TD
% This function is only for internal use.

%   Copyright 2017-2018 The MathWorks, Inc.

% extract time and data
t = xt.Properties.RowTimes;
td = [];
if nargout > 2
    td = t;
end
if(isa(t,'duration'))
    t = seconds(t);
else
    % convert datetime to duration
    t = t-t(1);
    t = seconds(t);
end
if ~all(varfun(@isnumeric,xt,'OutputFormat','uniform')) 
    error(message('signal:internal:utilities:parseTimetable:notNumericDataTimetable'));
end
x = xt{:,:};
end