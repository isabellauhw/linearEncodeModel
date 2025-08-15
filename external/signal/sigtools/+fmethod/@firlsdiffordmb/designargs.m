function args = designargs(this, hs)
%DESIGNARGS   Returns the inputs to the design function.

%   Copyright 1999-2017 The MathWorks, Inc.

order = hs.FilterOrder;

% Determine what type of differentiator we have
typeIV = true;
typeIII = false;
if ~rem(order,2)
    typeIII = true; 
    typeIV = false;
end

% Define the 2nd to last and last Amplitudes and Frequencies
if typeIV
    endA = 1;
    stA  = hs.Fstop;
else
    endA = 0;
    stA  = 0;
end

args = {order, [0 hs.Fpass hs.Fstop 1], [0 hs.Fpass*pi stA*pi  endA*pi],...
    'differentiator'};

% [EOF]
