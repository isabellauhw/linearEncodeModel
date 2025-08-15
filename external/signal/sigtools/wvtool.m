function varargout = wvtool(varargin)
%WVTOOL Window Visualization Tool.
%   WVTOOL is a Graphical User Interface (GUI) that allows you to analyze windows.  
%
%   WVTOOL(W) launches the Window Visualization Tool with window vector W.
%
%   WVTOOL(W1,W2, ...) will perform an analysis on multiple windows.
%
%   WVTOOL(H) launches the Window Visualization Tool with sigwin object H.
%   Type 'doc sigwin' for more information.
%
%   H = WVTOOL(...) returns the figure handle.
%
%   EXAMPLES:
%   % #1 Analysis of a single window
%   w = chebwin(64,100);
%   wvtool(w);
%
%   % #2 Analysis of multiple vectors
%   w1 = bartlett(64);
%   w2 = hamming(64);
%   wvtool(w1,w2);
%
%   % #3 Analysis of window objects
%   w1 = sigwin.bartlett(64);
%   w2 = sigwin.hamming(64);
%   wvtool(w1,w2);
%
%   See also WINDOWDESIGNER, FVTOOL.

%   Author(s): V.Pellissier
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(1,inf);

% Parse the inputs
[winobjs, winvects] = parse_inputs(varargin{:});

% Instantiate the winview object
h = sigtools.wvtool;
% Render the winview object
render(h);
% Add windows to the viewer
addwin(h, winobjs, winvects);

% Turn visibility on
set(h, 'Visible', 'on');

% Return WVTools' handle
if nargout
    
    % Render zoom buttons to respond to ML zoom commands.
    varargout = {h.FigureHandle, h};
end


% -----------------------------------------------------
function [winobjs, winvects] = parse_inputs(varargin)
% Input arguments must be window objects or vectors

winobjs = {};
winvects = {};
for i=1:nargin
    if isa(varargin{i}, 'sigwin.variablelength')
        winobjs{end+1} = varargin{i};
    elseif isnumeric(varargin{i})
        winvects{end+1} = varargin{i};
    else
      error(message('signal:wvtool:SigErr'))
    end
end
    

% [EOF]
