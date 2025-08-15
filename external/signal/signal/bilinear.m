function [zd, pd, kd, dd] = bilinear(z, p, k, fs, fp, fp1)
%BILINEAR Bilinear transformation with optional frequency prewarping.
%   [Zd,Pd,Kd] = BILINEAR(Z,P,K,Fs) converts the s-domain transfer
%   function specified by Z, P, and K to a z-transform discrete
%   equivalent obtained from the bilinear transformation:
%
%      H(z) = H(s) |
%                  | s = 2*Fs*(z-1)/(z+1)
%
%   where column vectors Z and P specify the zeros and poles, scalar
%   K specifies the gain, and Fs is the sample frequency in Hz.
%
%   [NUMd,DENd] = BILINEAR(NUM,DEN,Fs), where NUM and DEN are
%   row vectors containing numerator and denominator transfer
%   function coefficients, NUM(s)/DEN(s), in descending powers of
%   s, transforms to z-transform coefficients NUMd(z)/DENd(z).
%
%   [Ad,Bd,Cd,Dd] = BILINEAR(A,B,C,D,Fs) is a state-space version.
%
%   Each of the above three forms of BILINEAR accepts an optional
%   additional input argument that specifies prewarping.
%
%   For example, [Zd,Pd,Kd] = BILINEAR(Z,P,K,Fs,Fp) applies prewarping
%   before the bilinear transformation so that the frequency responses
%   before and after mapping match exactly at frequency point Fp
%   (match point Fp is specified in Hz).
%
%   % Example:
%   %   Design a 6-th order Elliptic analog low pass filter and transform
%   %   it to a Discrete-time representation.
%
%   Fs =0.5;                            % Sampling Frequency
%   [z,p,k]=ellipap(6,5,90);            % Lowpass filter prototype
%   [num,den]=zp2tf(z,p,k);             % Convert to transfer function form
%   [numd,dend]=bilinear(num,den,Fs);   % Analog to Digital conversion
%   fvtool(numd,dend)                   % Visualize the filter
%
%   See also IMPINVAR.

%   Author(s): J.N. Little, 4-28-87
%          J.N. Little, 5-5-87, revised
%   Copyright 1988-2019 The MathWorks, Inc.

%   Gene Franklin, Stanford Univ., motivated the state-space
%   approach to the bilinear transformation.
%#codegen
narginchk(3,6);
validateattributes(z,{'double','single'},{'2d'},'bilinear','',1);
validateattributes(p,{'double','single'},{'2d'},'bilinear','',2);
[mn,nn] = size(z);
[md,nd] = size(p);
if coder.target('MATLAB') % For MATLAB execution
    isZeroPoleGain = (nd == 1 && nn < 2) && nargout ~= 4;
    isStateSpace   =  nargout == 4;
    isTransferFcn  = (mn == 1 && md == 1);
    coder.internal.errorIf(~isStateSpace && ~(nd == 1 && nn < 2) && ~isTransferFcn,'signal:bilinear:SignalErr');
else  % For code generation
    nargoutchk(2,4);
    isZeroPoleGain = nargout == 3;
    isStateSpace   = nargout == 4;
    isTransferFcn  = nargout == 2;
    coder.internal.errorIf(~isStateSpace && ~(nd == 1 && nn < 2) && ~(mn == 1 && md == 1),'signal:bilinear:SignalErr');   
    if isZeroPoleGain
        % zero-pole-gain form requires 4 or 5 inputs
        narginchk(4,5); 
        % Zeros and Poles must be column vectors
        coder.internal.assert(nd == 1 && nn < 2,'signal:bilinear:notColumn');
    elseif isTransferFcn
         % transfer function form requires 3 or 4 inputs
        narginchk(3,4);
        % Numerator and denominator coefficients of transfer function must be
        % row vectors
        coder.internal.assert(mn == 1 && md == 1,'signal:bilinear:notRow');
    else % State space form
        % state space form requires 5 or 6 inputs
        narginchk(5,6); 
    end
