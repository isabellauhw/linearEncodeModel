function opts = parseAndValidateTimeTable(opts,x,varargin)
%PARSEANDVALIDATETIMETABLE parse and validate the time table for TFSMOMENT,
%TFTMOMENT, TFMOMENT.

%   This function is for internal use only. It may be removed. 

%   Copyright 2017 The MathWorks, Inc. 

if (height(x) < 2)
    error(message('signal:tfmoment:InvalidInputLength'));
end

% Parse x values and time values
signal.internal.utilities.validateattributesTimetable(x,...
    {'sorted','singlechannel'},opts.MomentType,'XT');  % opts.MomentType is function name
[xval, tval, t] = signal.internal.utilities.parseTimetable(x);
validateattributes(tval, {'single','double'}, {'nonempty','nonnan','finite','real'},...
    opts.MomentType,...
    [getString(message('signal:utilities:utilities:timeValuesOfTT')) ' XT']);
validateattributes(xval, {'single','double'}, {'nonempty','nonnan','finite','real'},...
    opts.MomentType,'XT{:,:}');
opts.Data = x;

% Parse Order
opts.Order = signal.internal.tfmoment.validateOrder(varargin{1},opts.MomentType);

% Parse NV pair
nvpair = {varargin{2:end}};
switch opts.MomentType    
    case 'tfsmoment'
        Fs = signal.internal.utilities.computeFs(t, opts.MomentType);
        defaultFrequencyRange = [0,Fs/2];
        opts = signal.internal.tfmoment.parseAndValidateNVPair(opts, [],defaultFrequencyRange, nvpair);
    case 'tftmoment'
        defaultTimeRange = [t(1),t(end)];
        opts = signal.internal.tfmoment.parseAndValidateNVPair(opts, defaultTimeRange,[], nvpair);               
    case 'tfmoment'
        defaultTimeRange = [t(1),t(end)];
        Fs = signal.internal.utilities.computeFs(t, opts.MomentType);
        defaultFrequencyRange = [0,Fs/2];
        opts = signal.internal.tfmoment.parseAndValidateNVPair(opts, defaultTimeRange, defaultFrequencyRange,nvpair);       
end

end