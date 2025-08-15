function [strs, lbls] = setstrs(h)
%SETSTRS Strings to set and get

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

strs = {'Fpass','Fstop'};
lbls = {[fvw(h) 'pass:'], [fvw(h) 'stop:']};
    
% [EOF]
