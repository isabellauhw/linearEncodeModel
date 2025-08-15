function svmax = set_svmax(this, svmax)
%SET_SVMAX   PreSet function for the 'svmax' property.

%   Author(s): R. Losada
%   Copyright 1999-2017 The MathWorks, Inc.

% Change scale value constraint if set to unit
if strcmpi(this.ScaleValueConstraint,'unit')
    this.ScaleValueConstraint = 'none';
end

this.privsvmax = svmax;

svmax = [];

% [EOF]
