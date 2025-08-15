function thisunrender(this)
%THISUNRENDER Unrender for the parameter dialog

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

for indx = 1:numel(this.BaseListeners)
    delete(this.BaseListeners{indx});
end

hFig = get(this, 'FigureHandle');
if ~isempty(hFig) && ishghandle(hFig)
    delete(hFig);
end

% Not sure why this was here but it was causing problems.
% % Reset the parameters.
% hPrm = get(this, 'Parameters');
% for indx = 1:length(hPrm)
%     send(hPrm(1), 'UserModified', sigdatatypes.sigeventdata(hPrm(1), ...
%     'UserModified', get(hPrm(1), 'Value')));
% end

% [EOF]
