function n = filtord(b,varargin)
%FILTORD Filter order
%   N = FILTORD(B,A) returns the order, N, of the filter:
%
%               jw               -jw              -jmw
%        jw  B(e)    b(1) + b(2)e + .... + b(m+1)e
%     H(e) = ---- = ------------------------------------
%               jw               -jw              -jnw
%            A(e)    a(1) + a(2)e + .... + a(n+1)e
%
%   given numerator and denominator coefficients in vectors B and A.
%
%   N = FILTORD(SOS) returns order, N, of the filter specified using the
%   second order sections matrix SOS. SOS is a Kx6 matrix, where the number
%   of sections, K, must be greater than or equal to 2. Each row of SOS
%   corresponds to the coefficients of a second order filter. From the
%   transfer function displayed above, the ith row of the SOS matrix
%   corresponds to [bi(1) bi(2) bi(3) ai(1) ai(2) ai(3)].
%
%   N = FILTORD(D) returns order, N, of the digital filter D. You design a
%   digital filter, D, by calling the <a href="matlab:help designfilt">designfilt</a> function.
%
%   % Example 1:
%   %   Create a 25th-order lowpass FIR filter and verify its order using
%   %   filtord.
%
%   b = fir1(25,0.45);
%   n = filtord(b)
%
%   % Example 2:
%   %   Create a 6th-order lowpass IIR filter using second order sections
%   %   and verify its order using filtord.
%
%   [z,p,k] = butter(6,0.35);
%   SOS = zp2sos(z,p,k);	% second order sections matrix
%   n = filtord(SOS)
%
%   % Example 3:
%   %   Use the designfilt function to design a highpass IIR digital filter
%   %   with order 8, passband frequency of 75 KHz, and a passband ripple
%   %   of 0.2 dB. Use filtord to get the filter order.
%
%   D = designfilt('highpassiir', 'FilterOrder', 8, ...
%            'PassbandFrequency', 75e3, 'PassbandRipple', 0.2,...
%            'SampleRate', 200e3);
%
%   n = filtord(D)
%
%   See also FVTOOL, ISALLPASS, ISLINPHASE, ISMAXPHASE, ISMINPHASE, ISSTABLE

%   Copyright 2012-2018 The MathWorks, Inc.
%#codegen

narginchk(1,2);

if coder.target('MATLAB')
    % MATLAB
    n = efiltord(b,varargin{:});
else
    % Code generation  
    if nargin == 1
        allConst = coder.internal.isConst(b);
    else
        allConst = coder.internal.isConst(b) && coder.internal.isConst(varargin{1});
    end
    
    if allConst && coder.internal.isCompiled
        % Constant Inputs
        n = coder.const(@feval,'filtord',b,varargin{:});        
    else
        % Variable Inputs
        n = efiltord(b,varargin{:});
    end    
end

end

function n = efiltord(b,varargin)

if nargin == 1
    a = 1; % Assume FIR for now
else
    a = varargin{1};
end

validateattributes(b,{'double','single'},{'2d'},'filtord');
validateattributes(a,{'double','single'},{'2d'},'filtord');

% Cast to precision rules
% Single/double datatype check and conversion
if isa(b,'single') || isa(a,'single')
    convClass = 'single';
else
    convClass = 'double';
end

b = cast(b,convClass);
a = cast(a,convClass);

coder.varsize('b1','a1');

% If b is SOS or vector,
if nargin == 1
    a1 = a;
    if isvector(b)
        % If input is column vector transpose to obtain row vectors
        if iscolumn(b)
            b1 = b.';
        else
            b1 = b;
        end
    else
        % If input is a matrix, check if it is a valid SOS matrix
        coder.internal.errorIf(size(b,2) ~= 6,'signal:signalanalysisbase:invalidinputsosmatrix');
         
        % Get transfer function
        [b1,a1] = sos2tf(b);
    end
    
else    % If b and a are vectors
    
    % If b is not a vector, then only one input is supported
    coder.internal.errorIf(size(b,1)>1 && size(b,2)>1,'signal:signalanalysisbase:invalidNumInputs');
    
    % If a is not a vector
    coder.internal.errorIf(size(a,1)>1 && size(a,2)>1,'signal:signalanalysisbase:inputnotsupported');
    
    
    b1 = b;
    a1 = a;
    
    % If input is column vector transpose to obtain row vectors
    if iscolumn(b)
        b1 = b.';
    end
    
    if iscolumn(a)
        a1 = a.';
    end
end

% Normalizing the filter coefficients
if ~isempty(b1)
    maxCoefNum = max(abs(b1),[],2);
    if maxCoefNum ~= 0
        b1 = b1/maxCoefNum(1);
    end
end

if ~isempty(a1)
    maxCoefDen = max(abs(a1),[],2);
    if maxCoefDen ~= 0
        a1 = a1/maxCoefDen(1);
    end
end

nZeroLastNum = 0;
nZeroLastDen = 0;

% Returning the index of the last nonzero coefficient
if ~isempty(b1)
    nZeroLastDen = find(b1(:)~=0, 1, 'last');
end

if ~isempty(a1)
    nZeroLastNum = find(a1(:)~=0, 1, 'last');
end

if isempty(nZeroLastDen)
    nZeroLastDen = 0;
end

if isempty(nZeroLastNum)
    nZeroLastNum = 0;
end

% filter order n is maximum of the last nonzero coefficient subtracted by 1
n = max(nZeroLastNum(1),nZeroLastDen(1)) - 1;

end

% LocalWords:  allownumeric signalanalysisbase inputnotsupported jw jmw jnw ith
% LocalWords:  invalidinputsosmatrix ai designfilt th IIR highpassiir
