function [fn,dr] = polesTofd(poles)
%POLESTOFD Compute natural frequency and damping from poles.
%   This function is for internal use only. It may be removed. 

%   Copyright 2016 The MathWorks, Inc.

% Compute natural frequency and damping for each pole
wn = abs(poles); 
fn = wn/(2*pi);
dr = -real(poles)./wn;