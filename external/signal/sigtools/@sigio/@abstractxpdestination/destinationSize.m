function [width, height] = destinationSize(this)
%DESTINATIONSIZE 

%   Author(s): J. Schickler
%   Copyright 2007-2017 The MathWorks, Inc.

sz = gui_sizes(this);

% Default frame height.
height = 100*sz.pixf;
width  = 160*sz.pixf;

% [EOF]
