function y = peak2rms(x, dim)
%PEAK2RMS Ratio of largest absolute to root mean squared value of a tall array.
%   Y = PEAK2RMS(X)
%   Y = PEAK2RMS(X,DIM) operates along the dimension DIM.
%
%   See also PEAK2RMS, TALL.

%   Copyright 2017 The MathWorks, Inc.

if nargin==1
    num = max(abs(x));
    den = rms(x);
else
    num = max(abs(x),[],dim);
    den = rms(x,dim);
end

% We have to use chunkfun here as the output size doesn't quite follow
% normal elementwise rules: (10x0)./(10x1) should be (10x0) but here is (10x1).
y = chunkfun(@iSafeDivide, num, den);
% Result is same type as X and same size as DEN.
y.Adaptor = copySizeInformation(x.Adaptor, den.Adaptor);

end

function out = iSafeDivide(num, den)
% element-wise divide that guards against empty numerator
if isempty(num)
    out = den;
else
    out = num ./ den;
end
end

