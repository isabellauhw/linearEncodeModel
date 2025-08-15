function str = coeff2str(hTar, coef, stage, H) %#ok<INUSD,INUSL>
%COEFF2STR  Convert coefficient to string

%    This should be a private method

%    Copyright 1995-2011 The MathWorks, Inc.

narginchk(4,4);

coef = coef(stage);

str = mat2str(coef, 18);
