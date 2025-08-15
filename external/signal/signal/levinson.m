function [A,E,K] = levinson(R,N)
%LEVINSON  Levinson-Durbin Recursion.
%   A = LEVINSON(R,N) solves the Hermitian Toeplitz system of equations
%
%       [  R(1)   R(2)* ...  R(N)* ] [  A(2)  ]  = [  -R(2)  ]
%       [  R(2)   R(1)  ... R(N-1)*] [  A(3)  ]  = [  -R(3)  ]
%       [   .        .         .   ] [   .    ]  = [    .    ]
%       [ R(N-1) R(N-2) ...  R(2)* ] [  A(N)  ]  = [  -R(N)  ]
%       [  R(N)  R(N-1) ...  R(1)  ] [ A(N+1) ]  = [ -R(N+1) ]
%
%   (also known as the Yule-Walker AR equations) using the Levinson-
%   Durbin recursion.  Input R is typically a vector of autocorrelation
%   coefficients with lag 0 as the first element.
%
%   N is the order of the recursion; if omitted, N = LENGTH(R)-1.
%   A will be a row vector of length N+1, with A(1) = 1.0.
%
%   [A,E] = LEVINSON(...) returns the prediction error, E, of order N.
%
%   [A,E,K] = LEVINSON(...) returns the reflection coefficients K as a
%   column vector of length N.  Since K is computed internally while
%   computing the A coefficients, then returning K simultaneously
%   is more efficient than converting A to K afterwards via TF2LATC.
%
%   If R is a matrix, LEVINSON finds coefficients for each column of R,
%   and returns them in the rows of A
%
%   % Example:
%   %   Estimate the coefficients of an autoregressive process given by
%   %   x(n) = 0.1*x(n-1) -0.8*x(n-2) + w(n).
%
%   % Generate AR process by filtering white noise
%   a = [1, .1, -0.8];              % AR coefficients
%   v = 0.4;                        % noise variance
%   w = sqrt(v)*randn(15000,1);     % white noise
%   x = filter(1,a,w);              % generate realization of AR process
%   r = xcorr(x,'biased');          % estimate of the correlation function
%   r(1:length(x)-1) = [];          % remove correlation at negative lags
%   ar = levinson(r,numel(a)-1)     % estimate model coefficients
%
%   See also LPC, PRONY, STMCB.

%   Copyright 1988-2019 The MathWorks, Inc.
%
%   Reference(s):
% 	  [1] Lennart Ljung, "System Identification: Theory for the User",
%         pp. 278-280

%#codegen

% Validating input arguments
narginchk(1,2)

validateattributes(R, {'double', 'single'},{'2d','nonempty'},...
    'levinson', 'R', 1);

if isvector(R)
    r = R(:);
else
    r = R;
end

[temp_rws, temp_cols] = size(r);

if nargin == 2
    validateattributes(N, {'double', 'single'},{'nonempty','scalar',...
        'nonnegative'}, 'levinson', 'N', 2);
    if (N == temp_rws) || (N > temp_rws)
        N = temp_rws -1;
    end
    N = floor(N);
else
    N = temp_rws - 1;
end

isInputSingle = isa(R,'single');
isInputComplex = ~isreal(R);

% Type casting the input due to precision rules.
if isInputSingle
    tempN = single(N);
elseif isa(N,'single') && ~isInputSingle
    tempN = double(N);
else
    tempN = N;
end

% Calling the helper for levinson algorithm.
[A,tempE,K] = signal.internal.levinson.callLevinson(r,tempN,temp_cols,...
    isInputComplex,isInputSingle,isempty(coder.target));
E = tempE;



