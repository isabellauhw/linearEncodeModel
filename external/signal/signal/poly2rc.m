function [kr,R0]=poly2rc(a,efinal)
%POLY2RC  Convert prediction polynomial to reflection coefficients (step-down).
%   K = POLY2RC(A) returns the reflection coefficients, K, based on the
%   prediction polynomial, A.
%
%   If A(1) is not equal to 1, POLY2RC normalizes the prediction
%   polynomial by A(1).
%
%   [K,R0] = POLY2RC(A,Efinal) returns the zero lag autocorrelation, R0,
%   based on the final prediction error, Efinal. If Efinal is not
%   specified, then the default is Efinal=0.
%
%   % Example:
%   %   Convert the following prediction filter polynomial to reflection
%   %   coefficients:
%   %   a = [1.0000   0.6149   0.9899   0.0000   0.0031  -0.0082];
%
%   a = [1.0000   0.6149   0.9899   0.0000   0.0031  -0.0082];
%   efinal = 0.2;               % Final prediction error
%   [k,r0] = poly2rc(a,efinal)  % Reflection coefficients
%
%   See also RC2POLY, POLY2AC, AC2POLY, RC2AC, AC2RC and TF2LATC.

%   References: S. Kay, Modern Spectral Estimation,
%               Prentice Hall, N.J., 1987, Chapter 6.
%
%   Copyright 1988-2018 The MathWorks, Inc.

%#codegen

if ((size(a,1) > 1) && (size(a,2) > 1))
    coder.internal.assert(false,'signal:poly2rc:inputnotsupported');
end

% Cast to enforce Precision Rules
if (nargin == 2) && any([signal.internal.sigcheckfloattype(a,'single','poly2rc',...
        'A(prediction polynomial)') signal.internal.sigcheckfloattype(efinal,...
        'single','poly2rc','Efinal(final prediction error)')])
    efinal_temp = single(efinal);
    a_temp = single(a);
elseif (nargin == 1) && (signal.internal.sigcheckfloattype(a,'single','poly2rc',...
        'A(prediction polynomial)')||isa(a,'double'))
    temp_class = class(a);
    if isempty(a) 
        efinal_temp  = a;
    else
    efinal_temp = zeros(1,1,temp_class);
    end
    a_temp = a;
else
    efinal_temp = efinal;
    a_temp = a;
end

if length(a_temp) <= 1
    % K is length of A minus one so make empty if A is a scalar or empty.
    % Cast to enforce Precision Rules
    if isa(a_temp,'single')
        kr = single([]);
    else
        kr = [];
    end
    R0 = efinal_temp;
    return
end

if a_temp(1) == 0
    coder.internal.error('signal:poly2rc:SignalErr');
end

temp_a1 = a_temp(:)./a_temp(1);  % Convert to column vector and normalize by a_temp(1)

p = length(temp_a1)-1;   % The leading one does not count
e = complex(zeros(p,1,class(temp_a1)));
kr = complex(zeros(p,1,class(temp_a1)));

e(p) = efinal_temp;
kr(p) = temp_a1(end);

temp_a = transpose(temp_a1);
coder.varsize('temp_a','unbound');

for k = p-1:-1:1
    [temp_a,e(k),~] = levdown(temp_a,e(k+1));
    kr(k) = temp_a(end);
end
% Compute R0 only if asked for because it can cause divide by zero warnings
if nargout >= 2
    % R0 is the zero order prediction error when the prediction error filter,
    % A(z) = 1.
    R0 = e(1)./(1-abs(kr(1))^2);
end

end

