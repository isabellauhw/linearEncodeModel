function opts = parseAndValidateSignalVec(opts,x,RequiredInputLen,varargin)
%PARSEANDVALIDATESIGNALVEC parse and validate the signal vector for TFSMOMENT,
%TFTMOMENT, TFMOMENT.

%   This function is for internal use only. It may be removed. 

%   Copyright 2017 The MathWorks, Inc. 


opts.InputType = 'Signal';

if (length(x) < 2)
    error(message('signal:tfmoment:InvalidInputLength'));
end
validateattributes(x, {'single','double'},{'nonempty','nonnan','finite','real','2d'},opts.MomentType,'X');
opts.Data = x(:);

TimeInfo = varargin{1};
validateattributes(TimeInfo,{'double','single','duration','datetime'},...
    {'vector','real','nonempty'},opts.MomentType,getString(message('signal:tfmoment:TimeValues')));
len = length(x);
if (~isscalar(TimeInfo))
    if length(TimeInfo) ~= len
        error(message('signal:tfmoment:TimeNotMatch'));
    end
end
opts.TimeInfo = TimeInfo;

opts.Order = signal.internal.tfmoment.validateOrder(varargin{2}, opts.MomentType);

% Parse name-value pairs
if RequiredInputLen == numel(varargin)
    nvpair = {};
else
    nvpair = {varargin{RequiredInputLen+1:end}};
end

switch opts.MomentType   
    case 'tfsmoment'
        Fs = signal.internal.utilities.computeFs(TimeInfo, opts.MomentType);
        defaultFrequencyRange = [0,Fs/2];
        opts = signal.internal.tfmoment.parseAndValidateNVPair(opts,[],defaultFrequencyRange, nvpair);      
    case 'tftmoment'
        [~,td]= signal.internal.tfmoment.parseTime(TimeInfo,length(x),opts.MomentType); 
        defaultTimeRange = [td(1),td(end)];
        opts = signal.internal.tfmoment.parseAndValidateNVPair(opts,defaultTimeRange,[],nvpair);       
    case 'tfmoment'
        Fs = signal.internal.utilities.computeFs(TimeInfo,opts.MomentType);
        defaultFrequencyRange = [0,Fs/2];
        [~,td]= signal.internal.tfmoment.parseTime(TimeInfo,length(x),opts.MomentType); 
        defaultTimeRange = [td(1),td(end)];
        opts = signal.internal.tfmoment.parseAndValidateNVPair(opts, defaultTimeRange,defaultFrequencyRange, nvpair);       
end

end