function w = bohmanwin(N)
%BOHMANWIN Bohman window.
%   BOHMANWIN(N) returns an N-point Bohman window in a column vector.
%
%   EXAMPLE:
%      N = 64; 
%      w = bohmanwin(N); 
%      plot(w); title('64-point Bohman window');
%
%   See also BARTHANNWIN, BARTLETT, BLACKMANHARRIS, FLATTOPWIN, 
%            NUTTALLWIN, PARZENWIN, RECTWIN, TRIANG, WINDOW.

%   Reference:
%     [1] fredric j. harris [sic], On the Use of Windows for Harmonic Analysis
%         with the Discrete Fourier Transform, Proceedings of the IEEE,
%         Vol. 66, No. 1, January 1978, Page 67, Equation 39.

%   Author(s): A. Dowd
%   Copyright 1988-2018 The MathWorks, Inc.

%#codegen

narginchk(1,1);

if coder.target('MATLAB')
    w = eBohmanwin(N);
else
    % check for constant inputs
    if coder.internal.isConst(N) && coder.internal.isCompiled
        % code generation for constant input argument
        w = coder.const(@feval,'bohmanwin',N);
    else
        % code generation for variable input argument
        w = eBohmanwin(N);
    end
    
end



function w = eBohmanwin(N)
%#codegen

validateattributes(N,{'numeric'},{'real','finite'},'bohmanwin','N');
% Cast to enforce Precision Rules
N = signal.internal.sigcasttofloat(N,'double','bohmanwin','N',...
  'allownumeric');

% check for valid window length (i.e. N < 0)
[N,w,trivialwin] = check_order(N);
if trivialwin
    return
end

L = N(1);
q = abs(linspace(-1,1,L));

% Forced end points to exactly zero
w = [ 0; ((1-q(2:end-1)).*cos(pi*q(2:end-1))+(1/pi)*sin(pi*q(2:end-1)))'; 0];



% [EOF]

% LocalWords:  Bohman fredric harris Dowd allownumeric
