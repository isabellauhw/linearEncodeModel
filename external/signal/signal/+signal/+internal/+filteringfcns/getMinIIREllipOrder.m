function [N, successFlag] = getMinIIREllipOrder(aWpass,aWstop,Apass,Astop)
%getMinIIREllipOrder Get minimum order that meets specs for an IIR ellip filter
%    aWpass - analog passband frequency
%    aWstop - analog stopband frequency
%    Apass - passband ripple in dB
%    Astop - stopband attenuation in dB

%   Copyright 2017 MathWorks, Inc.

%   This function is for internal use only. It may be removed.

successFlag = true;

Wp = aWpass;
Ws = aWstop;

% Compute cutoff
Wc = sqrt(Wp*Ws);

% Normalize passband-edge
Wpc = Wp/Wc;

% Determine min order
q = computeq(Wpc);
D = (10^(0.1*Astop) - 1)/(10^(0.1*Apass) - 1);
N = ceil(log10(16*D)/log10(1/q));

if N <=0
    successFlag = false;
    N = 2;
end

%--------------------------------------------------------------------------
function q = computeq(Wp)

Ws = 1/Wp;
k = Wp/Ws;

k1 = sqrt(1 - k^2);
q0 = 0.5*(1 - sqrt(k1))/(1 + sqrt(k1));
q = q0 + 2*q0^5 + 15*q0^9 + 150*q0^13;
