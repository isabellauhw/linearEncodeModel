function varargout = wintool(varargin)
%WINTOOL Window Design & Analysis Tool (WINTOOL)
%   The WINTOOL command will be removed in a future release. Use
%   windowDesigner instead.
%
%   WINTOOL is a Graphical User Interface (GUI) that allows 
%   you to design and analyze windows.  
%
%   WINTOOL(W1,W2, ..) where W1 and W2 are window objects which initialize
%   the GUI with the windows W1 and W2.
%
%   EXAMPLES :
%   % #1 Analysis of a window object
%   w = sigwin.chebwin(64,100);
%   wintool(w);
%
%   % #2 Analysis of multiple window objects
%   w1 = sigwin.bartlett(64);
%   w2 = sigwin.hamming(64);
%   wintool(w1,w2);
%
%   See also WINDOWDESIGNER, FILTERDESIGNER, SPTOOL.

%   Author(s): V.Pellissier
%   Copyright 1988-2016 The MathWorks, Inc.

warning(message('signal:wintool:FunctionToBeRemoved'));
[varargout{1:nargout}] = windowDesigner(varargin{:});

% [EOF]
