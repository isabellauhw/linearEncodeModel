function [h,a]=firls(varargin)
% FIRLS Linear-phase FIR filter design using least-squares error minimization.
%   B=FIRLS(N,F,A) returns a length N+1 linear phase (real, symmetric
%   coefficients) FIR filter which has the best approximation to the
%   desired frequency response described by F and A in the least squares
%   sense. F is a vector of frequency band edges in pairs, in ascending
%   order between 0 and 1. 1 corresponds to the Nyquist frequency or half
%   the sampling frequency. A is a real vector the same size as F
%   which specifies the desired amplitude of the frequency response of the
%   resultant filter B. The desired response is the line connecting the
%   points (F(k),A(k)) and (F(k+1),A(k+1)) for odd k; FIRLS treats the
%   bands between F(k+1) and F(k+2) for odd k as "transition bands" or
%   "don't care" regions. Thus the desired amplitude is piecewise linear
%   with transition bands.  The integrated squared error is minimized.
%
%   For filters with a gain other than zero at Fs/2, e.g., highpass
%   and bandstop filters, N must be even.  Otherwise, N will be
%   incremented by one. Alternatively, you can use a trailing 'h' flag to
%   design a type 4 linear phase filter and avoid incrementing N.
%
%   B=FIRLS(N,F,A,W) uses the weights in W to weight the error. W has one
%   entry per band (so it is half the length of F and A) which tells
%   FIRLS how much emphasis to put on minimizing the integral squared error
%   in each band relative to the other bands.
%
%   B=FIRLS(N,F,A,'Hilbert') and B=FIRLS(N,F,A,W,'Hilbert') design filters
%   that have odd symmetry, that is, B(k) = -B(N+2-k) for k = 1, ..., N+1.
%   A special case is a Hilbert transformer which has an approx. amplitude
%   of 1 across the entire band, e.g. B=FIRLS(30,[.1 .9],[1 1],'Hilbert').
%
%   B=FIRLS(N,F,A,'differentiator') and B=FIRLS(N,F,A,W,'differentiator')
%   also design filters with odd symmetry, but with a special weighting
%   scheme for non-zero amplitude bands. The weight is assumed to be equal
%   to the inverse of frequency, squared, times the weight W. Thus the
%   filter has a much better fit at low frequency than at high frequency.
%   This designs FIR differentiators.
%
%   % Example of a length 31 lowpass filter.
%   h=firls(30,[0 .1 .2 .5]*2,[1 1 0 0]);
%   fvtool(h);
%
%   % Example of a length 45 lowpass differentiator.
%   h=firls(44,[0 .3 .4 1],[0 .2 0 0],'differentiator');
%   fvtool(h);
%
%   % Example of a length 26 type 4 highpass filter.
%   h=firls(25,[0 .4 .5 1],[0 0 1 1],'h');
%   fvtool(h);
%
%   See also FIRPM, FIR1, FIR2, FREQZ, FILTER, DESIGNFILT.

%       Author(s): T. Krauss
%   History: 10-18-91, original version
%            3-30-93, updaited
%            9-1-95, optimize adjacent band case
%   Copyright 1988-2018 The MathWorks, Inc.

% Copyright 2008-2018 The MathWorks, Inc.

%#codegen

% number of arguments check
narginchk(3,5);

if coder.target('MATLAB')
    [h,a] = eFirls(varargin{:});
    
else
    % check for constant input arguments
    allConst = true;
    coder.unroll();
    for k = 1:nargin
        allConst = allConst && coder.internal.isConst(varargin{k});
    end
    if allConst && coder.internal.isCompiled
        % codegen for constant input arguments
        [h,a] = coder.const(@feval,'firls',varargin{:});
    else
        % codegen for variable input argument
        [h,a] = eFirls(varargin{:});
    end
end


end

function [h,a]= eFirls(N,freq,amp,W,ftype)
%#codegen

% check number of arguments, set up defaults.
narginchk(3,5);

% Flag to check if target is MATLAB
isTargetMATLAB = coder.target('MATLAB');

% Validate attributes for N, F, A
validateattributes(N,{'numeric'},{'scalar','real','finite','positive','nonempty'},'firls','n',1);
validateattributes(freq,{'numeric'},{'vector','real','finite','nonempty'},'firls','f',2);
validateattributes(amp,{'numeric'},{'vector','real','finite','nonempty'},'firls','a',3);

