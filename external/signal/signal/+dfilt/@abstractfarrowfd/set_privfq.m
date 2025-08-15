function privfq = set_privfq(this, privfq)
%SET_PRIVFQ   PreSet function for the 'privfq' property.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.

% Recreate the listeners on the private filter quantizers.
l  = [event.listener(privfq, 'QuantizeCoeffs', @(src,event)lcl_super_quantizecoeffs(src,event,this)); ...
    event.listener(privfq, 'QuantizeStates', @(src,event)lcl_quantizestates(src,event,this));...
   event.listener(privfq, 'QuantizeFracDelay', @(src,event)lcl_quantizefracdelay(src,event,this))];


this.filterquantizerlisteners = l;

% -------------------------------------------------------------------------
function lcl_quantizestates(src, event,this)

quantizestates(this);

% -------------------------------------------------------------------------
function lcl_quantizefracdelay(src, event,this)

quantizefd(this);

function lcl_super_quantizecoeffs(src, event,this)

super_quantizecoeffs(this);

% [EOF]
