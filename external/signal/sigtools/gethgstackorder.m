function order = gethgstackorder(hg)
%GETHGSTACKORDER Returns the UIStack order for the controls

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

hFig = get(hg, 'Parent');

% Make sure that all the HG objects are on the same figure.
if iscell(hFig)
    hFig = [hFig{:}];
    if numel(unique(hFig)) > 1
        error(message('signal:gethgstackorder:GUIErr'));
    end
    hFig = hFig(1);
end

hv = get(0, 'ShowHiddenHandles'); set(0, 'ShowHiddenHandles', 'On');
ac = get(hFig, 'Children');
set(0, 'ShowHiddenHandles', hv);

for indx = 1:length(hg)
    order(indx) = find(ac == hg(indx));
end

% We want the order to be a bottom of the stack to top of the stack.
order = length(ac)-order+1;

% [EOF]