% Cast to enforce precision rules N, F and A
N = double(N(1));
freq = double(freq);
amp = double(amp);

freq_length = length(freq);

% check of variable arguments W and ftype
if nargin > 4
    if isempty(W)
        weight = ones(floor(freq_length/2),1);
    else
        weight = W(:);
    end
    ftype = convertStringsToChars(ftype);
elseif nargin == 4
    if isnumeric(W)
        ftype = '';
        weight = W(:);
    elseif ischar(W) || isstring(W)
        ftype = char(W);
        weight = ones(floor(freq_length/2),1);
    end
elseif nargin == 3
    ftype = '';
    weight = ones(floor(freq_length/2),1);
end

% validate ftype
ok = false;
filtype = 0;
differ = 0;

if isempty(ftype)
    filtype = 0;
    differ = 0;
else
    if strcmpi(ftype,'h') || strcmpi(ftype,'hilbert')
        filtype = 1;
        differ = 0;
        ok = true;
    elseif strcmpi(ftype,'d') || strcmpi(ftype,'differentiator')
        filtype = 1;
        differ = 1;
        ok = true;
    end
    coder.internal.assert(ok,'signal:firls:InvalidEnum');
end

% Cast to enforce precision rules W
validateattributes(weight,{'numeric'},{'vector','finite','nonempty'},'firls','w',4);
weight = cast(weight,'double');

max_freq = max(freq,[],2);
min_freq = min(freq,[],2);

% check validity of input F and A
if (max_freq(1,1) > 1) || (min_freq(1,1) < 0)
    coder.internal.error('signal:firls:InvalidRange');
    return
end

if ~isTargetMATLAB % code generation
    coder.internal.errorIf((rem(freq_length,2)~=0),'signal:firls:MustHaveEvenLength','F');
    coder.internal.errorIf((freq_length ~= length(amp)),'signal:firls:UnequalLengths','F','A');
    % check for valid filter length
    N = firchk(N,freq(end),amp,filtype);
else % MATLAB Execution
    if (rem(freq_length,2)~=0)
        error(message('signal:firls:MustHaveEvenLength', 'F'));
    end
    if (freq_length ~= length(amp))
        error(message('signal:firls:UnequalLengths', 'F', 'A'));
    end
    [N,msg1,msg2,msgobj] = firchk(N,freq(end),amp,filtype);
    if ~isempty(msg1)
        error(msgobj);
    end
    if ~isempty(msg2)
        warning(msgobj);
    end
end

% filter length
N = N + 1;

F = freq(:)/2;
A = amp(:);

wt = abs(sqrt(complex(weight)));

% difference of F
dF = diff(F);

% check validity of F and weight
if isTargetMATLAB
    if ~((freq_length == length(wt)*2))
        error(message('signal:firls:InvalidDimensions'));
    end
else % code generation
    coder.internal.assert((freq_length == length(wt)*2),'signal:firls:InvalidDimensions');
    % Define variable size local variables
    coder.varsize('b','k','do_weight','m','h');
end

if any(dF<0)
    coder.internal.error('signal:firls:InvalidFreqVec');
end

% Fix for 67187
% length of Diff(F) = length(F) - 1;
lendF = freq_length - 1;
if (lendF) > 1
    fullband = true;
    for i = 2:2:lendF
        if dF(i) ~= 0
            fullband = false;
            break
        end
    end
    
else
    fullband = false;
end

% validate weight
tempW = wt - wt(1);
if sum(tempW(:)) == 0
    constant_weights = true;
else
    constant_weights = false;
end

% find the order
L = (N(1) - 1)/2;

% odd order
Nodd = (rem(N,2) == 1);

% initialize b0
b0 = 0;

