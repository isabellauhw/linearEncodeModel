function w = chebwin(n, r)
%MATLAB Code Generation Library Function

% Copyright 2008-2019 The MathWorks, Inc.
%#codegen
narginchk(1,2);

% Default value for R parameter.
if nargin < 2
    rVal = 100.0;
elseif isempty(r)
    rVal = cast(100.0,class(r));
else
    rVal = r;
end
validateattributes(rVal,{'numeric'},{'real','scalar','nonnegative'},mfilename,'r',2);           % 'r' input must be a real non-negative scalar
% Cast to enforce precision rules.
rScalar = double(rVal(1));

if isempty(n)
    w = zeros(0,1);
    return
else
    validateattributes(n,{'numeric'},{'real','scalar','finite','nonnegative'},mfilename,'n',1);	% 'n' input must be real finite scalar
    nScalar = double(n(1));
    
    if nScalar == 0
        w = zeros(0,1);
        return
    elseif nScalar == 1
        w = 1;
        return
    else
        % Check if order is already an integer If not, round to nearest
        % integer.
        if nScalar ~= floor(nScalar)
            nScalar = round(nScalar);
            coder.internal.warning('signal:chebwin:InvalidOrderRounding');
        end
        
        if mod(nScalar,2)==0
            middle = nScalar/2;
        else
            middle = (nScalar+1)/2;
        end
        
        % Convert dB attenuation
        b = 10^(rScalar/20);
        b = tanh( log(b + sqrt(b*b-1)) / (nScalar - 1));
        b = b*b;
        
        % Compute window weights
        w = coder.nullcopy(zeros(nScalar,1));
        wmax = 1/(nScalar-1);
        w(1)=wmax;
        w(nScalar)=wmax;
        
        % Pre-compute values of b/(k*(k+1)) for k=1 to middle-2 NOTE: If
        % N<=4, then middle=2 or less, and we do not allocate array for
        % kterm.
        if middle>2
            kterm = b./((1:1:middle-2).*(2:1:middle-1));
        else
            kterm = 0;
        end
        r_k0 = 2 - nScalar;
        for i=2:middle
            t=b;
            s=(0);
            s_old=(0);
            q_k = (i-1)*(nScalar-i);
            r_k = r_k0;
            for k=2:(i-1)
                q_k = q_k + r_k;
                r_k = r_k + 2;
                t = t * q_k * kterm(k-1);
                s = s + t;
                % terminate when t is too small to affect s.
                if s==s_old
                    break
                end
                s_old = s;
            end
            w(nScalar-i+1) = b + s;
            w(i) = w(nScalar-i+1);
            
            % Update maximum window value
            if w(i)>wmax
                wmax = w(i);
            end
        end
        
        % Normalize weights
        w = w/wmax;
    end
end
end