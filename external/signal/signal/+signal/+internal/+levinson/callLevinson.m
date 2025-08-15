function [A,E,K] = callLevinson(R,N,temp_cols,isInputComplex,...
    isInputSingle,isInMATLAB)
% callLevinson is called by levinson in MATLAB and codegen paths
% This function is for internal use only. It may be removed. 

%   Copyright 2019 The MathWorks, Inc.

%#codegen

if isInMATLAB
    if isInputSingle
        if isInputComplex
            [A,E,K] = signal.internal.levinson.levinsonmxcs(R,N,temp_cols);
        else
            [A,E,K] = signal.internal.levinson.levinsonmxs(R,N,temp_cols);
        end
    else
        if isInputComplex
            [A,E,K] = signal.internal.levinson.levinsonmxcd(R,N,temp_cols);
        else
            [A,E,K] = signal.internal.levinson.levinsonmxd(R,N,temp_cols);
        end
    end
else
    [A,E,K] = signal.internal.levinson.levinsonImpl(R,N,temp_cols);
end

end