% Type I and Type II linear phase FIR
if filtype == 0
    % Basis vectors are cos(2*pi*m*f)
    if ~Nodd
        m = (0:L)+.5;   % type II
    else
        m = (0:L);      % type I
    end
    k = m';
    need_matrix = (~fullband) || (~constant_weights);
    
    if ~isTargetMATLAB % Only for generating code.
        % preallocate I1,I2 and G matrices
        fl = floor(L+1);
        I1 = zeros(fl);
        I2 = zeros(fl);
        G = zeros(size(I1));
    end
    
    if need_matrix
        I1 = k(:,ones(size(m))) + m(ones(size(k)),:);    % entries are m + k
        I2 = k(:,ones(size(m))) - m(ones(size(k)),:);    % entries are m - k
        if isTargetMATLAB % target MATLAB
            G = zeros(size(I1));
        end
    end
    
    if Nodd
        k = k(2:length(k));
        b0 = 0;       %  first entry must be handled separately (where k(1)=0)
    end
    
    % preallocate b matrix
    b = zeros(size(k));
    
    for s = 1:2:length(F)
        m_s = ( A(s+1)-A(s) )/( F(s+1)-F(s) );    %  slope
        b1 = A(s) - m_s * F(s);                   %  y-intercept
        if Nodd
            b0 = b0 + (b1*(F(s+1)-F(s)) + m_s/2*(F(s+1)*F(s+1)-F(s)*F(s)))...
                * (wt((s+1)/2)^2) ;
        end
        b = b + (m_s/(4*pi*pi)*(cos(2*pi*k*F(s+1))-cos(2*pi*k*F(s)))./(k.*k))...
            * (wt((s+1)/2)^2);
        b = b + (F(s+1)*(m_s*F(s+1)+b1)*sinc(2*k*F(s+1)) ...
            - F(s)*(m_s*F(s)+b1)*sinc(2*k*F(s))) ...
            * (wt((s+1)/2)^2);
        if need_matrix
            G = G + (.5*F(s+1)*(sinc(2*I1*F(s+1))+sinc(2*I2*F(s+1))) ...
                - .5*F(s)*(sinc(2*I1*F(s))+sinc(2*I2*F(s))) ) ...
                * (wt((s+1)/2)^2);
        end
    end
    if Nodd
        b = [b0; b];
    end
    
    if need_matrix
        a = (G\b);
    else
        a = ((wt(1)^2)*4*b);
        if Nodd
            a(1) = a(1)/2;
        end
    end
    if Nodd
        h = [a(L+1:-1:2)/2; a(1); a(2:L+1)/2]';
    else
        h = .5*[flipud(a); a]';
    end
    
