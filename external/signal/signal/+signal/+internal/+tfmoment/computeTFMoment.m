function [moment,TF] = computeTFMoment(opts)
%COMPUTETFMOMENT compute the time-frequency moment.

%   This function is for internal use only. It may be removed. 

%   Copyright 2017 The MathWorks, Inc. 

if strcmp(opts.InputType,'Signal')   
    if opts.IsTimeTable
        try
            [P,F,T] = pspectrum(opts.Data,'spectrogram'); 
        catch e
            throw(e)
        end
        if ~strcmp(opts.MomentType, 'tfsmoment')
            T = signal.internal.tfmoment.TimeVec2Double(T); 
        end
    else
        TimeInfo = opts.TimeInfo;
        try
            [P,F,T] = pspectrum(opts.Data,TimeInfo,'spectrogram');
        catch e
            throw(e)
        end
        if ~strcmp(opts.MomentType, 'tfsmoment')
            T = signal.internal.tfmoment.TimeVec2Double(T); 
        end
    end
else
    F = opts.Frequency;
    T = opts.Time;
    P = opts.Data;
end

order = opts.Order;
IsCentral = opts.IsCentral;

switch opts.MomentType
    case 'tfsmoment'
        FrequencyRange = opts.FrequencyRange;
        moment = signal.internal.tfmoment.tfsmomentCompute(P,F,order,IsCentral,FrequencyRange);
        TF = T;
    case 'tftmoment'
        TimeRange = opts.TimeRange;
        moment = signal.internal.tfmoment.tftmomentCompute(P,T,order,IsCentral,TimeRange);
        TF = F;
    case 'tfmoment'
        FrequencyRange = opts.FrequencyRange;
        TimeRange = opts.TimeRange;
        moment = signal.internal.tfmoment.tfmomentCompute(P,T,F,order,IsCentral,TimeRange,FrequencyRange);        
end

end