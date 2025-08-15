function update_statusbar(hFig, str, varargin)
%UPDATE_STATUSBAR Update the status of the status bar
%   UPDATE_STATUSBAR(hFIG, STR) Update the status to the string STR.
%
%   See also RENDER_STATUSBAR.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,inf);

if rem(length(varargin), 2)
    error(message('signal:update_statusbar:Nargchk'));
end

if ~ishghandle(hFig, 'figure')
    error(message('signal:update_statusbar:FirstInputMustBeHandle'))   
end
if ~ischar(str) 
    error(message('signal:update_statusbar:SecondInputMustBeString'))   
end

% Make sure the string is only one line of text.
str(str == newline) = ' ';
str = str';
str = str(:)';

h = siggetappdata(hFig, 'siggui', 'StatusBar');
if ~isempty(h)
    set(h, varargin{:}, 'String', str);
    drawnow expose;
end

% [EOF]
