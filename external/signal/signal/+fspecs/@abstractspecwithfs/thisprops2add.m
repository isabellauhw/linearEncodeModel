function p = thisprops2add(this,varargin)
%THISPROPS2ADD   

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.

p = propstoadd(this);
% Remove the NormalizedFrequency and Fs properties.
p(strcmp(p,'NormalizedFrequency')) = [];
p(strcmp(p,'Fs')) = [];


% [EOF]
