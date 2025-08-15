function varargout = windowDesigner(varargin)
%WINDOWDESIGNER Window Designer (windowDesigner)
%   WINDOWDESIGNER is a Graphical User Interface (GUI) that allows 
%   you to design and analyze windows.  
%
%   WINDOWDESIGNER(W1,W2, ..) where W1 and W2 are window objects which initialize
%   the GUI with the windows W1 and W2.
%
%   EXAMPLES :
%   % #1 Analysis of a window object
%   w = sigwin.chebwin(64,100);
%   windowDesigner(w);
%
%   % #2 Analysis of multiple window objects
%   w1 = sigwin.bartlett(64);
%   w2 = sigwin.hamming(64);
%   windowDesigner(w1,w2);
%
%   See also FILTERDESIGNER, SPTOOL.

%   Author(s): V.Pellissier
%   Copyright 1988-2017 The MathWorks, Inc.

fprintf(getString(message('signal:sigtools:wintool:InitializingWindowDesignAnalysisTool')));
fprintf('.');

% Parse the inputs
winobjs = parse_inputs(varargin{:});

hWT = sigtools.wintool;
fprintf('.');

render(hWT);
fprintf('.');

setwindow(hWT, winobjs);
fprintf('.');

set(hWT, 'Visible', 'on');

if isunix
    % Increasing the size of the text to avoid text wrap in unix
    hView  = getcomponent(hWT, '-class', 'siggui.winviewer');
    hndls = get(hView, 'Handles');
    pos = get(hndls.text(2),'Position');
    pos = [pos(1)-15, pos(2), pos(3)+15, pos(4)];
    set(hndls.text(2),'Position',pos);
end

if nargout
    varargout = {hWT};
end

fprintf('.');
fprintf([' ' getString(message('signal:sigtools:wintool:Done')) '. \n']);


% -----------------------------------------------------
function winobjs = parse_inputs(varargin)
% Input arguments must be window objects

winobjs = [];

% Add windows
if nargin>0
    for i = 1:length(varargin)
        if ~isa(varargin{i}, 'sigwin.window')
          error(message('signal:wintool:invalidInputs'));                        
        end
        winobjs = [winobjs varargin{i}]; %#ok<AGROW>
    end
else
    winobjs = sigwin.hamming;
end

% [EOF]
