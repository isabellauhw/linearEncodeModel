function svmax = get_svmax(this, svmax)
%GET_SVMAX   PreGet function for the 'svmax' property.

%   Author(s): R. Losada
%   Copyright 1999-2017 The MathWorks, Inc.

if strcmpi(this.ScaleValueConstraint,'unit')
    svmax = 'Not used';
else
    svmax = this.privsvmax;
end

% [EOF]
