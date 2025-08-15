function [strs, lbls] = setstrs(h)
%SETSTRS Strings to set and get

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

strs = {'Fstop','Fpass'};
lbls = {[fvw(h) 'stop:'], [fvw(h) 'pass:']};

% [EOF]
