function hframes = thisrender(h, arrayh, varargin)
%RENDER  Render this object.
%
%   Inputs:
%       h - handle to the object
%       arrayh - array of handles to frames 

%   Author(s): J. Schickler & R. Losada
%   Copyright 1988-2010 The MathWorks, Inc.

% If nargin is less than 2, arrayh is empty
if nargin < 2, arrayh = []; end

parserenderinputs(h, varargin{:});

setupfiltertype(h);
hframes   = associate(h, arrayh, h.FigureHandle);
objspecificrender(h, varargin{:});
attachlisteners(h);

% ------------------------------------------------------------------
function setupfiltertype(h)

p = findprop(h, 'Visible');
set(p, 'AccessFlags.AbortSet', 'Off');


% ------------------------------------------------------------------
function attachlisteners(h)
%ATTACHLISTENERS Attach a listener to the properties

allframes = allchild(h);

% Attach a listener to the 'spec' properties
l = [ ...
        handle.listener(h, find(h.classhandle.properties, 'Description', 'spec'), ...
        'PropertyPostSet',@setGUIvals); ...
        handle.listener(allframes, 'UserModifiedSpecs',@syncGUIvals); ...
    ];

set(l, 'CallbackTarget', h);

% Store listeners in whenRenderedListeners
lold = get(h,'WhenRenderedListeners');
lnew = [lold,l];
set(h,'WhenRenderedListeners',lnew);

% [EOF]
