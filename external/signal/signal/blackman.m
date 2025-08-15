function w = blackman(varargin)
%BLACKMAN   Blackman window.
%   BLACKMAN(N) returns the N-point symmetric Blackman window in a column
%   vector.
%   BLACKMAN(N,SFLAG) generates the N-point Blackman window using SFLAG
%   window sampling. SFLAG may be either 'symmetric' or 'periodic'. By 
%   default, a symmetric window is returned. 
%
%   % Example:
%   %   Create a 64-point Blackman window and display the result using 
%   %   WVTool.
%
%   L=64;
%   wvtool(blackman(L))
%
%   See also  HAMMING, HANN, WINDOW.

%   Copyright 1988-2018 The MathWorks, Inc.
%#codegen

% Check number of inputs

narginchk(1,2);

if coder.target('MATLAB')
    w = gencoswin('blackman',varargin{:});
else
    % check for constant inputs
    allConst = true;
    coder.unroll();
    for k = 1:nargin
        allConst = allConst && coder.internal.isConst(varargin{k});
    end
    if allConst && coder.internal.isCompiled
        % codegen for constant input arguments
        w = coder.const(@feval,'blackman',varargin{:});
    else
        % codegen for variable input argument
        w = gencoswin('blackman',varargin{:});
    end
    
end

% [EOF] blackman.m

% LocalWords:  SFLAG
