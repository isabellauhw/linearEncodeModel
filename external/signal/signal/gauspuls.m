function [yc,ys,ye] = gauspuls(t,fc,bw,bwr,tpr)
%GAUSPULS Gaussian-modulated sinusoidal pulse generator.
%   YI=GAUSPULS(T,FC,BW) returns samples of the unity-amplitude
%   Gaussian RF pulse with center frequency FC (Hertz) and
%   fractional bandwidth BW, at the times indicated in array T.
%   Note that BW must be > 0.  By default, FC=1000 Hz and BW=0.5.
%
%   YI=GAUSPULS(T,FC,BW,BWR) specifies the optional fractional
%   bandwidth reference level, BWR.  The pulse bandwidth is
%   100*BW percent as measured at a level of BWR dB with respect
%   to the normalized signal peak.  By default, BWR=-6 dB.  Note that
%   BWR must be < 0, as it must always indicate a reference level less
%   than the peak (unity) envelope amplitude.
%
%   [YI,YQ]=GAUSPULS(...) returns both the in-phase and quadrature
%   pulses.  [YI,YQ,YE]=GAUSPULS(...) returns the RF signal envelope.
%
%   TC=GAUSPULS('cutoff',FC,BW,BWR,TPE) returns the cutoff time TC >= 0
%   at which the trailing pulse envelope falls below TPE dB with
%   respect to the peak envelope amplitude.  By default, TPE=-60 dB.
%   Note that TPE must be < 0 for the same reason as given for BWR.
%
%   Default values are substituted for empty or omitted trailing input
%   arguments.
%
%   For example, plot a 50 kHz Gaussian RF pulse with 60% bandwidth and
%   sampled at a rate of 1 MHz.  Truncate the pulse where the envelope
%   falls 40 dB below the peak.
%       tc = gauspuls('cutoff',50E3,.6,[],-40);
%       t  = -tc : 1E-6 : tc;
%       yi = gauspuls(t,50E3,.6); plot(t,yi)
%
%   See also CHIRP, SAWTOOTH, SQUARE.

%   Copyright 1988-2018 The MathWorks, Inc.

%#codegen


% Check input parameters:
narginchk(1,5);

t = convertStringsToChars(t);


if nargin<5, tpr = []; end
if nargin<4, bwr = []; end
if nargin<3, bw = []; end
if nargin<2, fc = []; end

if isempty(tpr)
    tprI = -60; 
else    
    validateattributes(tpr, {'numeric'}, {'real'}, 'gauspuls', 'TPR');
    tprI = signal.internal.sigcasttofloat(tpr,'double','gauspuls','TPE',...
  'allownumeric');
end

if isempty(bwr)
    bwrI = -6; 
else
    validateattributes(bwr, {'numeric'}, {'scalar', 'real'}, 'gauspuls', 'BWR');        
    coder.internal.errorIf(bwr>=0, 'signal:gauspuls:InvalidRange');
    bwrI = signal.internal.sigcasttofloat(bwr,'double','gauspuls','BWR',...
      'allownumeric');
end

if isempty(bw)
    bwI = 0.5; 
else    
    validateattributes(bw, {'numeric'}, {'scalar', 'real'}, 'gauspuls', 'BW');
    coder.internal.errorIf(bw<=0, 'signal:gauspuls:MustBePositiveBW', 'BW');
    bwI = signal.internal.sigcasttofloat(bw,'double','gauspuls','BW',...
      'allownumeric');
end

if isempty(fc)
    fcI = 1E3; 
else    
    validateattributes(fc, {'numeric'}, {'scalar', 'real'}, 'gauspuls', 'FC');
    coder.internal.errorIf(fc<0, 'signal:gauspuls:MustBePositiveFC', 'FC');
    fcI = signal.internal.sigcasttofloat(fc,'double','gauspuls','FC',...
      'allownumeric');
end


% Determine Gaussian mean and variance in the
% frequency domain to match specifications:
r = 10.^(bwrI/20);             % Ref level (fraction of max peak)
fv = -bwI*bwI*fcI*fcI/(8*log(r)); % variance is fv, mean is fc
% Determine corresponding time-domain parameters:
tv = 1/(4*pi*pi*fv);  % variance is tv, mean is 0


compute_cutoff = false;
if ischar(t)
    compute_cutoff = strncmpi(t, 'cutoff', length(t));
    coder.internal.errorIf(~compute_cutoff, 'signal:gauspuls:InvalidCutoffInput');
end

if compute_cutoff
    coder.internal.errorIf(tprI>0, 'signal:gauspuls:InvalidRange');
    % Compute pulse cutoff time:    
    coder.internal.errorIf(nargout>1, 'signal:gauspuls:SignalErr');
    
    % Determine extent (pulse length) of time-domain envelope:
    delta = 10.^(tprI/20);        % Ref level (fraction of max peak)
    yc = sqrt(-2*tv*log(delta)); % Pulse cutoff time
        
    ys = []; 
    ye = [];    
else
    % Return RF pulses:
    coder.internal.errorIf(nargin>4, 'signal:gauspuls:Nargchk');
      
    % Cast to enforce precision rules
    t = double(t);
   
    if isempty(t)
        ye = []; 
        yc = []; 
        ys = [];
        return
    end    
        
    % Compute time-domain pulse envelope, normalized by sqrt(2*pi*tv):
    ye = exp(-t.*t/(2*tv));
    
    % Modulate envelope to form in-phase and quadrature components:
    yc = ye .* cospi(2*fcI*t);    % In-phase
    if nargout>1
        ys = ye .* sinpi(2*fcI*t);  % Quadrature
    end
    
    % gauspuls converges to 0 at Inf
    idxInf = isinf(t);
    yc(idxInf) = 0;
    if nargout>1
        ys(idxInf) = 0;
    end
    
end

% end of gauspuls.m
