function colvec = toColIfVect(vec)
% Convert vec to a column vector if it is a row vector, maintaining
% complexity. This is different than calling vec(:) in two ways: 1)
% matrices stay as matrices and 2) complex vectors with zero imaginary
% part stay imaginary.
%
%#codegen

%   Copyright 2016-2019 The MathWorks, Inc.

if isrow(vec)
    colvec = reshape(vec,size(vec,2),1);
else
    colvec = vec;
end

% LocalWords:  vec
