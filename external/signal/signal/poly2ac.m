function R=poly2ac(a,efinal)
%POLY2AC  Convert prediction polynomial to autocorrelation sequence.
%   R=POLY2AC(A,Efinal) returns the autocorrelation sequence, R, based on
%   the prediction polynomial, A, and the final prediction error, Efinal. 
%
%   If A(1) is not equal to 1, POLY2AC normalizes the prediction
%   polynomial by A(1).
%
%   % Example:
%   %   Convert the following prediction filter polynomial to
%   %   autocorrelation sequence
%   %   a = [1.0000 0.6147 0.9898 0.0004 0.0034 -0.0077];
%
%   a = [1.0000 0.6147 0.9898 0.0004 0.0034 -0.0077];
%   efinal = 0.2;           % Step prediction error
%   r = poly2ac(a,efinal)   % Autocorrelation sequence
%
%   See also AC2POLY, POLY2RC, RC2POLY, RC2AC, AC2RC.

%   References: S. Kay, Modern Spectral Estimation,

%               Prentice Hall, N.J., 1987, Chapter 6.
%
%   Copyright 1988-2018 The MathWorks, Inc.

%#codegen

if ~isvector(a)
   coder.internal.assert(false, 'signal:poly2ac:inputnotsupported');
end

if any([signal.internal.sigcheckfloattype(a,'single','poly2ac',...
        'A(Prediction Polynomial)') signal.internal.sigcheckfloattype(efinal,...
        'single','poly2ac','Efinal(Final Prediction Error)')])
    efinal_temp = single(efinal);
    a_temp = single(a);
else
    efinal_temp = efinal;
    a_temp = a;
end
R = rlevinson(a_temp,efinal_temp);
% [EOF] poly2ac.m
