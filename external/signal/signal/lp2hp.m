function [at,bt,ct,dt] = lp2hp(a,b,c,d,wo)
%LP2HP Lowpass to highpass analog filter transformation.
%   [NUMT,DENT] = LP2HP(NUM,DEN,Wo) transforms the lowpass filter prototype
%   NUM(s)/DEN(s) with unity cutoff frequency (1 rad/s) to a highpass
%   filter with cutoff frequency Wo rad/s.
%
%   [AT,BT,CT,DT] = LP2HP(A,B,C,D,Wo) does the same when the filter is
%   described in state-space form.
%
%   % Example:
%   %   Design a Elliptic analog lowpass filter with 5 dB of ripple in the
%   %   passband and a stopband 90 dB down. Transform this filter to a
%   %   highpass filter with cutoff angular frequency of 24 rad/s.
%
%   Wo = 24;                     % Cutoff frequency
%   [z,p,k] = ellipap(6,5,90);   % Lowpass filter prototype
%   [b,a] = zp2tf(z,p,k);        % Specify filter in polynomial form
%   [num,den] = lp2hp(b,a,Wo);   % Convert LPF to HPF
%   freqs(num,den)               % Frequency response of analog filter
%
%   See also BILINEAR, IMPINVAR, LP2BP, LP2BS and LP2LP

%   Copyright 1988-2019 The MathWorks, Inc.
%#codegen

coder.internal.assert(nargin ==3 || nargin == 5,'signal:lp2hp:MustHaveNInputs');
if nargin == 3		% Transfer function case
    if coder.target('MATLAB')
        % accept complex values in MATLAB
        validateattributes(a,{'double','single'},{'vector'},'lp2hp','NUM',1);
        validateattributes(b,{'double','single'},{'vector'},'lp2hp','DEN',2);
    else
        validateattributes(a,{'double','single'},{'vector','real'},'lp2hp','NUM',1);
        validateattributes(b,{'double','single'},{'vector','real'},'lp2hp','DEN',2);
    end
    validateattributes(c,{'numeric'},{'scalar','finite','real'},'lp2hp','Wo',3);
    w1 = double(c(1));
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
    validateattributes(a,{'double','single'},{'2d'},'lp2hp','A',1);
    validateattributes(b,{'double','single'},{'2d'},'lp2hp','B',2);
    validateattributes(c,{'double','single'},{'2d'},'lp2hp','C',3);
    validateattributes(d,{'double','single'},{'2d'},'lp2hp','D',4);
    validateattributes(wo,{'numeric'},{'scalar','finite','real'},'lp2hp','Wo',5);
    w1 = double(wo(1));
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

% Transform lowpass to highpass
at =  w1*inv(as); %#ok<MINV>
bt = -w1*(as\bs);
ct = cs/as;
if isempty(as) || isempty(bs) || isempty(cs) || isempty(ds)
    dt = zeros(0,'like',as);
else
    dt = ds - cs/as*bs;
end
if nargin == 3		% Transfer function case
    % Transform back to transfer function
    if isempty(as)
        % if as is empty, then at bt ct and dt are empty. Then we assign
        % outputs directly. Avoid calling ltipack.sszero with empty input
        % dt.
        bt  = ones(1,'like',as);
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

% LocalWords:  NUMT Wo stopband LPF HPF BP NInputs infzero