elseif (filtype == 1)  % Type III and Type IV linear phase FIR
    %  basis vectors are sin(2*pi*m*f) (see m below)
    if (differ)      % weight non-zero bands with 1/f^2
        do_weight = double(( abs(A(1:2:length(A))) +  abs(A(2:2:length(A))) ) > 0);
    else
        do_weight = zeros(size(F));
    end
    
    if Nodd
        m=(1:L);      % type III
        if ~isTargetMATLAB
            fl = floor(L);
            I1 = zeros(fl);
            I2 = zeros(fl);
            G = zeros(size(I1));
        end
    else
        m=(0:L)+.5;   % type IV
        if ~isTargetMATLAB
            fl = floor(L+1);
            I1 = zeros(fl);
            I2 = zeros(fl);
            G = zeros(size(I1));
        end
    end
    k = m';
    b = zeros(size(k));
    
    need_matrix = (~fullband) ||(any(do_weight)) || (~constant_weights);
    if need_matrix
        I1=k(:,ones(size(m)))+m(ones(size(k)),:);    % entries are m + k
        I2=k(:,ones(size(m)))-m(ones(size(k)),:);    % entries are m - k
        if isTargetMATLAB
            G=zeros(size(I1));
        end
    end
    
    for s=1:2:length(F)
        if (do_weight((s+1)/2))      % weight bands with 1/f^2
            if F(s) == 0 % avoid singularities
                F(s) = 1e-5;
            end
            m_s=(A(s+1)-A(s))/(F(s+1)-F(s));
            b1=A(s)-m_s*F(s);
            snint1 = sineint(2*pi*k*F(s+1)) - sineint(2*pi*k*F(s));
            csint1 = real((-1/2)*(expint(1i*2*pi*k*F(s+1))+expint(-1i*2*pi*k*F(s+1))...
                -expint(1i*2*pi*k*F(s))  -expint(-1i*2*pi*k*F(s)) ));
            b=b + ( m_s*snint1 ...
                + b1*2*pi*k.*( -sinc(2*k*F(s+1)) + sinc(2*k*F(s)) + csint1 ))...
                * (wt((s+1)/2)^2);
            snint1 = sineint(2*pi*F(s+1)*(-I2));
            snint2 = sineint(2*pi*F(s+1)*I1);
            snint3 = sineint(2*pi*F(s)*(-I2));
            snint4 = sineint(2*pi*F(s)*I1);
            G = G - ( ( -1/2*( cos(2*pi*F(s+1)*(-I2))/F(s+1)  ...
                - 2*snint1*pi.*I2 ...
                - cos(2*pi*F(s+1)*I1)/F(s+1) ...
                - 2*snint2*pi.*I1 )) ...
                - ( -1/2*( cos(2*pi*F(s)*(-I2))/F(s)  ...
                - 2*snint3*pi.*I2 ...
                - cos(2*pi*F(s)*I1)/F(s) ...
                - 2*snint4*pi.*I1) ) ) ...
                * (wt((s+1)/2)^2);
        else      % use usual weights
            m_s = (A(s+1)-A(s))/(F(s+1)-F(s));
            b1=A(s)-m_s*F(s);
            b=b+(m_s/(4*pi*pi)*(sin(2*pi*k*F(s+1))-sin(2*pi*k*F(s)))./(k.*k))...
                * (wt((s+1)/2)^2) ;
            b = b + (((m_s*F(s)+b1)*cos(2*pi*k*F(s)) - ...
                (m_s*F(s+1)+b1)*cos(2*pi*k*F(s+1)))./(2*pi*k)) ...
                * (wt((s+1)/2)^2) ;
            if need_matrix
                G = G + (.5*F(s+1)*(sinc(2*I1*F(s+1))-sinc(2*I2*F(s+1))) ...
                    - .5*F(s)*(sinc(2*I1*F(s))-sinc(2*I2*F(s)))) * ...
                    (wt((s+1)/2)^2);
            end
        end
    end
    
    if need_matrix
        a=(G\b);
    else
        a=(-4*b*(wt(1)^2));
    end
    if Nodd
        h=.5*[flipud(a); 0; -a]';
    else
        h=.5*[flipud(a); -a]';
    end
    if differ
        h=-h;
    end
else
    h = 0;
end
if nargout > 1
    a = 1;
end

end

%% SINEINT (a.k.a. SININT)   Numerical Sine Integral
function y = sineint(x)

%   Used by FIRLS in the Signal Processing Toolbox.
%   Untested for complex or imaginary inputs.
%
%   See also SININT in the Symbolic Toolbox.

%   Was Revision: 1.5, Date: 1996/03/15 20:55:51

isTargetMATLAB = coder.target('MATLAB');
real_x = real(x) < 0;

if isTargetMATLAB
    i1 = find(real_x);
    x(i1) = -x(i1);
    y = zeros(size(x));
    ind = find(x);
else
    [m,n] = size(x);
    q = zeros(m*n,1);
    count = 1;
    for k = 1:length(q)
        if real_x(k) == 1
            q(count) = k;
            count = count + 1;
        end
    end
    
    L = count - 1;
    i1 = zeros(L,1);
    for e = 1:L
        i1(e) = q(e);
    end
    x(i1) = -x(i1);
    y = zeros(size(x));
    
    count = 1;
    for k = 1:length(q)
        if x(k) ~= 0
            q(count) = k;
            count = count + 1;
        end
    end
    L = count - 1;
    ind = zeros(L,1);
    for e = 1:L
        ind(e) = q(e);
    end
end

% equation 5.2.21 Abramowitz & Stegun
%  y(ind) = (1/(2*i))*(expint(1i*x(ind)) - expint(-i*x(ind))) + pi/2;
y(ind) = imag(expint(1i*x(ind))) + pi/2;
y(i1) = -y(i1);
end



% EOF firls.m

% LocalWords:  Fs DESIGNFILT Krauss updaited allownumeric ftype Vec snint csint
% LocalWords:  SINEINT Abramowitz Stegun FIRCHK firchk

% EOF firls.m

% LocalWords:  Fs DESIGNFILT Krauss updaited allownumeric ftype Vec snint csint
% LocalWords:  SINEINT Abramowitz Stegun FIRCHK firchk
