function coeffs = removetrailzeros(coeffs)
%REMOVETRAILZEROS  Remove trailing zeros.
%   C = REMOVETRAILZEROS(C) removes all trailing zeros from vector C.
%   If C is all zeros, then it returns C equal to a single zero. If
%   C is empty, it returns empty.

%   Author(s): R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

if isempty(coeffs)
	return
end

indx = find(coeffs ~= 0, 1, 'last' );

if isempty(indx)
	coeffs = 0;
else
	coeffs = coeffs(1:indx);
end

