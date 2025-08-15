function w = bartlett(n_est)
%BARTLETT Bartlett window.
%   W = BARTLETT(N) returns the N-point Bartlett window.
%
%   % Example:
%   %   Create a 64-point Bartlett window and display the result using
%   %   WVTool.
%
%   L=64;
%   wvtool(bartlett(L))
%
%   See also BARTHANNWIN, BLACKMANHARRIS, BOHMANWIN, FLATTOPWIN,
%            NUTTALLWIN, PARZENWIN, RECTWIN, TRIANG, WINDOW.

%   Copyright 1988-2018 The MathWorks, Inc.
%#codegen

narginchk(1,1);

if coder.target('MATLAB')
    w = eBartlett(n_est);
else
    % check for constant inputs
    if coder.internal.isConst(n_est) && coder.internal.isCompiled
        % codegeneration for constant input argument
        w = coder.const(feval('bartlett',n_est));
    else
        % codegeneration for variable input argument
        w = eBartlett(n_est);
    end
end

end

function w = eBartlett(N)
%#codegen

narginchk(1,1);

if ~isempty(N)
    
    validateattributes(N,{'numeric'},{'real','finite'},'bartlett','L');
    
    % Cast to enforce Precision Rules
    N = signal.internal.sigcasttofloat(N,'double','bartlett','N',...
        'allownumeric');
    
    [n,w,trivialwin] = check_order(N);
    if trivialwin 
        return
    end
    
    L = n(1);
        
    w = 2*(0:(L-1)/2)/(L-1);
    
    if isodd(n)
        % It's an odd length sequence
        w = [w w((L-1)/2:-1:1)]';
    else
        % It's even
        w = [w w(L/2:-1:1)]';
    end
else
    w = zeros(0,1);
end

end

% [EOF] bartlett.m

% LocalWords:  allownumeric
