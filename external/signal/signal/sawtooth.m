function y = sawtooth(t,width)%#codegen
%SAWTOOTH Sawtooth and triangle wave generation.
%   SAWTOOTH(T) generates a sawtooth wave with period 2*pi for the
%   elements of time vector T.  SAWTOOTH(T) is like SIN(T), only
%   it creates a sawtooth wave with peaks of +1 to -1 instead of
%   a sine wave.
%
%   SAWTOOTH(T,WIDTH) generates a modified triangle wave where WIDTH, a
%   scalar parameter between 0 and 1, determines the fraction between 0
%   and 2*pi at which the maximum occurs. The function increases from -1
%   to 1 on the interval 0 to WIDTH*2*pi, then decreases linearly from 1
%   back to -1 on the interval WIDTH*2*pi to 2*pi. Thus WIDTH = .5 gives
%   you a triangle wave, symmetric about time instant pi with peak amplitude
%   of one.  SAWTOOTH(T,1) is equivalent to SAWTOOTH(T).
%
%   Caution: this function is inaccurate for huge numerical inputs
%
%   See also SQUARE, SIN, COS, CHIRP, DIRIC, GAUSPULS, PULSTRAN, RECTPULS,
%   SINC and TRIPULS.

%   Copyright 1988-2019 The MathWorks, Inc.

narginchk(1,2);
if nargin == 1
    width = 1;
end

% 't' input must be real
validateattributes(t,{'single','double'},{'real'},mfilename,'t',1);
% 'width' input must be a real scalar between 0 and 1
validateattributes(width,{'numeric'},{'real','scalar','>=',0,'<=',1},mfilename,'width',2);

widthScalar = width(1);
twoPi = cast(2*pi,class(t));
rt = rem(t,twoPi)*(1/twoPi);
y = coder.nullcopy(t);

if widthScalar > 0 && widthScalar < 1
    c1 = 2/widthScalar;
    c2 = 2/(1 - widthScalar);
else
    c1 = cast(2,'like',widthScalar);
    c2 = c1;
end

for idx=1:numel(t)
    if rt(idx)>0
        if rt(idx)>widthScalar
            y(idx) = (-(t(idx)<0) - rt(idx) + 1 - .5*(1-widthScalar))*c2;
        else
            y(idx) = ( (t(idx)<0) + rt(idx) - .5*widthScalar)*c1;
        end
    elseif rt(idx)<0
        if rt(idx)<widthScalar-1
            y(idx) = ( (t(idx)<0) + rt(idx) - .5*widthScalar)*c1;
        else
            y(idx) = (-(t(idx)<0) - rt(idx) + 1 - .5*(1-widthScalar))*c2;
        end
    elseif widthScalar > 0
        y(idx) = (rt(idx) - .5*widthScalar)*c1;
    else
        y(idx) = 1;
    end
end
end
