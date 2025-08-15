function update_uis(this)
%SUPER_UPDATE_UIS updates visibility of the labels and value uicontrols

%   Author(s): Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

% Determine the object state
visstate = get(this, 'Visible');

% Get the necessary data and turn the values
% and labels to the current visstate
h = get(this, 'Handles');

% Extract the actual specification values and labels
labels = get(this, 'Labels');
values = get(this, 'Values');

% First set everything to invisible and turn on as appropriate
set(h.labels(union(this.hiddenlabels, (length(labels)+1):this.Maximum)), ...
    'Visible','off')
set(h.values(union(this.hiddenvalues, (length(values)+1):this.Maximum)), ...
    'Visible','off')

for i = 1:length(values)
    if ~any(i == this.hiddenvalues)
        set(h.values(i),...
            'Visible',visstate,...
            'String',values{i});
    end
end

for i = 1:length(labels)
    if ~any(i == this.hiddenlabels)
        set(h.labels(i),...
            'Visible',visstate,...
            'String',getTranslatedString('signal:siggui:labelsandvalues:updateuis',labels{i}));
    end
end

% [EOF]
