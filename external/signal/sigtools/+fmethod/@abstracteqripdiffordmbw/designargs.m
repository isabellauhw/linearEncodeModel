function args = designargs(this, hs)
%DESIGNARGS Returns the inputs to the design function.

%   Copyright 1999-2017 The MathWorks, Inc.

order = hs.FilterOrder;

% Determine what type of differentiator we have
typeIV = true;
if ~rem(order,2)
    typeIV = false;
end

% Define the 2nd to last and last Amplitudes and Frequencies
if typeIV
    error(message('signal:fmethod:abstracteqripdiffordmbw:designargs:InvalidDesign'));
else
    endA = 0;
    stA  = 0;
end

args = {order, [0 hs.Fpass hs.Fstop 1], [0 hs.Fpass*pi stA*pi  endA*pi],...
    [this.Wpass this.Wstop],'differentiator'};

% [EOF]
