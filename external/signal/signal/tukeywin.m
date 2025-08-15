function w = tukeywin(N,r)
%TUKEYWIN Tukey window.
%   TUKEYWIN(N) returns an N-point Tukey window in a column vector.
% 
%   W = TUKEYWIN(N,R) returns an N-point Tukey window in a column vector. A
%   Tukey window is also known as the cosine-tapered window.  The R
%   parameter specifies the ratio of the length of taper section to the
%   total length of the window. For a Tukey window, R is normalized to 1
%   (i.e., 0 < R < 1). If omitted, R is set to 0.500.
%   
%   If R is outside the region of (0, 1), the Tukey window degenerates into
%   other common windows. Thus when R = 1, it is equivalent to a Hanning
%   window. Conversely, for R = 0 the Tukey window is equivalent to a
%   boxcar window.
%
%   EXAMPLE:
%      N = 64; 
%      w = tukeywin(N,0.5); 
%      plot(w); title('64-point Tukey window, Ratio = 0.5');
%
%   See also CHEBWIN, GAUSSWIN, KAISER, WINDOW.

%   Reference:
%     [1] fredric j. harris [sic], On the Use of Windows for Harmonic Analysis
%         with the Discrete Fourier Transform, Proceedings of the IEEE,
%         Vol. 66, No. 1, January 1978, Page 67, Equation 38.

%   Author(s): A. Dowd
%   Copyright 1988-2019 The MathWorks, Inc.

%#codegen

narginchk(1,2);

if coder.target('MATLAB')
    switch nargin
        case 1
            w = eTukeywin(N);
        case 2
            w = eTukeywin(N,r);
    end
else
    switch nargin
        case 1
            if coder.internal.isConst(N) && coder.internal.isCompiled
                % code generation for constant input args
                w = coder.const(@feval,'tukeywin',N);
            else
                % code generation for variable input args
                w = eTukeywin(N);
            end
        case 2
            if coder.internal.isConst(N) && coder.internal.isConst(r) && coder.internal.isCompiled
                % code generation for constant input args
                w = coder.const(@feval,'tukeywin', N, r);
            else
                % code generation for variable input args
                w = eTukeywin(N, r);
            end
    end
end

end

function w = eTukeywin(N,r)

validateattributes(N,{'numeric'},{'real','finite'},'tukeywin','N');
N = signal.internal.sigcasttofloat(N,'double','tukeywin','order','allownumeric');

[N,w,trivialwin] = check_order(N);
if trivialwin
    return;
end

% Default value for R parameter.
if nargin < 2 || isempty(r) 
    ratio = 0.500;
else
    validateattributes(r,{'numeric'},{'scalar','real','finite'},'tukeywin','r',2);
    ratio = r(1);
end

L = N(1); % codegeneration special case: Ensure order is scalar
if ratio <= 0
    w = ones(L,1);
elseif ratio >= 1
    w = hann(L);
else
    t = linspace(0,1,L)';
    % Defines period of the taper as 1/2 period of a sine wave.
    per = ratio/2; 
    tl = floor(per*(L-1))+1;
    th = L-tl+1;
    % Window is defined in three sections: taper, constant, taper
    w = [ ((1+cos(pi/per*(t(1:tl) - per)))/2);  ones(th-tl-1,1); ((1+cos(pi/per*(t(th:end) - 1 + per)))/2)];
end

end


% [EOF]

% LocalWords:  Tukey fredric harris Dowd allownumeric
