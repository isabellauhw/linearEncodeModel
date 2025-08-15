function CM = callCountCycles(x,idx,isInMATLAB)
%CALLCOUNTCYCLES  Call callCountCycles in MATLAB and codegen
% This function is for internal use only. It may be removed. 

%   Copyright 2017 The MathWorks, Inc.

%#ok<*EMCLS>
%#ok<*EMCA>
%#codegen

if isInMATLAB
     % Call mex function, which is generated from 'signal.internal.rainflow.countCycles.m'.
    if isa(x,'single')
      CM = signal.internal.rainflow.rainflowmxs('countCycles',x(idx));
    else
      CM = signal.internal.rainflow.rainflowmx('countCycles',x(idx));
    end
else
  CM = signal.internal.rainflow.countCycles(x(idx));
end