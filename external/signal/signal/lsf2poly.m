function a = lsf2poly(lsf)
%LSF2POLY  Line spectral frequencies to prediction polynomial.
%   A = LSF2POLY(LSF) returns the prediction polynomial, A, based on the line
%   spectral frequencies, LSF.
%
%   % Example:
%   %   Convert the following line spectral frequencies to prediction
%   %   filter coefficients:
%   %   lsf = [0.7842    1.5605    1.8776    1.8984    2.3593];
%
%   lsf = [0.7842    1.5605    1.8776    1.8984    2.3593];
%   a = lsf2poly(lsf)
%
%   See also POLY2LSF, RC2POLY, AC2POLY, RC2IS.

%   Reference:
%   A.M. Kondoz, "Digital Speech: Coding for Low Bit Rate Communications
%   Systems" John Wiley & Sons 1994 ,Chapter 4
%
%   Copyright 1988-2018 The MathWorks, Inc.

%#codegen

% Check the input data type.
if any(signal.internal.sigcheckfloattype(lsf,'single','poly2lsf',...
        'LSF(Line spectral frequencies)'))
    lsf = single(lsf);
end

if (~isreal(lsf))
    coder.internal.error('signal:lsf2poly:MustBeReal');
end

if isvector(lsf)
    lsf_vector = lsf(:);
else
    lsf_vector = lsf;
end

nchannels = size(lsf_vector,2);
a_vector = complex(zeros(nchannels,size(lsf_vector,1)+1,class(lsf)));
coder.varsize('temp_lsf');

for m = 1:nchannels
    
    temp_lsf = lsf_vector(:,m);
    
    if (max(temp_lsf) > pi || min(temp_lsf) < 0)
        coder.internal.error('signal:lsf2poly:InvalidRange');
    end
    
    temp_lsf = temp_lsf(:);
    p = length(temp_lsf); % This is the model order
    
    % Form zeros using the LSFs and unit amplitudes
    z  = exp(1i*temp_lsf);
    
    % Separate the zeros to those belonging to P and Q
    rQ = z(1:2:end);
    rP = z(2:2:end);
    
    % Include the conjugates as well
    rQ = [rQ;conj(rQ)]; %#ok<AGROW>
    rP = [rP;conj(rP)]; %#ok<AGROW>
    
    % Form the polynomials P and Q, note that these should be real
    Q  = real(poly(rQ));
    P  = real(poly(rP));
    
    % Form the sum and difference filters by including known roots at z = 1 and
    % z = -1
    
    if isodd(p)
        % Odd order: z = +1 and z = -1 are roots of the difference filter, P1(z)
        P1 = conv2(P,[1 0 -1]);
        Q1 = Q;
    else
        % Even order: z = -1 is a root of the sum filter, Q1(z) and z = 1 is a
        % root of the difference filter, P1(z)
        P1 = conv2(P,[1 -1]);
        Q1 = conv2(Q,[1  1]);
    end
    
    % Prediction polynomial is formed by averaging P1 and Q1
        
    a = .5*(P1 + Q1);
    a(end) = []; % The last coefficient is zero and is not returned
    
    a_vector(m,:) = a;
end

a = a_vector;
% [EOF] lsf2poly.m
