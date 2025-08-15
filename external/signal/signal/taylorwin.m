function w = taylorwin(varargin)
%TAYLORWIN   Taylor window.
%
% TAYLORWIN(N) returns an N-point Taylor window in a column vector.
%
% TAYLORWIN(N,NBAR) returns an N-point Taylor window with NBAR nearly
% constant-level sidelobes adjacent to the mainlobe. NBAR must be an
% integer greater than or equal to one.
%
% TAYLORWIN(N,NBAR,SLL) returns an N-point Taylor window with SLL maximum
% sidelobe level in dB relative to the mainlobe peak. SLL must be a
% negative value, e.g., -30 dB.
%
% NBAR should satisfy NBAR >= 2*A^2+0.5, where A is equal to
% acosh(10^(-SLL/20))/pi, otherwise the sidelobe level specified is not
% guaranteed. If NBAR is not specified it defaults to 4. SLL defaults to
% -30 dB if not specified.
%
% % EXAMPLE
% %  This example generates a 64-point Taylor window with 4 sidelobes
% %  adjacent to the mainlobe that are nearly constant-level, and a peak
% %  sidelobe level of -35 dB relative to the mainlobe peak.
%
%   w = taylorwin(64,5,-35);
%   wvtool(w);
%
%   See also CHEBWIN.

%   Copyright 2005-2018 The MathWorks, Inc.

%
%   References:
%     [1] Carrara, Walter G., Ronald M. Majewski, and Ron S. Goodman,
%         Spotlight Synthetic Aperture Radar: Signal Processing Algorithms,
%         Artech House, October 1, 1995.
%     [2] Brookner, Eli, Practical Phased Array Antenna Systems,
%         Artech House, Inc., 1991, pg. 2-51.

%#codegen

% Validate input and set default values.

narginchk(1, 3); 

if coder.target('MATLAB')
    w = eTaylorwin(varargin{:});
else
    allConst = true;
    coder.unroll();
    for k = 1:nargin
        allConst = allConst && coder.internal.isConst(varargin{k});
    end
    
    if allConst && coder.internal.isCompiled
        % codegen for constant input args
        w = coder.const(@feval,'taylorwin',varargin{:});
        
    else
        % codegen for variable input args
        w = eTaylorwin(varargin{:});
    end
end


function w = eTaylorwin(varargin)

narginchk(1, 3); 

[N,w,trivalwin] = validateN(varargin{1});
if trivalwin    
    return
end 

[NBAR,SLL] = validateOptionalArgs(varargin{:});
L = N(1); % codegeneration special case: Ensure order is scalar

A = acosh((10^(-SLL/20)))/pi;

% Taylor pulse widening (dilation) factor.
sp2 = NBAR^2/(A^2 + (NBAR-.5)^2);

Fm = zeros(NBAR-1,1);
summation = zeros(L,1);
k = (0:L-1)';
xi = (k-0.5*L+0.5)/L;
for m = 1:(NBAR-1)
    Fm(m) = calculateFm(m,sp2,A,NBAR);
    summation = Fm(m)*cos(2*pi*m*xi)+summation;
end
w = w + 2*summation;


%-------------------------------------------------------------------
function Fm = calculateFm(m,sp2,A,NBAR)
% Calculate the cosine weights.

n = (1:NBAR-1)';
p = [1:m-1, m+1:NBAR-1]'; % p~=m

Num = prod((1 - (m^2/sp2)./(A^2+(n-0.5).^2)));
Den = prod((1 - m^2./p.^2));

Fm = ((-1)^(m+1).*Num)./(2.*Den);


function [N,w,trivalwin] = validateN(n_in)

trivalwin = 0;
% Special case of N is []
if isempty(n_in)
    N = 0;    
    w = zeros(0,1);
    trivalwin = 1;
    return
end

validateattributes(n_in,{'numeric'},{'real','finite','scalar','nonnegative'},'taylorwin','N');
n = signal.internal.sigcasttofloat(n_in,'double','taylorwin','order','allownumeric');

if all(n(:) == floor(n(:)),1)
    N = n;
else
    N = round(n);
    coder.internal.warning('signal:taylorwin:WindowLengthMustBeInteger');
end

if all(N(:) == 0,1)
    w = zeros(0,1);   
    trivalwin = 1;      
else
    w = ones(N(1),1);
end

%-------------------------------------------------------------------
function [NBAR,SLL] = validateOptionalArgs(varargin)

% Validate NBAR
if nargin < 2 || isempty(varargin{2})
    NBAR = 4;
else
    validateattributes(varargin{2},{'numeric'},{'scalar','real','finite'},'taylorwin','nbar',2);
    % Cast to enforce Precision Rules
    nbar = signal.internal.sigcasttofloat(varargin{2},'double',...
      'taylorwin','NBAR','allownumeric');
    NBAR = nbar(1);
  % NBAR must be a positive integer
    coder.internal.errorIf((NBAR<=0 || NBAR~=floor(NBAR)),'signal:taylorwin:NBARMustBeInteger');   
end

% Validate SLL
if nargin < 3 || isempty(varargin{3})
    SLL = -30;
else
    validateattributes(varargin{3},{'numeric'},{'scalar','real','finite'},'taylorwin','sll',3);
    % Cast to enforce Precision Rules
    sll = signal.internal.sigcasttofloat(varargin{3},'double','taylorwin',...
      'SLL','allownumeric');  
    SLL = sll(1);
    coder.internal.errorIf(SLL > 0,'signal:taylorwin:SLLMustBeNegative');    
end


% [EOF]

% LocalWords:  NBAR sidelobes mainlobe SLL sidelobe Carrara Majewski Artech
% LocalWords:  Brookner nbar allownumeric sll
