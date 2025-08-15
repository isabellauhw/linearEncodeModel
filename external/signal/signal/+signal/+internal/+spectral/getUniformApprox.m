function [fstart, fstop, n, err] = getUniformApprox(f)
%#codegen
% GETUNIFORMAPPROX get uniform approximation of a frequency vector
%   [Fstart, Fstop, N, Emax] = GETUNIFORMAPPROX(F) returns the first
%   frequency, Fstart, last frequency Fstop, and number of frequency
%   points, N, and the relative maximum error, Emax, between any internal
%   point and a linearly spaced vector with the same number of points over
%   the same range as the input.
%
%   This file is for internal use only and may be removed in a future
%   release.

%   Copyright 1988-2018 The MathWorks, Inc.

fstart = f(1);
fstop = f(end);
n = numel(f);

if coder.target('MATLAB')
    err = max(abs(f.'-linspace(fstart,fstop,n))./max(abs(f)));
else
    approx = linspace(fstart,fstop,n).';
    errorMatrix = coder.nullcopy(zeros(n,1));
    maxFreq = max(abs(f));

    for i=1:n
        errorMatrix(i) = abs(f(i) - approx(i))/maxFreq;  
    end

    err = max(errorMatrix);
end
end