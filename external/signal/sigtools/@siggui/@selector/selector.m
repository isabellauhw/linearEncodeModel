function this = selector(name, tags, labels, selection, subselection)
%SELECTOR Constructor for the generic Selector
%   H = SIGGUI.SELECTOR(NAME, TAGS, LABELS) Create a selector object whose name
%   is NAME.  TAGS is a cell array of strings which are used to identify
%   selections made.  LABELS is a cell array of strings which are used to label
%   the radio buttons which are created by the RENDER method.  TAGS and LABELS
%   must be the same size.
%
%   TAGS and LABELS can be nested cell array.  If this format is used the second
%   layer inside the cell array is used to identify the SubSelection.  When
%   rendered popup menus will be used to show the subselections available.
%
%    H = SIGGUI.SELECTOR(NAME, TAGS, LABELS, DEFAULT) Create a selector object
%   which has DEFAULT selected.
%
%   EXAMPLES:
%   
%   % #1 Create a selector to choose your favorite ice cream
%   tags    = {'vanilla', 'chocolate', 'strawberry'};
%   strings = {'Vanilla', 'Chocolate', 'Strawberry'};
%   name    = 'What is your favorite Ice Cream?';
%   h       = siggui.selector(name, tags, strings);
%   hFig    = figure('position',[200 200 212 180], ...
%      'Menubar', 'None');
%
%   % Execute these lines one at a time.
%   render(h, hFig, [10 10 192 160]);
%   set(h, 'Visible', 'On');
%   disableselection(h, 'strawberry', 'vanilla')
%
%   % #2 Create a more complicated ice cream selector
%   tags    = {'vanilla', 'chocolate', 'strawberry', ...
%             {'withcandy', 'butterfinger', 'reesespieces', 'm&m'}};
%   strings = {'Vanilla', 'Chocolate', 'Strawberry', ...
%             {'With Candy', 'ButterFinger', 'Reese''s Pieces', 'M&M''s'}};
%   name    = 'What is your favorite Ice Cream?';
%   h       = siggui.selector(name, tags, strings,tags{2});
%   hFig    = figure('position',[200 200 222 180], ...
%      'Menubar', 'None');
%
%   % Execute these lines one at a time.
%   render(h, hFig, [10 10 202 160]);
%   set(h, 'Visible', 'On');
%   disableselection(h, 'strawberry', 'vanilla')
%   setgroup(h, 'withcandy', {'butterfinger', 'reesespieces'}, {'ButterFinger', 'Reese''''s Pieces'});
%
%   See Also DISABLESELECTION, ENABLESELECTION, SETGROUP, RENDER.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(3,5);

validate_inputs(tags, labels);

% Instantiate the object
this = siggui.selector;

% Set up the object
set(this, 'Identifiers', tags);
set(this, 'Strings', labels);
set(this, 'Version', 1.0);
set(this, 'Name', name);

if nargin < 5
    subselections = getsubselections(this);
    subselection  = subselections{1};
    if nargin < 4
        selections = getallselections(this);
        selection  = selections{1};
    end
end

% Set the objects original selection
set(this, 'Selection', selection);

if ~isempty(subselection)
    set(this, 'SubSelection', subselection);
end

% -------------------------------------------------------------
function validate_inputs(tags, labels)

i = 1;

if length(labels) ~= length(tags)
    error(message('signal:siggui:selector:selector:InvalidStringIdentLength'))
end

while i <= length(labels)
    if iscell(labels{i})
        diff = length(tags{i}) - length(labels{i});
        if ~iscell(tags{i})
            error(message('signal:siggui:selector:selector:InvalidTagLength'))
        elseif diff > 1 | diff < 0
            error(message('signal:siggui:selector:selector:InvalidTagLength'))
        end
    elseif iscell(tags{i})
        diff = length(tags{i}) - length(labels{i});
        if ~iscell(labels{i})
            error(message('signal:siggui:selector:selector:InvalidTagLength'))
        elseif diff > 1 | diff < 0
            error(message('signal:siggui:selector:selector:InvalidTagLength'))
        end
    elseif ~ischar(labels{i}) | ~ischar(tags{i})
        error(message('signal:siggui:selector:selector:InvalidInput'))        
    end
    i = i + 1;
end

% [EOF]
