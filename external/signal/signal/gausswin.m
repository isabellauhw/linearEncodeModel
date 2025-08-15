function w = gausswin(N, a)
%GAUSSWIN Gaussian window.
%   GAUSSWIN(N) returns an N-point Gaussian window.
%
%   GAUSSWIN(N, ALPHA) returns the ALPHA-valued N-point Gaussian
%   window.  ALPHA is defined as the reciprocal of the standard
%   deviation and is a measure of the width of its Fourier Transform.
%   As ALPHA increases, the width of the window will decrease. If omitted,
%   ALPHA is 2.5.
%
%   EXAMPLE:
%      N = 32;
%      wvtool(gausswin(N));
%
%
%   See also CHEBWIN, KAISER, TUKEYWIN, WINDOW.

%   Reference:
%     [1] fredric j. harris [sic], On the Use of Windows for Harmonic
%         Analysis with the Discrete Fourier Transform, Proceedings of
%         the IEEE, Vol. 66, No. 1, January 1978

%   Copyright 1988-2019 The MathWorks, Inc.

%#codegen

narginchk(1,2);

if coder.target('MATLAB')
    switch nargin
        case 1
            w = eGausswin(N);
        case 2
            w = eGausswin(N,a);
    end
else
    switch nargin
        case 1
            if coder.internal.isConst(N) && coder.internal.isCompiled
                % code generation for constant input args
                w = coder.const(@feval,'gausswin',N);
            else
                % code generation for variable input args
                w = eGausswin(N);
            end
        case 2
            if coder.internal.isConst(N) && coder.internal.isConst(a) && coder.internal.isCompiled
                % code generation for constant input args
                w = coder.const(@feval,'gausswin', N, a);
            else
                % code generation for variable input args
                w = eGausswin(N, a);
            end
    end
end

end

function w = eGausswin(N,a)

narginchk(1,2);

validateattributes(N,{'numeric'},{'real','finite'},'gausswin','N');

%Cast to enforce Precision Rules
N = signal.internal.sigcasttofloat(N,'double','gausswin','order','allownumeric');
% Check for valid window length (i.e., N < 0)
[N,w,trivialwin] = check_order(N);
if trivialwin
    return
end

% Default value for Alpha
if nargin < 2 || isempty(a)
    alpha = 2.5;
else
    validateattributes(a,{'numeric'},{'scalar','real','finite','nonnegative'},'gausswin','alpha',2);
    alpha = a(1); % codegeneration special case: Ensure order is scalar
end
alpha = signal.internal.sigcasttofloat(alpha,'double','gausswin','ALPHA',...
    'allownumeric');

% Compute window according to [1]
L = N(1)-1;  % codegeneration special case: Ensure order is scalar
n = (0:L)'-L/2;
w = exp(-(1/2)*(alpha*n/(L/2)).^2);

end




% [EOF]

% LocalWords:  fredric harris allownumeric
