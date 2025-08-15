function lsf = poly2lsf(a)
%POLY2LSF Prediction polynomial to line spectral frequencies.
%   LSF = POLY2LSF(A) converts the prediction polynomial specified by A,
%   into the corresponding line spectral frequencies, LSF.
%
%   POLY2LSF normalizes the prediction polynomial by A(1).
%
%   % Example:
%   %   Convert the following prediction filter polynomial to spectral
%   %   frequencies:
%   %   a = [1.0000   0.6149   0.9899   0.0000   0.0031  -0.0082];
%
%   a = [1.0000  0.6149  0.9899  0.0000  0.0031 -0.0082];
%   lsf = poly2lsf(a)   % Line spectral frequencies
%
%   See also LSF2POLY, POLY2RC, POLY2AC, RC2IS.

%   Reference:
%   A.M. Kondoz, "Digital Speech: Coding for Low Bit Rate Communications
%   Systems" John Wiley & Sons 1994, Chapter 4.
%
%   Copyright 1988-2018 The MathWorks, Inc.

%#codegen

if ~isvector(a)
    coder.internal.assert(false, 'signal:poly2lsf:inputnotsupported');
end

if any(signal.internal.sigcheckfloattype(a,'single','poly2lsf',...
        'A(prediction polynomial)'))
    a_temp = single(a);
else
    a_temp = a;
end

if ~isreal(a_temp)
    coder.internal.assert(false,'signal:poly2lsf:NotSupported');
end

a_temp  = a_temp(:);

% Normalize the polynomial if a(1) is not unity

if a_temp(1) ~= 1.0
    a_temp = a_temp./a_temp(1);
end

if (max(abs(roots(a_temp))) >= 1.0)
    coder.internal.error('signal:poly2lsf:SignalErr');
end

% Form the sum and difference filters

p  = length(a_temp) - 1;  % The leading one in the polynomial is not used
a1 = [a_temp;0];
a2 = a1(end:-1:1);
P1 = a1-a2;        % Difference filter
Q1 = a1+a2;        % Sum Filter

% If order is even, remove the known root at z = 1 for P1 and z = -1 for Q1
% If odd, remove both the roots from P1

if isodd(p)  % Odd order
    P = deconv(P1,[1 0 -1]);
    Q = Q1;
else          % Even order
    P = deconv(P1,[1 -1]);
    Q = deconv(Q1,[1  1]);
end

rP  = roots(P);
rQ  = roots(Q);
 
% considering complex conjugate roots along with zeros for finding aP and
% aQ 
aP  = angle(rP(:,[1 1]));
aQ  = angle(rQ(:,[1 1]));

lsf_temp = sort([aP(aP >= 0);aQ(aQ >= 0)]); % considering positive angles
lsf =lsf_temp(1:2:end);

end
% [EOF] poly2lsf.m