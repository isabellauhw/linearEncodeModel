function this = weightmagspecs
%WEIGHTMAGSPECS constructs the weight mag specs object and sets initial conditions

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.

% Call builtin constructor
this = siggui.weightmagspecs;

% Create a labelsandvalues object
construct_mf(this, 'Maximum', 5);

settag(this);

% [EOF]
