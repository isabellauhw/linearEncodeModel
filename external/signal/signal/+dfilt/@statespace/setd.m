function D = setd(Hd, D)
%SETD Overloaded set function on the D property.
  
%   Author: V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.

if ~isreal(D)
    error(message('MATLAB:class:MustBeReal'));
end

Hd.refD = D;
quantizecoeffs(Hd);

% Hold an empty to not duplicate storage
D = [];
