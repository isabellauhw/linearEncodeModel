function varargout=rc2poly(kr,varargin)
%RC2POLY Convert reflection coefficients to prediction polynomial (step-up).
%   A = RC2POLY(K) computes the prediction polynomial, A, based on the
%   reflection coefficients, K.
%
%   [A,Efinal] = RC2POLY(K,R0) returns the final prediction error, Efinal,
%   based on the zero lag autocorrelation, R0.
%
%   % Example:
%   %   Consider a lattice IIR filter given by reflection coefficients,
%   %   k = [0.3090    0.9800    0.0031    0.0082   -0.0082], and give its
%   %   equivalent prediction filter representation.
%
%   k = [0.3090    0.9800    0.0031    0.0082   -0.0082];
%   a = rc2poly(k)      % Gives prediction polynomial
%
%   See also POLY2RC, RC2AC, AC2RC, AC2POLY, POLY2AC.

%   References: S. Kay, Modern Spectral Estimation,
%               Prentice Hall, N.J., 1987, Chapter 6.
%
%   Copyright 1988-2018 The MathWorks, Inc.

%#codegen

narginchk(1,2);

nargoutchk(0,2);

if ~isvector(kr)
  coder.internal.assert(false, 'signal:rc2poly:inputnotsupported');
end

if (nargout == 2) && (nargin < 2)
    coder.internal.error('signal:rc2poly:SignalErr');
end

% At this point nargin will be either 1 or 2
if nargin < 2
    e0 = zeros(1,1,class(kr));  % Default value when e0_temp is not specified
else
    e0 = varargin{1};
end

% Cast to enforce Precision rules
if any([signal.internal.sigcheckfloattype(kr,'single','rc2poly',...
        'K(reflection coefficients)') signal.internal.sigcheckfloattype(e0,...
        'single','rc2poly','R0(zero lag autocorrelation)')])
  kr_temp = single(kr);
  e0_temp = single(e0);
else
  kr_temp = kr;
  e0_temp = e0;
end

% Initialize the recursion
kr_temp = kr_temp(:);               % Force kr_temp to be a column vector.

p = length(kr_temp);         % p is the order of the prediction polynomial.

a = [1 kr_temp(1)];  
coder.varsize('a');

e = complex(zeros(1,p,class(kr_temp)));
e(1) = e0_temp.*(1 - kr_temp(1)'.*kr_temp(1));

% Continue the recursion for k=2,3,...,p, where p is the order of the
% prediction polynomial.

for k = 2:p
  [a,e(k)] = levup(a,kr_temp(k),e(k-1)); 
end

varargout{1} = a;
varargout{2} = e(end);

end

