function [fosNum, fosDen] = octaveFilterDesigner(N, Fc, b, Fs)
%octaveFilterDesigner Design octave and fractional octave band filters.
%   octaveFilterDesigner designs an octave-band or fractional octave-band
%   filter with filter order N, center-frequency Fc, bands-per-octave b,
%   and sample rate Fs.

%   Copyright 2017 MathWorks, Inc.

%   This function is for internal use only. It may be removed.

 %#codegen

inputDT = class(N);

% Cast constants to correct data type
one_cast = cast(1, inputDT);
two_cast = cast(2, inputDT);
three_cast = cast(3, inputDT);
ten_cast = cast(10, inputDT);
pi_cast = cast(pi, inputDT);

Fc = Fc/(Fs/two_cast); % Normalize center frequency
G = ten_cast^(three_cast/ten_cast);

% Compute band-edge frequencies
f1 = Fc*(G^(-one_cast/(two_cast*b))); 
f2 = Fc*(G^(one_cast/(two_cast*b))); 

% Analog specs
c = sin(pi_cast*(f1+f2))/(sin(pi_cast*f1)+sin(pi_cast*f2));
wc = (c - cos(pi_cast*f2))/sin(pi_cast*f2);

% Design digital filter
[fosNum, fosDen] = bld(N, wc, c, inputDT);

end

function [fosNum, fosDen] = bld(N, wc, c, inputDT)
% Design digital filter from analog specs using bilinear. Returns
% fourth-order sections

zero_cast = cast(0, inputDT);
one_cast = cast(1, inputDT);
two_cast = cast(2, inputDT);
four_cast = cast(4, inputDT);
five_cast = cast(5, inputDT);
pi_cast = cast(pi, inputDT);

% Compute cos of stable poles
k = (one_cast:floor(N/four_cast)).';
theta = pi_cast/(two_cast*N/two_cast)*(N/two_cast-one_cast+two_cast*k);
cs = cos(theta);

% Compute den coeffs
wccs = wc*cs;
wccs2 = two_cast*wc*cs;
wc2 = wc^two_cast;
den = one_cast-wccs2+wc2;
ai1 = four_cast*c*(wccs-one_cast)./den;
ai2 = two_cast*(two_cast*c^2+one_cast-wc2)./den;
ai3 = -four_cast*c*(wccs+one_cast)./den;
ai4 = (one_cast+wccs2+wc2)./den;

fog = wc2./den; % Fourth-order gains

msf = floor(N/four_cast);
fosNum = zeros(msf+(rem(N,four_cast)>0),five_cast, inputDT);
fosDen = zeros(size(fosNum), inputDT);

idx = 1;
if rem(N,four_cast)
    % Create a SOS section
    fosNum(1,:) = [one_cast, zero_cast, -one_cast, zero_cast, zero_cast] * wc/(wc+one_cast);
    fosDen(1,:) = [one_cast, -two_cast*c/(wc + one_cast), (one_cast - wc)/(wc + one_cast), zero_cast, zero_cast];
    idx = idx + 1;
end

fosNum(idx:end,:) = repmat([one_cast, zero_cast, -two_cast, zero_cast, one_cast],msf,one_cast) .* repmat(fog,one_cast,five_cast);
fosDen(idx:end,:) = [ones(msf,one_cast),ai1,ai2,ai3,ai4];

end