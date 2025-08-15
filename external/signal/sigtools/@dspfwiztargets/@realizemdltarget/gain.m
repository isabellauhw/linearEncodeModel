function hblk = gain(hTar, name, coeff, param, render)
%GAIN Add a Gain block to the model.
%   HBLK = GAIN(HTAR, NAME, COEFF, param) adds a gain block named NAME,
%   sets its value to COEFF and returns a handle HBLK to the block. qparam
%   specifies the arithmetic property and parameters of the filter.
%

% Copyright 2004-2017 The MathWorks, Inc.

narginchk(4,5);

sys = hTar.system;

if nargin<5
    render=true;
end

if render
    hblk = add_block('built-in/Gain', [hTar.system '/' name]);
    set_param(hblk, 'ParamDataTypeStr', 'fixdt(1,16,0)',...
                    'LockScale', 'off');

else
    hblk1=find_system(sys,'SearchDepth',1,'BlockType','Gain','Name',name);
    hblk=hblk1{1};
end

try
    % Parameters may or may not be tunable (depends on model running or not)
    if isstruct(param)
        % Fixed -Point
        if length(param.qcoeff)>1 && length(param.qproduct)>1

            fxptAvail = (exist('fixptlib') == 4);
            if ~fxptAvail
                error(message('signal:dspfwiztargets:realizemdltarget:gain:NotSupported'));
            end

            if param.Signed
                sign = '1';
            else
                sign = '0';
            end
            wordLength = num2str(param.qcoeff(1));
            fracLength = num2str(param.qcoeff(2));
            fixdt_string = ['fixdt(' sign ',' wordLength ',' fracLength ')'];
            set_param(hblk,'ParamDataTypeStr', fixdt_string);

            wordLength = num2str(param.qproduct(1));
            fracLength = num2str(param.qproduct(2));
            fixdt_string = ['fixdt(1,' wordLength ',' fracLength ')'];
            set_param(hblk,'OutDataTypeStr', fixdt_string, ...
                           'RndMeth', rndmeth(param.RoundMode), ...  % Zero|Nearest|Ceiling|Floor
                           'DoSatur', dosatur(param.OverflowMode));
        end
    else
        set_param(hblk, ...
                  'OutDataTypeStr','Inherit: Same as input', ...
                  'RndMeth', 'Nearest', ... 
                  'DoSatur','on');
        switch param
          case 'double'
            set_param(hblk, 'ParamDataTypeStr', 'double');
          case 'single'
            set_param(hblk, 'ParamDataTypeStr', 'single');
          otherwise
            old_fixdt_str = get_param(hblk, 'ParamDataTypeStr');
            if strncmp(old_fixdt_str, 'fixdt(', 6)
                try
                    dt = eval(old_fixdt_str);
                    dt.FractionLength=1;
                    new_fixdt_str = fixdt(dt);
                    set_param(hblk,'ParamDataTypeStr',new_fixdt_str);
                catch %#ok
                      % do not do any thing
                end
            end
        end
    end
catch ME %#ok<NASGU> 

end

% Gain is always tunable
set_param(hblk, 'Gain', coeff);


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
