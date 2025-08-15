function impRespType = selectImpulseResponse(NreqFir, opts)
% SELECTIMPULSERESPONSE Determine impulse response to be used in the design
% based on required filter order and input signal length
% 
% impRespType can be 'fir' or 'iir'

%   Copyright 2017 MathWorks, Inc.

%   This function is for internal use only. It may be removed.

impRespType = 'fir';
if strcmp(opts.ImpulseResponse,'auto') 
    if (opts.SignalLength <= 2*NreqFir)
        impRespType = 'iir';
    end
elseif strcmp(opts.ImpulseResponse,'fir') 
    if (opts.SignalLength <= 2*NreqFir)
        error(message('signal:internal:filteringfcns:SignalLengthForFIR',num2str(NreqFir)));        
    end
elseif strcmp(opts.ImpulseResponse,'iir') 
    impRespType = 'iir';
end
end

