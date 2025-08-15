function w = triang(N)
%TRIANG Triangular window.
%   W = TRIANG(N) returns the N-point triangular window.
%
%   % Example:
%   %   Create a 200-point triangular window and plot the result using
%   %   WVTool.
%
%   L=200;
%   wvtool(triang(L))
%
%   See also BARTHANNWIN, BARTLETT, BLACKMANHARRIS, BOHMANWIN,
%            FLATTOPWIN, NUTTALLWIN, PARZENWIN, RECTWIN, WINDOW.

%   Copyright 1988-2019 The MathWorks, Inc.

%#codegen

narginchk(1,1);

if coder.target('MATLAB')    
    w = eTriang(N);
else    
    if coder.internal.isConst(N) && coder.internal.isCompiled
        % code generation for constant input args
        w = coder.const(@feval,'triang',N);
    else
        % code generation for variable input args
        w = eTriang(N);
    end
    
end
end

function w = eTriang(N)

validateattributes(N,{'numeric'},{'real','finite'},'triang','N');

% Cast to enforce Precision Rules
N = signal.internal.sigcasttofloat(N,'double','triang',...
  'N','allownumeric');

[N,w,trivialwin] = check_order(N);
if trivialwin
    return
end

% codegeneration special case: Ensure order is scalar
L = N(1);

if rem(L,2)
    % It's an odd length sequence
    w_temp = 2*(1:(L+1)/2)/(L+1);
    w = [w_temp w_temp((L-1)/2:-1:1)]';
else
    % It's even
    w_temp = (2*(1:(L+1)/2)-1)/L;
    w = [w_temp w_temp(L/2:-1:1)]';
end

end




% [EOF] triang.m

% LocalWords:  allownumeric
