function hblk = delay(hTar, name, latency, render)
%DELAY Add a Delay block to the model.
%   HBLK = DELAY(HTAR, NAME, LATENCY) adds a sum block named NAME, sets its
%   latency to LATENCY and returns a handle HBLK to the block.

%   Copyright 1995-2017 The MathWorks, Inc.

narginchk(3,4);
sys = hTar.system;
InputProcessing = '';
libname = 'simulink';
blockname = '/Discrete/Integer Delay';
latprop = 'NumDelays';

switch (hTar.InputProcessing)
  case 'columnsaschannels'
    InputProcessing = 'Columns as channels (frame based)';
  case 'elementsaschannels'
    InputProcessing = 'Elements as channels (sample based)';
  case 'inherited'
    InputProcessing = 'Inherited';
end

isloaded = 0;
w=warning;
warning('off'); %#ok<WNOFF>

if isempty(find_system(0,'flat','Name', libname))
    isloaded = 1;
    load_system(libname);
end
fullname = [libname blockname];

if nargin<4
    render=true;
end

if render
    hblk = add_block(fullname , [hTar.system '/' name],...
                     latprop, latency);
    set_param(hblk, 'InputProcessing', InputProcessing);
else         % then find the block and just update the block's parameters
    hblk1=find_system(sys,'SearchDepth',1,'Name',name);
    hblk=hblk1{1};
    
    % Only need to set if it's different from previous setting
    % Only compare first 9 characters because 9b and before DSP Delay block
    % was used. After 10a, Simulink Integer Delay block has been used
    if ~strncmp(get_param(hblk, 'InputProcessing'),InputProcessing, 9)
        set_param(hblk, 'InputProcessing', InputProcessing);
    end
end

if isloaded
    close_system(libname);
end

warning(w);
