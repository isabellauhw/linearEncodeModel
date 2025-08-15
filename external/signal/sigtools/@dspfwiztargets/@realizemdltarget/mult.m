function hblk = mult(hTar, name, ninputs, param,render)
%MULT  Add a Product block to the model.
%   HBLK = MULT(HTAR, NAME, NINPUTS, param) adds a gain block named NAME,
%   with NINPUTS inputs and returns a handle HBLK to the block. PARAM
%   specifies the arithmetic property and parameters of the filter.

%   Author(s): V. Pellissier
%   Copyright 2005-2017 The MathWorks, Inc.

narginchk(4,5);

sys = hTar.system;

if nargin<5
    render=true;
end

if render
    hblk = add_block('built-in/Product', [sys '/' name]);
    set_param(hblk, 'Inputs', ninputs, ...
        'InputSameDT','off',...
        'LockScale', 'off');
else
    hblk1=find_system(sys,'SearchDepth',1,'BlockType','Product','Name',name);
    hblk=hblk1{1};
end

try
    % Parameters may or may not be tunable (depends on model running or not)
    if isstruct(param)
        fxptAvail = (exist('fixptlib') == 4);
        if ~fxptAvail
            error(message('signal:dspfwiztargets:realizemdltarget:mult:NotSupported'));
        end
        
        wordLength = num2str(param.qproduct(1));
        fracLength = num2str(param.qproduct(2));
        
        set_param(hblk, ...
            'OutDataTypeStr',['fixdt(1,' wordLength ',' fracLength ')'],...
            'RndMeth', rndmeth(param.RoundMode), ...  
            'DoSatur', dosatur(param.OverflowMode),...
            'InputSameDT','off');

    else
        set_param(hblk, ...
            'OutDataTypeStr', 'Inherit: Same as first input', ...
            'RndMeth', 'Nearest', ...  
            'DoSatur', 'on');

    end
catch ME %#ok<NASGU> 

end


%---------------------------------------------------------------------
function RndMeth = rndmeth(Roundmode)
% Convert from roundmode to RndMeth property of the block.

switch Roundmode
    case 'fix'
        RndMeth = 'Zero';
    case 'floor'
        RndMeth = 'Floor';
    case 'ceil'
        RndMeth = 'Ceiling';
    case 'round'
        RndMeth = 'Round';
    case 'convergent'
        RndMeth = 'Convergent';
    case 'nearest'
         RndMeth = 'Nearest';
end

%----------------------------------------------------------------------
function DoSatur = dosatur(Overflowmode)
% Convert from quantizer/overflowmode to DoSatur property of the block.

switch Overflowmode
    case 'saturate'
        DoSatur = 'on';
    case 'wrap'
        DoSatur = 'off';
end
