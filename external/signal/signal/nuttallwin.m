function w = nuttallwin(N,sflag)
%NUTTALLWIN Nuttall defined minimum 4-term Blackman-Harris window.
%   NUTTALLWIN(N) returns an N-point modified minimum 4-term
%   Blackman-Harris window with coefficients according to
%   Albert H. Nuttall's paper.
%   NUTTALLWIN(N,SFLAG) generates the N-point modified minimum 4-term
%   Blackman-Harris window using SFLAG window sampling. SFLAG may be either
%   'symmetric' or 'periodic'. By default, a symmetric window is returned.
%
%   EXAMPLE:
%      N = 32;
%      w = nuttallwin(N);
%      plot(w); title('32-point Nuttall window');
%
%   See also BARTHANNWIN, BARTLETT, BLACKMANHARRIS, BOHMANWIN,
%            FLATTOPWIN, PARZENWIN, RECTWIN, TRIANG, WINDOW.

%   Reference:
%     [1] Albert H. Nuttall, Some Windows with Very Good Sidelobe
%         Behavior, IEEE Transactions on Acoustics, Speech, and
%         Signal Processing, Vol. ASSP-29, No.1, February 1981

%   Copyright 1988-2019 The MathWorks, Inc.

%#codegen

narginchk(1,2);

if coder.target('MATLAB')
    switch nargin
        case 1
            w = eNuttallwin(N);
        case 2
            w = eNuttallwin(N,sflag);
    end
else
    switch nargin
        case 1
            if coder.internal.isConst(N) && coder.internal.isCompiled
                % code generation for constant input args
                w = coder.const(@feval,'nuttallwin',N);
            else
                % code generation for variable input args
                w = eNuttallwin(N);
            end
        case 2
            if coder.internal.isConst(N) && coder.internal.isConst(sflag) && coder.internal.isCompiled
                % code generation for constant input args
                w = coder.const(@feval,'nuttallwin',N, sflag);
            else
                % code generation for variable input args
                w = eNuttallwin(N, sflag);
            end
    end
end
end

function w = eNuttallwin(N,sflag)

validateattributes(N,{'numeric'},{'real','finite'},'nuttallwin','N');
% Cast to enforce Precision Rules
N = signal.internal.sigcasttofloat(N,'double','nuttallwin','N',...
    'allownumeric');

% Check for valid window length (i.e., N < 0)
[N,w,trivialwin] = check_order(N);
if trivialwin
    return
end

if nargin == 1 || isempty(sflag)
    sFlag = "symmetric";
else
    if isstring(sflag) && strlength(sflag) == 0
        sFlag = "symmetric";
    else
        sflagOpts = {'symmetric','periodic'};
        sFlag = convertCharsToStrings(validatestring(sflag,sflagOpts,'nuttallwin','sflag'));        
    end    
end

% Coefficients obtained from page 89 of [1]
a = [0.3635819 0.4891775 0.1365995 0.0106411];
L = N(1);  % codegeneration special case: Ensure order is scalar
if sFlag == "periodic"
    x = (0:L-1)' * 2.0*pi/L;
else
    x = (0:L-1)'*2*pi/(L-1);
end
w = min4termwin(a,x);

end

% [EOF]

% LocalWords:  Nuttall Nuttall's SFLAG Sidelobe ASSP scalartext sflag
% LocalWords:  allownumeric
