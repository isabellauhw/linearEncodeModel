function hConvert = convert(varargin)
%CONVERT Create a convert dialog object

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Parse the inputs
[filtobj, WindowStyle, dspMode] = parse_inputs(varargin{:});

% Instantiate the convert dialog object
hConvert = siggui.convert;

% Set the reference filter
hConvert.Filter = filtobj;

% Set up the object
fstruct = get(filtobj, 'FilterStructure');
set(hConvert, 'TargetStructure', fstruct);
set(hConvert, 'WindowStyle', WindowStyle);
set(hConvert, 'Version', 1);
set(hConvert, 'DSPMode', dspMode);

% set(hConvert, 'isApplied', 1);

% ----------------------------------------------------------------
function [filtobj, windowStyle, dspMode] = parse_inputs(varargin)

windowStyle = 'normal';
dspMode     = 0;
narginchk(1,3);

filtobj = varargin{1};

for i = 2:length(varargin)
    if ischar(varargin{i})
        windowStyle = varargin{i};
    elseif isnumeric(varargin{i})
        dspMode = varargin{i};
    else
        error(message('signal:siggui:convert:convert:SigErr'))
    end
end

% [EOF]
