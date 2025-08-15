function renderabstractframe(this, varargin)
%RENDERABSTRACTFRAME  Render the abstract frame

%   Author(s): Z. Mecklai
%   Copyright 1988-2017 The MathWorks, Inc.

pos  = parserenderinputs(this, varargin{:});

% Set/get defaults
if isempty(pos)
    sz = gui_sizes(this);
    pos = sz.pixf.*[217 55 178 133-(sz.vffs/sz.pixf)];
end

framewlabel(this, pos, getTranslatedString('signal:sigtools:siggui',get(this, 'Name')));

% Check for existence of additional parameters
if ~isempty(getbuttonprops(this))
    renderactionbtn(this, pos, getString(message('signal:sigtools:siggui:Moreoptions')), ...
                    'editadditionalparameters');
end

% [EOF]
