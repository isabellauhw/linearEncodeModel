function idx = callFindExtrema(x,ext,isInMATLAB)
%CALLFINDEXTREMA  Call findExtrema in MATLAB and codegen
% This function is for internal use only. It may be removed. 

%   Copyright 2017 The MathWorks, Inc.

%#ok<*EMCLS>
%#ok<*EMCA>
%#codegen

% Find extrema, if time series provided.
if ~ext
  if isInMATLAB
    % Call mex function, which is generated from 'signal.internal.rainflow.findExtrema.m'.
    if isa(x,'single')
      idx = signal.internal.rainflow.rainflowmxs('findExtrema',x);
    else
      idx = signal.internal.rainflow.rainflowmx('findExtrema',x);
    end
  else
    idx = signal.internal.rainflow.findExtrema(x);
  end
else
  idx = (1:length(x))';
end