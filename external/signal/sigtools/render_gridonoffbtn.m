function hlegendtoolbar = render_gridonoffbtn(hToolbar, callback, varargin)
%RENDER_GRIDONOFFBTN Render the Grid On/Off toggle button
%   RENDER_GRIDONOFFBTN(H, CB) Render the Grid On/Off togglebutton to
%   the uitoolbar H.  CB will be used as the clicked callback.
%
%   RENDER_GRIDONOFFBTN(H, CB, ON_CB, OFF_CB) ON_CB will be used as the
%   OnCallback and OFF_CB will be used as the OffCallback.

%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,4);

on_cb = @local_cb;
off_cb = @local_cb;
if nargin > 2
    on_cb = varargin{1};
end
if nargin > 3
    off_cb = varargin{2};
end

% Load the MAT-file with the icon
icons = load('mwtoolbaricons');

% Render the ToggleButtons
hlegendtoolbar = uitoggletool('CData',icons.grid,...
    'Parent',          hToolbar,...
    'ClickedCallback', callback,...
    'OnCallback',      on_cb,...
    'OffCallback',     off_cb,...
    'Tag',             'gridonoff',...
    'TooltipString',   getString(message('signal:sigtools:render_gridonoffbtn:TurnGridOff')),...
    'Separator',       'On');

% --------------------------------------------------------
function local_cb(hcbo, eventStruct) %#ok<INUSD>

state = get(hcbo, 'State');

if strcmpi(state, 'on')
    set(hcbo,'TooltipString', getString(message('signal:sigtools:render_gridonoffbtn:TurnGridOff')));
else
    set(hcbo,'TooltipString', getString(message('signal:sigtools:render_gridonoffbtn:TurnGridOn')));
end



% [EOF]
