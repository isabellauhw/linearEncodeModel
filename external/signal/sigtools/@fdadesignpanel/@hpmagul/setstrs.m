function [upper, lower, lbls] = setstrs(this) %#ok
%SETSTRS Returns the strings to use to setup the contained object/

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

upper = {'DstopUpper', 'DpassUpper'};
lower = {'DstopLower', 'DpassLower'};
lbls  = {'Dstop', 'Dpass'};

% [EOF]
