function [w, h] = destinationSize(this)
%DESTINATIONSIZE 

%   Author(s): J. Schickler
%   Copyright 2007-2017 The MathWorks, Inc.

sz = gui_sizes(this);
w = 160*sz.pixf;
h = 40*sz.pixf;

% [EOF]
