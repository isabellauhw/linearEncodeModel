function hblk = downsample(hTar, name, N, libname,phase,render)
%DOWNSAMPLE Add a Downsample block to the model.
%   HBLK = DOWNSAMPLE(HTAR, NAME, N, LIBNAME, PHASE) adds a sum block named
%   NAME, and sets its downsample number to N, phase to the specified phase

%   Copyright 1995-2014 The MathWorks, Inc.

narginchk(4,6);

sys = hTar.system;

if nargin<6
    render=true;
end

if render
    hblk = add_block([libname '/Downsample'], [hTar.system '/' name], 'N', N); % add block
else
    hblk1=find_system(sys,'SearchDepth',1,'BlockType','S-Function','Name',name);
    % workaround for submitting the pilot job of converting DownSample to coreblock
    % because Bdsp does not build the component that contains this MATLAB module
    % following works for both s-function and core block-based Downsample block
    % find s-function based Downsample block instances
    % if nothing found
    % then find core-block based DownSample block instances
    %
    % xxx remove s-function based search once the integration is done
    if isempty(hblk1)
        hblk1=find_system(sys,'SearchDepth',1,'BlockType','DownSample','Name',name); % Do not add block
    end
    hblk=hblk1{1};
end

InputProcessing = '';
switch (hTar.InputProcessing)
  case 'columnsaschannels'
    InputProcessing = 'Columns as channels (frame based)';
  case 'elementsaschannels'
    InputProcessing = 'Elements as channels (sample based)';
  case 'inherited'
    InputProcessing = 'Inherited (this choice will be removed - see release notes)';
end
RateOptions = '';
switch(hTar.RateOption)
  case 'enforcesinglerate'
    RateOptions = 'Enforce single-rate processing';
  case 'allowmultirate'
    RateOptions = 'Allow multirate processing';
end
set_param(hblk, 'InputProcessing', InputProcessing, ...
                'RateOptions', RateOptions);
        
if nargin > 4 && ~isempty(phase)
    set_param(hblk,'phase',phase);
end

%will hard error if dspblks are
