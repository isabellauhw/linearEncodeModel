function [strs, lbls] = setstrs(h)
%SETSTRS Strings to set and get

%   Author(s): J. Schickler
%   Copyright 1988-2011 The MathWorks, Inc.

strs = allprops(h);
lbls = {getString(message('signal:sigtools:fdadesignpanel:FreqVector')), getString(message('signal:sigtools:fdadesignpanel:FreqEdges')), getString(message('signal:sigtools:fdadesignpanel:GrpdelayVector')), getString(message('signal:sigtools:fdadesignpanel:WeightVector'))};

% [EOF]
