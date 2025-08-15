function TimeRangeOut = validateTimeRange(TimeRange, defaultTimeRange, funcNameStr)
%VALIDATETIMERANGE validate the time range and return the valid time range
%in double vector.
% The valid type of time range is determined by the defaultTimeRange, which
% is decided by the input time information, as shown below:
%
%      defaultTimeRange        |              TimeRange     
% -----------------------------------------------------------------------
%        single/double         |        single/double/duration
%         duration             |        single/double/duration
%         datetime             |     single/double/duration/datetime
%

%   Copyright 2017-2020 The MathWorks, Inc.
%#codegen

varName = 'TimeLimits';

switch class(defaultTimeRange)
    case {'single', 'double'}
        validateattributes(TimeRange, {'single','double','duration'}, ...
            {'vector','numel',2}, funcNameStr, varName);
        if isduration(TimeRange)
            defaultTimeRangeTransform = seconds(defaultTimeRange);
            TimeRangeOut = seconds(TimeRange);
        else
            defaultTimeRangeTransform = defaultTimeRange;
            TimeRangeOut = TimeRange;
        end
    case 'duration'
        validateattributes(TimeRange, {'single','double','duration'}, ...
            {'vector','numel',2}, funcNameStr, varName);
        
        if isduration(TimeRange)
            defaultTimeRangeTransform = defaultTimeRange;
            TimeRangeOut = seconds(TimeRange);
        else
            defaultTimeRangeTransform = seconds(defaultTimeRange);
            TimeRangeOut = TimeRange;
        end
        
    case 'datetime'
        validateattributes(TimeRange, {'datetime','single','double','duration'}, ...
            {'vector','numel',2},funcNameStr,varName);
        if isa(TimeRange,'single')||isa(TimeRange,'double')
            defaultTimeRangeTransform = seconds(defaultTimeRange - defaultTimeRange(1));
            TimeRangeOut = TimeRange;
        elseif isa(TimeRange,'duration')
            defaultTimeRangeTransform = defaultTimeRange - defaultTimeRange(1);
            TimeRangeOut = seconds(TimeRange);
        else
            defaultTimeRangeTransform = defaultTimeRange;
            TimeRangeOut = seconds(TimeRange - defaultTimeRange(1));
        end    
end

coder.internal.errorIf(TimeRange(1) > defaultTimeRangeTransform(2) || TimeRange(2) < defaultTimeRangeTransform(1), ...
    'signal:utilities:utilities:InvalidTimeLimits',...
        varName, string(defaultTimeRangeTransform(1)),string(defaultTimeRangeTransform(2)));
    
validateattributes(TimeRangeOut, {'single','double'},...
            {'nonnan','finite','real','nondecreasing'},...
            funcNameStr, varName);
end
