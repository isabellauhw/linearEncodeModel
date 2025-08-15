function [strs, lbls] = setstrs(h)
%SETSTRS Strings to set and get

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

strs = allprops(h);
lbls = {getString(message('signal:sigtools:fdadesignpanel:FreqVector')), getString(message('signal:sigtools:fdadesignpanel:MagVector')),getString(message('signal:sigtools:fdadesignpanel:WeightVector')), getString(message('signal:sigtools:fdadesignpanel:ConsBands'))};

% [EOF]
