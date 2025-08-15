function sos = getWeightingFilter(Weighting, EffectiveFs)
% Determine A/C Weighting numerator and denominator coefficients from
% analog poles and zeros
if strcmpi(Weighting,'A')
    % Zeros, poles and gain according to ANSI S1.42 standard for
    % A-weighting, and IEC 61672 standard.
    p1 = -20.598997*2*pi;
    p2 = -107.65265*2*pi;
    p3 = -737.86223*2*pi;
    p4 = -12194.217*2*pi;
    
    zW= zeros(4,1);
    pW = [p1; p1;  p2; p3; p4; p4];
    
    C = 10^(1.9997/20);
    kW = C*(pW(6)^2);
elseif strcmpi(Weighting,'C')
    % Zeros, poles and gain according to ANSI S1.42 standard for
    % C-weighting, and IEC 61672 standard.
    p1 = -20.598997*2*pi;
    p2 = -12194.217*2*pi;
    
    zW= zeros(2,1);
    pW = [p1; p1;  p2; p2];
    
    C = 10^(0.0619/20);
    kW = C*(pW(3)^2);
end

% Convert analog zeros and poles to a digital transfer function using the
% bilinear transformation
[z,p,k] = bilinear(zW,pW,kW,EffectiveFs);
sos = zp2sos(z,p,k);
