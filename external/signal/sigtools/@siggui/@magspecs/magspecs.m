function this = magspecs
%MAGSPECS This is the constructor for the magspecs class.

%   Author(s): Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

% Use built-in constructor
this = siggui.magspecs;

% Create a labelsandvalues object
construct_mf(this, 'Maximum', 5);

% Set the version
set(this, 'Version', 1.0);

settag(this)

% [EOF]
