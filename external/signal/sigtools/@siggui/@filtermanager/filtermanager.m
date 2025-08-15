function this = filtermanager
%FILTERMANAGER   Construct a FILTERMANAGER object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

this = siggui.filtermanager;

% Create a vector object to store all the filter structures.
this.Data = sigutils.vector;

% [EOF]
