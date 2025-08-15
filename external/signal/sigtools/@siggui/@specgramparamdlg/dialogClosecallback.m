function dialogClosecallback(this)
%DIALOGCLOSECALLBACK Called when dialog closes.

%   Author(s): J. Yu
%   Copyright 2006 The MathWorks, Inc.

send(this,'DialogClose', handle.EventData(this, 'DialogClose'));

% [EOF]
