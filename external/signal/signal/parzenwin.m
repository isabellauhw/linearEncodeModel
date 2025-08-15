function w = parzenwin(N)
%PARZENWIN Parzen window.
%   PARZENWIN(N) returns the N-point Parzen (de la Valle-Poussin) window in a column vector.
%
%   % Example:
%   %   Create a 64-point Parzen window and display the result using Wvtool
%
%   wvtool(parzenwin(64))
%
%   See also BARTHANNWIN, BARTLETT, BLACKMANHARRIS, BOHMANWIN,
%            FLATTOPWIN, NUTTALLWIN, RECTWIN, TRIANG, WINDOW.

%   Reference:
%     [1] fredric j. harris [sic], On the Use of Windows for Harmonic
%         Analysis with the Discrete Fourier Transform, Proceedings of
%         the IEEE, Vol. 66, No. 1, January 1978

%   Copyright 1988-2019 The MathWorks, Inc.

%#codegen

narginchk(1,1);

if coder.target('MATLAB')
    w = eParzenwin(N);
else
    if coder.internal.isConst(N) && coder.internal.isCompiled
        % code generation for constant input args
        w = coder.const(@feval,'parzenwin',N);
    else
        % code generation for variable input args
        w = eParzenwin(N);
    end
    
end

end

function w = eParzenwin(N)

validateattributes(N,{'numeric'},{'real','finite'},'parzenwin','N');

% Cast to enforce Precision Rules
N = signal.internal.sigcasttofloat(N,'double','parzenwin','N','allownumeric');

% Check for valid window length (i.e., n < 0)
[N,w,trivialwin] = check_order(N);
if trivialwin
    return
end
L = N(1);  % codegeneration special case: Ensure order is scalar
% Index vectors
k = -(L-1)/2:(L-1)/2;
k1 = k(k<-(L-1)/4);
k2 = k(abs(k)<=(L-1)/4);

% Equation 37 of [1]: window defined in three sections
w1 = 2 * (1-abs(k1)/(L/2)).^3;
w2 = 1 - 6*(abs(k2)/(L/2)).^2 + 6*(abs(k2)/(L/2)).^3;
w = [w1 w2 w1(end:-1:1)]';

end

% [EOF]

% LocalWords:  Parzen de fredric harris allownumeric
