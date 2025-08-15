function w = blackmanharris(varargin)
%BLACKMANHARRIS Minimum 4-term Blackman-Harris window.
%   BLACKMANHARRIS(N) returns an N-point minimum 4-term Blackman-Harris 
%   window in a column vector.
%   BLACKMANHARRIS(N,SFLAG) generates the N-point Blackman-Harris window
%   using SFLAG window sampling. SFLAG may be either 'symmetric' or
%   'periodic'. By default, a symmetric window is returned.
%
%   EXAMPLE:
%      N = 32; 
%      w = blackmanharris(N); 
%      plot(w); title('32-point Blackman-Harris Window');
%
%   See also BARTHANNWIN, BARTLETT, BOHMANWIN, FLATTOPWIN, 
%            NUTTALLWIN, PARZENWIN, RECTWIN, TRIANG, WINDOW.

%   Reference:
%     [1] fredric j. harris [sic], On the Use of Windows for Harmonic 
%         Analysis with the Discrete Fourier Transform, Proceedings of 
%         the IEEE, Vol. 66, No. 1, January 1978

%   Copyright 1988-2018 The MathWorks, Inc.

%#codegen

narginchk(1,2);    

if coder.target('MATLAB')
    w = eBlackmanharris(varargin{:});
else
   % check for constant inputs
   allConst = true;
   coder.unroll();
   for k = 1:nargin
       allConst = allConst && coder.internal.isConst(varargin{k});
   end
   if allConst && coder.internal.isCompiled
       % codegen for constant input arguments
       w = coder.const(@feval,'blackmanharris',varargin{:});
   else
       % codegen for variable input argument
       w = eBlackmanharris(varargin{:});
   end  
   
end

function w = eBlackmanharris(N,sflag)

narginchk(1,2); 

validateattributes(N,{'numeric'},{'real','finite'},'blackmanharris','N');
% Cast to enforce Precision Rules
N = signal.internal.sigcasttofloat(N,'double','BLACKMANHARRIS','N',...
  'allownumeric');

% Check for valid window length (i.e., N < 0)
[N,w,trivialwin] = check_order(N);
if trivialwin
    return
end
L = N(1);

if nargin > 1
    sflagOpts = {'symmetric','periodic'};
    validateattributes(sflag,{'char','string'},{'scalartext'},'blackmanharris','sflag');
    sFlag = convertCharsToStrings(validatestring(sflag,sflagOpts,'blackmanharris','sflag'));
elseif nargin < 2
    sFlag = "symmetric";
end

% Coefficients obtained from page 65 of [1]
a = [0.35875 0.48829 0.14128 0.01168];
if sFlag == "periodic"
    x = (0:L-1)' * 2.0*pi/L;
else
    x = (0:L-1)'*2*pi/(L-1);
end
w = min4termwin(a,x);



% [EOF]

% LocalWords:  SFLAG fredric harris scalartext sflag allownumeric
