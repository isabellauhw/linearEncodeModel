function p = thisprops2add(this,varargin)
%THISPROPS2ADD   

%   Author(s): V. Pellissier
%   Copyright 2005-2017 The MathWorks, Inc.

p = propstoadd(this);
% Remove the NormalizedFrequency and Fs properties.
p(strcmp(p,'NormalizedFrequency')) = [];
p(strcmp(p,'Fs')) = [];

idx = strmatch('NBands',p);
if ~isempty(idx) && length(varargin)>1
    % Set NBands first and update propstoadd
    this.(p{idx}) = varargin{idx};
    p = propstoadd(this);
    % Remove NormalizedFrequency and Fs
    p(strcmp(p,'NormalizedFrequency')) = [];
    p(strcmp(p,'Fs')) = [];
   
end


% [EOF]
