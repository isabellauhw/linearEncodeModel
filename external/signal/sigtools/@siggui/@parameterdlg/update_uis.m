function update_uis(this, eventData)
%UPDATE_UIS   Update the UIControls

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if isempty(this.Parameters), return; end

hPrm    = get(this, 'Parameters');
sparams = get(this, 'StaticParameters');
dparams = get(this, 'DisabledParameters');
h       = get(this, 'Handles');
tags    = get(hPrm, 'Tag');

sindx = [];
dindx = [];

% Find the indices of the parameters to make static.
for i = 1:length(sparams)
    sindx = [sindx find(strcmpi(sparams{i}, tags))];
end

% Find the indices of the parameters to disable.
for i = 1:length(dparams)
    dindx = [dindx find(strcmpi(dparams{i}, tags))];
end

eindx = setdiff(1:length(h.controls), sindx);

if ~isempty(sindx)
    for indx = 1:length(sindx)
        hui = h.controls(sindx(indx)).specpopup;
        str = popupstr(hui);
        if ~isempty(str), set(hui, 'String', str); end
    end
    set(convert2vector(h.controls(sindx)), ...
        'HorizontalAlignment', 'Left', ...
        'Style', 'text', ...
        'BackgroundColor', get(0, 'DefaultUicontrolBackgroundColor'));
end
for indx = 1:length(eindx)
    lindx = eindx(indx);
    set(h.controls(lindx).edit, 'Style', 'edit');
    vv = get(hPrm(lindx), 'ValidValues');
    if iscell(vv)
        vv = getTranslatedStringcell('signal:sigtools:sigdatatypes',vv);
        if strcmpi(get(h.controls(lindx).specpopup, 'Style'), 'text')
            indx = find(strcmpi(vv, get(h.controls(lindx).specpopup, 'String')));
        else
            indx = get(h.controls(lindx).specpopup, 'Value');
        end
        set(h.controls(lindx).specpopup, ...
            'Style', 'popup', ...
            'String', vv, ...
            'Value', indx);
    end
end

eindx = setdiff(1:length(h.controls), dindx);

if ~isempty(dindx)
    setenableprop(convert2vector(h.controls(dindx)), 'Off');
end
if ~isempty(eindx)
    setenableprop(convert2vector(h.controls(eindx)), this.Enable);
end

for indx = 1:length(hPrm)
    vv = get(hPrm(indx), 'ValidValues');
    if iscell(vv) & length(vv) == 1
        setenableprop(convert2vector(h.controls(indx)), 'Off');
    end
end

% [EOF]
