function hlegendtoolbar = render_legendonoffbtn(hToolbar, callback, varargin)
%RENDER_LEGENDONOFFBTN Render the Legend On/Off toggle button
%   RENDER_LEGENDONOFFBTN(H, CB) Render the Legend On/Off togglebutton to
%   the uitoolbar H.  CB will be used as the clicked callback.
%
%   RENDER_LEGENDONOFFBTN(H, CB, ON_CB, OFF_CB) ON_CB will be used as the
%   OnCallback and OFF_CB will be used as the OffCallback.

%   Author(s): P. Costa & J. Schickler
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
icons = load('scribeiconcdata');

% Render the ToggleButtons
hlegendtoolbar = uitoggletool('CData',icons.legendCData,...
    'Parent',          hToolbar,...
    'ClickedCallback', callback,...
    'OnCallback',      on_cb,...
    'OffCallback',     off_cb,...
    'Tag',             'legendonoff',...
    'TooltipString',   getString(message('signal:sigtools:render_legendonoffbtn:TurnLegendOn')),...
    'Separator',       'On');

% --------------------------------------------------------
function local_cb(hcbo, eventStruct)

state = get(hcbo, 'State');

if strcmpi(state, 'on')
    id = 'signal:sigtools:render_legendonoffbtn:TurnLegendOff';
else
    id = 'signal:sigtools:render_legendonoffbtn:TurnLegendOn';
end

set(hcbo,'TooltipString', getString(message(id)));

% [EOF]
