function w = barthannwin(varargin)
%   BARTHANNWIN Modified Bartlett-Hanning window.
%   BARTHANNWIN(N) returns an N-point Modified Bartlett-Hanning window
%   in a column vector.
%
%   EXAMPLE:
%      N = 64;
%      w = barthannwin(N);
%      plot(w); title('64-point Modified Bartlett-Hanning window');
%
%   See also BARTLETT, BLACKMANHARRIS, BOHMANWIN, FLATTOPWIN,
%            NUTTALLWIN, PARZENWIN, RECTWIN, TRIANG, WINDOW.

%   Reference:
%     [1] Yeong Ho Ha and John A. Pearce, A New Window and Comparison
%         to Standard Windows, IEEE Transactions on Acoustics, Speech,
%         and Signal Processing, Vol. 37, No. 2, February 1999

%   Copyright 1988-2018 The MathWorks, Inc.

% Copyright 2008-2010 The MathWorks, Inc.
%#codegen    

narginchk(1,1);

if coder.target('MATLAB')
    w = eBarthannwin(varargin{1});
else
    % check for constant inputs
    if coder.internal.isConst(varargin{1}) && coder.internal.isCompiled 
       % codegeneration for constant input argument
       w = coder.const(@feval,'barthannwin',varargin{:});   
    else
        % codegeneration for variable input argument
        w = eBarthannwin(varargin{1});        
    end       
end



function w = eBarthannwin(N)%#codegen  

narginchk(1,1);

validateattributes(N,{'numeric'},{'real','finite'},'barthannwin','L');

% Cast to enforce Precision Rules
N = signal.internal.sigcasttofloat(N,'double','barthannwin','N','allownumeric');

% Check for valid window length (i.e., N < 0)
[N,w,trivialwin] = check_order(N); 
if trivialwin
    return
end
L = N(1);
% Evaluate the window
t = ((0:(L-1))/(L-1) - 0.5)'; % -0.5 <= t <= 0.5
w = 0.62 - 0.48 * abs(t) + 0.38 * cos(2*pi*t);


% LocalWords:  Yeong allownumeric
