function [cshtags, cshtool] = getcshtags(~)
%GETCSHTAGS   Returns the Tags and the Toolname for the CSH.

%   Copyright 2011 The MathWorks, Inc.

cshtags.design = fullfile('fdatool_designpanel_design', 'signal');
cshtool = 'fdatool';

% [EOF]
