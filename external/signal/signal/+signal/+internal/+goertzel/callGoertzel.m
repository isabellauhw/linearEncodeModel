function y = callGoertzel(data,freqIndices,isInputComplex,isInputSingle,isInMATLAB)
%CALLGOERTZEL Call Goertzel in MATLAB and codegen
% This function is for internal use only. It may be removed. 

%   Copyright 2018 The MathWorks, Inc.
%#codegen

if isInputSingle
    outExample = single(1i);
else
    outExample = 1i;
end

if isInMATLAB
    if isInputSingle
        if isInputComplex
            y = signal.internal.goertzel.goertzelmxcs(data,freqIndices,isInputComplex,outExample);
        else
            y = signal.internal.goertzel.goertzelmxs(data,freqIndices,isInputComplex,outExample);
        end
    else
        if isInputComplex
            y = signal.internal.goertzel.goertzelmxc(data,freqIndices,isInputComplex,outExample);
        else
            y = signal.internal.goertzel.goertzelmx(data,freqIndices,isInputComplex,outExample);
        end
    end
else
    y = signal.internal.goertzel.goertzelImpl(data,freqIndices,isInputComplex,outExample);
end

end

