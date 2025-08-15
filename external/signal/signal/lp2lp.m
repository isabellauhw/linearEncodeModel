function [at,bt,ct,dt] = lp2lp(a,b,c,d,wo)
%LP2LP Lowpass to lowpass analog filter transformation.
%   [NUMT,DENT] = LP2LP(NUM,DEN,Wo) transforms the lowpass filter prototype
%   NUM(s)/DEN(s) with unity cutoff frequency (1 rad/s) to a lowpass filter
%   with cutoff frequency Wo rad/s.
%
%   [AT,BT,CT,DT] = LP2LP(A,B,C,D,Wo) does the same when the filter is
%   described in state-space form.
%
%   % Example:
%   %   Design a Elliptic analog lowpass filter with 5 dB of ripple in the
%   %   passband and a stopband 90 dB down. Change the cutoff frequency of
%   %   this lowpass filter to 24 rad/s.
%
%   Wo = 24;                     % Cutoff frequency
%   [z,p,k] = ellipap(6,5,90);   % Lowpass filter prototype
%   [b,a] = zp2tf(z,p,k);        % Specify filter in polynomial form
%   [num,den] = lp2lp(b,a,Wo);   % Change cutoff frequency
%   freqs(num,den)               % Frequency response of analog filter
%
%   See also BILINEAR, IMPINVAR, LP2BP, LP2BS and LP2HP

%   Copyright 1988-2019 The MathWorks, Inc.
%#codegen

coder.internal.assert(nargin == 3 || nargin == 5 ,'signal:lp2lp:MustHaveNInputs');

if nargin == 3		% Transfer function case
    if coder.target('MATLAB')
        % accept complex values in MATLAB
        validateattributes(a,{'double','single'},{'vector'},'lp2lp','NUM',1);
        validateattributes(b,{'double','single'},{'vector'},'lp2lp','DEN',2);
    else
        validateattributes(a,{'double','single'},{'vector','real'},'lp2lp','NUM',1);
        validateattributes(b,{'double','single'},{'vector','real'},'lp2lp','DEN',2);
    end
    validateattributes(c,{'numeric'},{'scalar','finite','real'},'lp2lp','Wo',3);
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
    validateattributes(a,{'double','single'},{'2d'},'lp2lp','A',1);
    validateattributes(b,{'double','single'},{'2d'},'lp2lp','B',2);
    validateattributes(c,{'double','single'},{'2d'},'lp2lp','C',3);
    validateattributes(d,{'double','single'},{'2d'},'lp2lp','D',4);
    validateattributes(wo,{'numeric'},{'scalar','finite','real'},'lp2lp','Wo',5);
    w1 = double(wo(1));
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

% Transform lowpass to lowpass
at = w1*as;
bt = w1*bs;
ct = cs;
dt = ds;

if nargin == 3		% Transfer function case
    % Transform back to transfer function
    zinf  = ltipack.getTolerance('infzero',true);
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

% LocalWords:  NUMT Wo stopband BP NInputs infzero
