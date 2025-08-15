function opts = parseAndValidateInputs(funcNameStr,x,varargin)
%PARSEANDVALIDATEINPTES parse and validate inputs for TFSMOMENT, TFTMOMENT
%and TFMOMENT functions.
%
%	X is a time table   	
%       - tfsmoment(TT, order, 'IsCentral', true/false, 'FrequencyRange', [f1, f2])
%       - tftmoment(TT, order, 'IsCentral', true/false, 'TimeRange', [t1, t2])
%       - tfmoment(TT, order, 'IsCentral', true/false, 'TimeRange', [t1, t2],'FrequencyRange', [f1, f2])
%
%   X is a signal vector    
%       - tfsmoment(s, Fs, order, 'IsCentral', true/false, 'FrequencyRange', [f1, f2])
%       - tfsmoment(s, Ts, order, 'IsCentral', true/false, 'FrequencyRange', [f1, f2])
%       - tfsmoment(s, Tv, order, 'IsCentral', true/false, 'FrequencyRange', [f1, f2])
%       - tftmoment(s, Fs, order, 'IsCentral', true/false, 'TimeRange', [t1, t2])
%       - tftmoment(s, Ts, order, 'IsCentral', true/false, 'TimeRange', [t1, t2])
%       - tftmoment(s, Tv, order, 'IsCentral', true/false, 'TimeRange', [t1, t2])
%       - tfmoment(s, Fs, 'IsCentral', true/false, 'TimeRange', [t1, t2],'FrequencyRange', [f1, f2])
%       - tfmoment(s, Ts, 'IsCentral', true/false, 'TimeRange', [t1, t2],'FrequencyRange', [f1, f2])
%       - tfmoment(s, Tv, 'IsCentral', true/false, 'TimeRange', [t1, t2],'FrequencyRange', [f1, f2])
%
%   X is time-frequency distribution    
%       - tfsmoment(P, Ts, order, 'IsCentral', true/false, 'FrequencyRange', [f1, f2])
%       - tfsmoment(P, Tv, order, 'IsCentral', true/false, 'FrequencyRange', [f1, f2]) 
%       - tftmoment(P, Ts, order, 'IsCentral', true/false, 'TimeRange', [t1, t2])
%       - tftmoment(P, Tv, order, 'IsCentral', true/false, 'TimeRange', [t1, t2])  
%       - tfmoment(P, Ts, 'IsCentral', true/false, 'TimeRange', [t1, t2],'FrequencyRange', [f1, f2])
%       - tfmoment(P, Tv, 'IsCentral', true/false, 'TimeRange', [t1, t2],'FrequencyRange', [f1, f2])    
%

%   This function is for internal use only. It may be removed. 

%   Copyright 2017 The MathWorks, Inc. 

opts = struct(...
    'Data',[],...
    'SamplingFrequency',[],...
    'Time',[],...
    'TimeInfo',[],...
    'Frequency',[],...
    'Order',[],...
    'IsCentral',true,...
    'FrequencyRange',[],...
    'TimeRange',[],...
    'IsTimeTable',istimetable(x),...
    'InputType','Signal',...
    'MomentType',funcNameStr);

if opts.IsTimeTable
    opts = signal.internal.tfmoment.parseAndValidateTimeTable(opts,x,varargin{:});
else
    % Determine if it is a signal vector or a time-frequency distribution
    % based on the number of inputs which are not name-value pair. 
    RequiredVararginLen = signal.internal.tfmoment.numOfRequiredInput(varargin{:});
    if RequiredVararginLen < 2
        error(message('signal:tfmoment:notEnoughInputArg'));
    elseif RequiredVararginLen < 3
        opts = signal.internal.tfmoment.parseAndValidateSignalVec(opts,x,RequiredVararginLen,varargin{:});
    else
        opts = signal.internal.tfmoment.parseAndValidateTFD(opts,x,RequiredVararginLen,varargin{:});
    end
end

end