function siggui_cshelpcontextmenu(hObj, cshtag, toolname)
%ADDCSH Add context sensitive help to the frame

% Author(s): J. Schickler
% Copyright 1988-2008 The MathWorks, Inc.

narginchk(2,3);

if isempty(cshtag), return; end

if nargin < 3, toolname = 'fdatool'; end

h = handles2vector(hObj);

% If there are no handles that can use a context menu return.
if isempty(h), return; end

h = h(logical(isprop(h, 'UIContextMenu'))); % G152363

% If there are no handles that can use a context menu return.
if isempty(h), return; end

hc = get(hObj, 'CSHMenu');

if ishghandle(hc), delete(hc); end

hc = cshelpcontextmenu(h, cshtag, toolname);

set(hObj, 'CSHMenu', hc);

% [EOF]
