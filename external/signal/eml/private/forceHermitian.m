function X = forceHermitian(X)
%MATLAB Code Generation Private Function

%   Equivalent to X = (X + X')/2 without forming X'.
%   Assumes X is a square matrix.

%   Copyright 1988-2016 The MathWorks, Inc.
%#codegen

n = coder.internal.indexInt(size(X,2));
for j = 1:n
    for i = 1:j-1
        rij = (X(i,j) + conj(X(j,i)))/2;
        X(i,j) = rij;
        X(j,i) = conj(rij);
    end
    X(j,j) = real(X(j,j));
end

