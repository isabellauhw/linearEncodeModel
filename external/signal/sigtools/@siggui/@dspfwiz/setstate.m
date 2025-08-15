function setstate(this, state)
%SETSTATE PreSet function for the 'state' property.

%   Copyright 1995-2011 The MathWorks, Inc.

% We no longer let them choose the blocktype.
if isfield(state, 'blocktype'), state = rmfield(state, 'blocktype'); end
if isfield(state, 'BlockType'), state = rmfield(state, 'BlockType'); end

% Set the input processing option. If loading from a pre R2011b block, then
% set input processing to inherited. 
setInputProcessingState(this,state);

siggui_setstate(this, state);

% [EOF]