end
if isZeroPoleGain % In zero-pole-gain form
    coder.internal.errorIf(mn > md,'signal:bilinear:InvalidRange');
    validateattributes(k,{'double','single'},{'scalar','finite'},'bilinear','K',3);
    validateattributes(fs,{'numeric'},{'scalar','real','finite','positive'},'bilinear','Fs',4);
    if isa(z,'single') || isa(p,'single') || isa(k,'single')
        zs = single(z(:));
        ps = single(p(:));
        ks = single(k(1));
    else
        zs = z(:);
        ps = p(:);
        ks = k(1);
    end

    if nargin == 4
        sampleFreq = 2*double(fs(1));
    else
        validateattributes(fp,{'numeric'},{'scalar','real','finite','positive','<',fs(1)/2},'bilinear','Fp',5);
        sampleFreq = double(fs(1));
        preWarp = double(fp(1));
        sampleFreq = 2*pi*preWarp/tan(pi*preWarp/sampleFreq);
    end
    zs = zs(isfinite(zs));  % Strip infinities from zeros
                            % Do bilinear transformation
    if isempty(zs)
        prodzs = ones(1,'like',zs);
        zd1 = zs;
    else
        prodzs = prod(sampleFreq-zs,1);
        zd1 = (1 + zs/sampleFreq)./(1 - zs/sampleFreq);
    end
    if isempty(ps)
        prodps = ones(1,'like',ps);
        pd = ps;
    else
        prodps = prod(sampleFreq - ps,1);
        pd = (1 + ps/sampleFreq)./(1 - ps/sampleFreq);
    end
    kd = (ks*prodzs./prodps);
    zd = [zd1;-ones(length(pd)-length(zd1),1)];
else
    if isStateSpace             % State-space case
        validateattributes(k,{'double','single'},{'2d'},'bilinear','C',3);
        validateattributes(fs,{'double','single'},{'2d'},'bilinear','D',4);
        validateattributes(fp,{'numeric'},{'scalar','real','finite','positive'},'bilinear','Fs',5);
        if isa(z,'single') || isa(p,'single') || isa(k,'single') || isa(fs,'single')
            as = single(z);
            bs = single(p);
            cs = single(k);
            ds = single(fs);
        else
            as = z;
            bs = p;
            cs = k;
            ds = fs;
        end
        [msg,~,~,~,~] = abcdchk(as,bs,cs,ds);
        if ~isempty(msg)
            coder.internal.error(msg.identifier);
        end
        sampleFreq = double(fp(1));
        if nargin == 6
            validateattributes(fp1,{'numeric'},{'scalar','real','finite','positive','<',sampleFreq/2},'bilinear','Fp',6);
            preWarp = double(fp1(1));
            sampleFreq = pi*preWarp/tan(pi*preWarp/sampleFreq);
        end
    else  % Transfer function case
        coder.internal.errorIf(nn > nd,'signal:bilinear:InvalidRange');
        validateattributes(k,{'numeric'},{'scalar','real','finite','positive'},'bilinear','Fs',3);
        if isa(z,'single') || isa(p,'single')
            num = single(z(:).');
            den = single(p(:).');
        else
            num = z(:).';
            den = p(:).';
        end
        sampleFreq = double(k(1));
        if nargin == 4
            validateattributes(fs,{'numeric'},{'scalar','real','positive','finite','<',sampleFreq/2},'bilinear','Fp',4);
            preWarp = double(fs(1));
            sampleFreq = pi*preWarp/tan(pi*preWarp/sampleFreq);
        end
        [as,bs,cs,ds] = tf2ss(num,den);
    end
    % Now do state-space version of bilinear transformation:
    t = 1/sampleFreq;
    r = sqrt(t);
    t1 = eye(size(as)) + as*t/2;
    t2 = eye(size(as)) - as*t/2;
    ad = t2\t1;
    bd = t/r*(t2\bs);
    cd = r*cs/t2;
    dd = cs/t2*bs*t/2 + ds;
    if isStateSpace
        zd = ad;
        pd = bd;
        kd = cd;
    else % Transfer function
        pd = poly(ad);
        zd = poly(ad-bd*cd) + (dd-1)*pd;
    end
end


% LocalWords:  prewarping Zd Kd Fs Fp th numd dend
