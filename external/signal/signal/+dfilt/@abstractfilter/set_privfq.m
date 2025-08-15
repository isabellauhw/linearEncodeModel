function privfq = set_privfq(this, privfq)
%SET_PRIVFQ   PreSet function for the 'privfq' property.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.

% Recreate the listeners on the private filter quantizers.
l  = [event.listener(privfq, 'QuantizeCoeffs', @(src,evnt)lcl_super_quantizecoeffs(src, evnt, this)); ...
    event.listener(privfq, 'QuantizeStates', @(src,evnt)lcl_quantizestates(src, evnt, this))];

this.filterquantizerlisteners = l;

% -------------------------------------------------------------------------
function lcl_quantizestates(src, eventData,this)

quantizestates(this);


function lcl_super_quantizecoeffs(src, eventData,this)

super_quantizecoeffs(this);


% [EOF]
