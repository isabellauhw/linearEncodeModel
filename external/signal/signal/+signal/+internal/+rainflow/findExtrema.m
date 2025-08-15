function indEx = findExtrema(x) 
%FINDEXTREMA Locate extrema from time history
% This function is for internal use only. 

% This function is converted to C++ code and converted to mex during build,
% and is called in MATLAB by rainflow.m as a MEX function. To rebuild after
% modifying this file, use 'mw gmake -B build COMPONENT=signal' in
% ./rainflowmx and ./rainflowmxs.

%   Copyright 2017 The MathWorks, Inc.

%#ok<*EMCLS>
%#ok<*EMCA>
%#codegen

  [~,ind1] = findpeaks(x);
  [~,ind2] = findpeaks(-x);
  indEx = [1;sort([ind1;ind2]);length(x)];
end