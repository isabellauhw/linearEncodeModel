function varargout = render_statusbar(hFig, str, varargin)
%RENDER_STATUSBAR Render a status bar on the bottom of a MATLAB figure
%   RENDER_STATUSBAR(hFIG) Render a status bar on the bottom of the figure hFIG.
%
%   RENDER_STATUSBAR(hFIG, STR) Render a status bar on the bottom of the figure
%   using STR as the default string.
%
%   See also UPDATE_STATUSBAR.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(1,inf);

if nargin < 2
    str = '';
elseif rem(length(varargin), 2)
    varargin = {str, varargin{:}};
    str = '';
end

% If hFig is not a figure or handle, error out.
if ~ishghandle(hFig, 'figure')
  error(message('signal:render_statusbar:SigErr'))
end

htext = siggetappdata(hFig, 'siggui', 'StatusBar');

if isempty(htext)

    sz = gui_sizes;
    units = get(hFig, 'Units'); set(hFig, 'Units', 'pixels');
    figPos = get(hFig, 'Position'); set(hFig, 'Units', units);
    htext = uicontrol(hFig, ...
        'Style', 'edit', ...
        'Units', 'Pixels', ...
        'Position', [sz.ffs/2 sz.ffs/2 figPos(3)-sz.ffs sz.lh+sz.ffs/2], ...
        'Enable', 'Inactive', ...
        'Visible', 'On', ...
        'HorizontalAlignment', 'Left', ...
        'FontUnits', 'Normalized', ...
        'FontSize', .65, ...
        'Tag', 'StatusBar', ...
        'String', str);
    % Set the units to normalized so it will always stretch across the figure
    set(htext, 'Units','Normalized');
    
    % Save the handle in the figure's appdata for later access
    sigsetappdata(hFig, 'siggui', 'StatusBar', htext);
else
    set(htext, varargin{:});
    if ~isempty(str), set(htext, 'Text', str); end
end

if nargout
    varargout = {htext};
end

% [EOF]
