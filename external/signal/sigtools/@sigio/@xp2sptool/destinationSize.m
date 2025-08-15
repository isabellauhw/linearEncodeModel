function [width, height] = destinationSize(this)
%DESTINATIONSIZE 

%   Author(s): J. Schickler
%   Copyright 2007-2017 The MathWorks, Inc.

sz     = gui_sizes(this);
width  = 160*sz.pixf;
height = getfrheight(this);

% [EOF]
