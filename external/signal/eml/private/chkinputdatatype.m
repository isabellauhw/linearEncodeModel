function chkinputdatatype(varargin)
%MATLAB Code Generation Private Function

%   Copyright 1988-2016 The MathWorks, Inc.
%#codegen

for n = coder.unroll(1:nargin)
    coder.internal.assert(isa(varargin{n},'double'), ...
        'signal:chkinputdatatype:NotSupported');
end
