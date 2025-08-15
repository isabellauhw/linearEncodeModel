function thisrender(this,varargin)
%RENDER Render the entire filter order GUI component.
% Render the frame and uicontrols

%   Author(s): Z. Mecklai, J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

pos  = parserenderinputs(this, varargin{:});

if isempty(pos)
    sz  = gui_sizes(this);
    pos = sz.pixf*[217 188 178 72];
end

framewlabel(this,pos,getString(message('signal:sigtools:siggui:FilterOrder')));

rendercontrols(this, pos);

cshelpcontextmenu(this, 'fdatool_numden_filterorder_specs');

% [EOF]
