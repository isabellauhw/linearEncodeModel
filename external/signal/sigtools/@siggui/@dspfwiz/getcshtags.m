function [cshtags, cshtool] = getcshtags(~)
%GETCSHTAGS   Returns the Tags and the Toolname for the CSH.

%   Copyright 2011 The MathWorks, Inc.

cshtags.panel = fullfile('fdatool_dspfwiz_panel', 'signal');
cshtags.actionbutton = fullfile('fdatool_dspfwiz_actionbutton','signal');
cshtags.blockname = fullfile('fdatool_dspfwiz_blockname', 'signal');
cshtags.destination = fullfile('fdatool_dspfwiz_destination', 'signal');
cshtags.userdefined = fullfile('fdatool_dspfwiz_destination', 'signal');
cshtags.overwriteblock = fullfile('fdatool_dspfwiz_overwriteblock', 'signal');
cshtags.usebasicelements = fullfile('fdatool_dspfwiz_usebasicelements', 'signal');
cshtags.optimizezeros = fullfile('fdatool_dspfwiz_optimizezeros', 'signal');
cshtags.optimizeones = fullfile('fdatool_dspfwiz_optimizeones', 'signal');
cshtags.optimizenegones = fullfile('fdatool_dspfwiz_optimizenegones', 'signal');
cshtags.optimizedelaychains = fullfile('fdatool_dspfwiz_optimizedelaychains', 'signal');
cshtags.optimizescalevalues = fullfile('fdatool_dspfwiz_optimizescalevalues', 'signal');
cshtool = 'fdatool';

% [EOF]
