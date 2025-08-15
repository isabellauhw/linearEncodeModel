function [at,bt,ct,dt] = lp2bs(a,b,c,d,wo,bw)
%LP2BS Lowpass to bandstop analog filter transformation.
%   [NUMT,DENT] = LP2BS(NUM,DEN,Wo,Bw) transforms the lowpass filter
%   prototype NUM(s)/DEN(s) with unity cutoff frequency (1 rad/s) to a
%   bandstop filter with center frequency Wo rad/s and bandwidth Bw rad/s.
%
%   [AT,BT,CT,DT] = LP2BS(A,B,C,D,Wo,Bw) does the same when the filter is
%   described in state-space form.
%
%   % Example:
%   %   Design a Elliptic analog lowpass filter with 5 dB of ripple in the
%   %   passband and a stopband 90 dB down. Transform this filter to a
%   %   bandstop filter with center frequency of 24 rad/s and bandwidth of
%   %   10 rad/s.
%
%   Wo = 24;                        % Center frequency
%   Bw = 10;                        % Bandwidth
%   [z,p,k] = ellipap(6,5,90);      % Lowpass filter prototype
%   [b,a] = zp2tf(z,p,k);           % Specify filter in polynomial form
%   [num,den] = lp2bs(b,a,Wo,Bw);   % Convert LPF to BSF
%   freqs(num,den)                  % Frequency response of analog filter
%
%   See also BILINEAR, IMPINVAR, LP2BP, LP2LP and LP2HP

%   Copyright 1988-2019 The MathWorks, Inc.
%#codegen

coder.internal.assert(nargin == 4 || nargin == 6,'signal:lp2bs:MustHaveNInputs');
if nargin == 4		% Transfer function case
    if coder.target('MATLAB')
        % accept complex values in MATLAB
        validateattributes(a,{'double','single'},{'vector'},'lp2bs','NUM',1);
        validateattributes(b,{'double','single'},{'vector'},'lp2bs','DEN',2);
    else
        validateattributes(a,{'double','single'},{'vector','real'},'lp2bs','NUM',1);
        validateattributes(b,{'double','single'},{'vector','real'},'lp2bs','DEN',2);
    end
    validateattributes(c,{'numeric'},{'scalar','finite','real'},'lp2bs','Wo',3);
    validateattributes(d,{'numeric'},{'scalar','finite','real'},'lp2bs','Bw',4);
    w1  = double(c(1));
    bw1 = double(d(1));
    % handle column vector inputs: convert to rows
    if iscolumn(a)
        aRow = reshape(a,1,[]);
    else
        aRow = a;
    end
    % Cast to enforce precision rules
    if isa(a,'single') || isa(b,'single')
        tfnum = single(aRow);
        tfden = single(b);
    else
        tfnum = aRow;
        tfden = b;
    end
   
    % Transform to state-space
    [as,bs,cs,ds] = tf2ss(tfnum,tfden);
else
    validateattributes(a,{'double','single'},{'2d'},'lp2bs','A',1);
    validateattributes(b,{'double','single'},{'2d'},'lp2bs','B',2);
    validateattributes(c,{'double','single'},{'2d'},'lp2bs','C',3);
    validateattributes(d,{'double','single'},{'2d'},'lp2bs','D',4);
    validateattributes(wo,{'numeric'},{'scalar','finite','real'},'lp2bs','Wo',5);
    validateattributes(bw,{'numeric'},{'scalar','finite','real'},'lp2bs','Bw',6);
    w1  = double(wo(1));
    bw1 = double(bw(1));
    % Cast to enforce precision rules    
    if isa(a,'single') || isa(b,'single') || isa(c,'single') || isa(d,'single')
        as = single(a);
        bs = single(b);
        cs = single(c);
        ds = single(d);
    else
        as = a;
        bs = b;
        cs = c;
        ds = d;
    end
    [msg,~,~,~,~] = abcdchk(as,bs,cs,ds);
    if ~isempty(msg)
        coder.internal.error(msg.identifier);
    end
end

nb = size(bs, 2);
[mc,ma] = size(cs);

% Transform lowpass to bandstop
q = w1/bw1;
at =  [w1/q*inv(as) w1*eye(ma); -w1*eye(ma) zeros(ma)]; %#ok<MINV>
bt = -[w1/q*(as\bs); zeros(ma,nb)];
ct = [cs/as zeros(mc,ma)];
if isempty(as) || isempty(bs) || isempty(cs) || isempty(ds)
    dt = zeros(0,'like',as);
else
    dt = ds - cs/as*bs;
end

if nargin == 4		% Transfer function case
    % Transform back to transfer function
    if isempty(as)
        % if as is empty, then at bt ct and dt are empty. Then we assign
        % outputs directly. Avoid calling ltipack.sszero with empty input
        % dt.
        bt = ones(1,'like',as);
    else
    zinf = ltipack.getTolerance('infzero',true);
    [z,k] = ltipack.sszero(at,bt,ct,dt(1),[],zinf);
    num = k * poly(z);
    den = poly(at);
    if coder.target('MATLAB')
        at = num;
        bt = den;
    else
        at = real(num);
        bt = real(den);
    end
    end
end

% LocalWords:  NUMT Wo Bw stopband LPF BSF BP NInputs infzero
