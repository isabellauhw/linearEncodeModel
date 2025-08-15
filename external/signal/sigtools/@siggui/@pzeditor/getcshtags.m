function [cshtags, cshtool] = getcshtags(~)
%GETCSHTAGS   Returns the Tags and the Toolname for the CSH.

%   Copyright 2011 The MathWorks, Inc.

cshtags.plot = fullfile('fdatool_pzeditor_plot', 'signal');
cshtags.controls = fullfile('fdatool_pzeditor_controls', 'signal');
cshtags.MovePoleZero = fullfile('fdatool_pzeditor_actionbutton_MovePoleZero', 'signal');
cshtags.AddPole = fullfile('fdatool_pzeditor_actionbutton_AddPole', 'signal');
cshtags.AddZero = fullfile('fdatool_pzeditor_actionbutton_AddZero', 'signal');
cshtags.DeletePoleZero = fullfile('fdatool_pzeditor_actionbutton_DeletePoleZero', 'signal');
cshtags.gain = fullfile('fdatool_pzeditor_gain', 'signal');
cshtags.coordinatemode = fullfile('fdatool_pzeditor_coordinatemode', 'signal');
cshtags.real = fullfile('fdatool_pzeditor_real', 'signal');
cshtags.imaginary = fullfile('fdatool_pzeditor_imaginary', 'signal');
cshtags.currentsection = fullfile('fdatool_pzeditor_currentsection', 'signal');
cshtags.conjugatemode = fullfile('fdatool_pzeditor_conjugatemode', 'signal');
cshtags.autoupdate = fullfile('fdatool_pzeditor_autoupdate', 'signal');

cshtool = 'fdatool';

% [EOF]
