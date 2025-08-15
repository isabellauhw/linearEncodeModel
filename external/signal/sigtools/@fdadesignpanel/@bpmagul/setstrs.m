function [upper, lower, lbls] = setstrs(this) %#ok
%SETSTRS Returns the strings to use to setup the contained object/

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

upper = {'Dstop1Upper', 'DpassUpper', 'Dstop2Upper'};
lower = {'Dstop1Lower', 'DpassLower', 'Dstop2Lower'};
lbls  = {'Dstop1', 'Dpass', 'Dstop2'};

% [EOF]
