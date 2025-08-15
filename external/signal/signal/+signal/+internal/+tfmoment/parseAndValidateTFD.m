function opts = parseAndValidateTFD(opts,x,RequiredInputLen,varargin)
%PARSEANDVALIDATETFD parse and validate the spectrum for TFSMOMENT,
%TFTMOMENT, TFMOMENT.

%   This function is for internal use only. It may be removed. 

%   Copyright 2017 The MathWorks, Inc. 

opts.InputType = 'Spectrum';

validateattributes(x, {'single','double'},...
    {'nonempty','nonnan','finite','real','nonnegative','2d'},opts.MomentType,'P');
opts.Data = x;

F = varargin{1};
validateattributes(F, {'single','double'},{'nonempty','nonnan','finite','real',...
    'nonnegative','increasing','vector'},opts.MomentType,'F');
len = size(x,1);
if length(F) ~= len
    error(message('signal:tfmoment:FrequencyNotMatch'));
end
opts.Frequency = F;

TimeInfo = varargin{2};
validateattributes(TimeInfo,{'double','single','duration','datetime'},...
    {'vector','nonempty','real'},opts.MomentType,getString(message('signal:tfmoment:TimeValues')));
len = size(x,2);
if (~isscalar(TimeInfo))||(len==1)
    if length(TimeInfo) ~= len
        error(message('signal:tfmoment:TimeNotMatch'));
    end
else
    % It must be Ts as a dutation instead of Fs as single/double
    if isa(TimeInfo,'double')||isa(TimeInfo,'single')
        error(message('signal:tfmoment:TimeNotMatch'));
    end
end
[t, td]= signal.internal.tfmoment.parseTime(TimeInfo,len,opts.MomentType); 
% validateattributes(t, {'single','double'},{'nonempty','nonnan','finite','nonnegative','increasing',...
%     'vector','real','vector'},opts.MomentType,getString(message('signal:tfmoment:TimeValues')));
opts.Time = t;

opts.Order = signal.internal.tfmoment.validateOrder(varargin{3}, opts.MomentType);

if RequiredInputLen == numel(varargin)
    nvpair = {};
else
    nvpair = {varargin{RequiredInputLen+1:end}};
end

switch opts.MomentType    
    case 'tfsmoment'
        defaultFrequencyRange = [F(1),F(end)];
        opts = signal.internal.tfmoment.parseAndValidateNVPair(opts,[],defaultFrequencyRange,nvpair);        
    case 'tftmoment'
        defaultTimeRange = [td(1),td(end)];
        opts = signal.internal.tfmoment.parseAndValidateNVPair(opts,defaultTimeRange,[],nvpair);              
    case 'tfmoment'
        defaultTimeRange = [td(1),td(end)];
        defaultFrequencyRange = [F(1),F(end)];
        opts = signal.internal.tfmoment.parseAndValidateNVPair(opts,defaultTimeRange, defaultFrequencyRange,nvpair);       
end

end