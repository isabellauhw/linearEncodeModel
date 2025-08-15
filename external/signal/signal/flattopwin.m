function w = flattopwin(varargin)
%FLATTOPWIN Flat Top window.
%   FLATTOPWIN(N) returns the N-point symmetric Flat Top window in a column 
%   vector.
%   FLATTOPWIN(N,SFLAG) generates the N-point Flat Top window using SFLAG
%   window sampling. SFLAG may be either 'symmetric' or 'periodic'. By 
%   default, a symmetric window is returned. 
%
%   EXAMPLE:
%      w = flattopwin(64); 
%      wvtool(w);
%
%   See also BARTHANNWIN, BARTLETT, BLACKMANHARRIS, BOHMANWIN,
%            NUTTALLWIN, PARZENWIN, RECTWIN, TRIANG, WINDOW.

%   Reference:
%     [1] Digital Signal Processing for Measurement Systems, D'Antona G. and
%     Ferrero A., Springer Media, Inc. 2006
%     [2] Bruel & Kjaer, Windows to FFT Analysis (Part I), Technical
%     Review, No. 3, 1987

%   Copyright 1988-2018 The MathWorks, Inc.
%#codegen

narginchk(1,2);

if coder.target('MATLAB')
    w = gencoswin('flattopwin',varargin{:});
else
    % check for constant inputs
    allConst = true;
    coder.unroll();
    for k = 1:nargin
        allConst = allConst && coder.internal.isConst(varargin{k});
    end
    if allConst && coder.internal.isCompiled
        % codegen for constant input arguments
        w = coder.const(@feval,'flattopwin',varargin{:});
    else
        % codegen for variable input argument
        w = gencoswin('flattopwin',varargin{:});
    end
    
end

% [EOF]

% LocalWords:  SFLAG D'Antona Ferrero Bruel Kjaer
