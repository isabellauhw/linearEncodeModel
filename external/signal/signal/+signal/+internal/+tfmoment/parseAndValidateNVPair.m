function opts = parseAndValidateNVPair(opts, defaultTimeRange,defaultFrequencyRange,nvpair)
%PARSEANDVALIDATENVPAIR parse and validate the name-value pair for
%TFSMOMENT, TFTMOMENT and TFMOMENT functions.

%   This function is for internal use only. It may be removed. 

%   Copyright 2017 The MathWorks, Inc.

p=inputParser;
switch opts.MomentType   
    case 'tfsmoment'
        addParameter(p,'FrequencyLimits',defaultFrequencyRange);
        defaultIsCentral = true;        
    case 'tftmoment'       
        addParameter(p,'TimeLimits',defaultTimeRange);
        defaultIsCentral = true;        
    case 'tfmoment'
        addParameter(p,'FrequencyLimits',defaultFrequencyRange);
        addParameter(p,'TimeLimits',defaultTimeRange);
        defaultIsCentral = false;
end

addParameter(p,'Centralize',defaultIsCentral);
parse(p,nvpair{:});

switch opts.MomentType
    case 'tfsmoment'
        FrequencyRange=p.Results.FrequencyLimits;
        validateattributes(FrequencyRange, {'single','double'},...
            {'nonnan','real','vector','nondecreasing',...
            '>=',defaultFrequencyRange(1),'<=',defaultFrequencyRange(2),'numel',2},...
            opts.MomentType,'FrequencyLimits');
        opts.FrequencyRange = FrequencyRange;       
    case 'tftmoment'
        TimeRange=p.Results.TimeLimits;        
        opts.TimeRange = signal.internal.utilities.validateTimeRange(TimeRange, defaultTimeRange, opts.MomentType);        
    case 'tfmoment'
        TimeRange=p.Results.TimeLimits;
        TimeRange=signal.internal.utilities.validateTimeRange(TimeRange, defaultTimeRange, opts.MomentType);
        FrequencyRange=p.Results.FrequencyLimits;
        validateattributes(FrequencyRange, {'single','double'},...
            {'nonnan','real','vector','nondecreasing',...
            '>=',defaultFrequencyRange(1),'<=',defaultFrequencyRange(2),'numel',2},...
            opts.MomentType,'FrequencyLimits');
        opts.FrequencyRange = FrequencyRange;
        opts.TimeRange = TimeRange;
end

IsCentral=p.Results.Centralize;
validateattributes(IsCentral, {'single','double','logical'},{'scalar','nonempty'},opts.MomentType,'Centralize');
if IsCentral~=0 && IsCentral~=1
    error(message('signal:tfmoment:invalidLogicalValue','Centralize','0/1/true/false'));
end
opts.IsCentral = IsCentral;
