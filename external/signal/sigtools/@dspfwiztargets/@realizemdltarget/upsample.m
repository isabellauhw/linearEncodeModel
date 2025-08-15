function hblk = upsample(hTar, name, N, libname,phase,render)
%UPSAMPLE Add a Upsample block to the model.
%   HBLK = UPSAMPLE(HTAR, NAME, N, LIBNAME, PHASE) adds a sum block named
%   NAME, and sets its upsample number to N, phase to the specified phase

%   Copyright 1995-2010 The MathWorks, Inc.

narginchk(4,6);
sys = hTar.system;

if nargin<6
    render=true;
end

if render
    hblk = add_block([libname '/Upsample'], [hTar.system '/' name], 'N', N);
else
    hblk1=find_system(sys,'SearchDepth',1,'BlockType','S-Function','Name',name); % Do not add block
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
