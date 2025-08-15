function update_uis(this, varargin)
%UPDATE_UIS  Updates the uis to reflect the current object state

%   Author(s): Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

% Determine the current state of the object
opts = get(this, 'AllOptions');
comments = get(this, 'Comment');

handles = get(this, 'Handles');
rbs = handles.rbs;

% Turn all the radio buttons off
set(rbs, 'Visible', 'off');
% Turn on and set the string for the appropriate number of radio buttons
for indx = 1:length(opts)
    set(rbs(indx), 'Visible', this.Visible,...
        'String', getTranslatedString('signal:siggui:labelsandvalues:updateuis',opts{indx}), ...
        'Tag', opts{indx});
end

% Update the radio buttons to reflect the current option selection
%allOpts = get(this, 'AllOptions');
allOpts = set(this, 'CurrentSelection');
currOpt = get(this, 'CurrentSelection');
currentRb = find(strcmp(allOpts, currOpt));
set(rbs, 'Value', 0);
set(rbs(currentRb), 'Value', 1);


% Get the handle to the text field.
text = handles.text;

% Set the string into the text field
set(text, 'String', comments);

% Set the position of the text field just below the last 
% visible radio button
setunits(this,'Pixels');
set(text, 'Position', calculate_positions(this, handles, length(opts)));
setunits(this, 'Normalized');

if isempty(comments)
    set(handles.divider, 'Visible','off');
    set(handles.text,'Visible','off');
else
    set(handles.divider, 'Visible',this.Visible);
    set(handles.text,'Visible',this.Visible);
end


%-------------------------------------------------------------------------------
function textPos = calculate_positions(this, handles, numrbs)

framePos = get(handles.framewlabel(1), 'Position');
rbsPos   = get(handles.rbs(numrbs)   , 'Position');
divPos   = get(handles.divider       , 'Position');

sz = gui_sizes(this);
sz.indent = 10*sz.pixf;
sz.ufhs = 17*sz.pixf;

textPos = [rbsPos(1),...
        framePos(2) + sz.ufhs,...
        rbsPos(3),...
        rbsPos(2)- framePos(2) - 2*sz.uh];

if isunix, ht = 2;
else,      ht = 1; end

set(handles.divider , 'Position', [rbsPos(1) rbsPos(2) - sz.uuvs rbsPos(3) ht]);


% [EOF]
