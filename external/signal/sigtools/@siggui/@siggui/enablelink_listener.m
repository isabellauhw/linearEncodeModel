function enablelink_listener(this, eventData, enabvalue, varargin)
%ENABLELINK_LISTENER   Listener to link enable states.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if ischar(eventData), prop = eventData;
else,                 prop = get(eventData.Source, 'Name'); end

value = get(this, prop);
if ~iscell(enabvalue), enabvalue = {enabvalue}; end

enab = 'Off';
indx = 1;
while strcmpi(enab, 'off') && length(enabvalue) >= indx
    if ischar(value) && strcmpi(value, enabvalue{indx}) || isequal(value, enabvalue{indx})
        enab = this.Enable;
    end
    indx = indx + 1;
end

if strcmpi(varargin{end}, '-update')
    update = true;
    varargin(end) = [];
else
    update = false;
end

% Gather the handles to disable.
if ischar(varargin{1})
    h = get(this, 'Handles');
    henab = [];
    for indx = 1:length(varargin)
        henab = [henab; h.(varargin{indx})];
        if isfield(h, [varargin{indx} '_lbl'])
            henab = [henab; h.([varargin{indx} '_lbl'])];
        end
    end
    setenableprop(henab(:), enab, false);
elseif isa(varargin{1}, 'siggui.siggui')
    set([varargin{:}], 'Enable', enab);
else
    error(message('signal:siggui:siggui:enablelink_listener:invalidLink'));
end

if update
    for indx = 1:length(varargin)
        prop_listener(this, varargin{indx});
    end
end

% [EOF]
