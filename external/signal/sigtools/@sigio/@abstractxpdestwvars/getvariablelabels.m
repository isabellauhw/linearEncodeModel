function P = getvariablelabels(h,P)
%GETVARIABLELABELS GetFunction for the VariableLabels property.

%   Author(s): P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

% Just return what is stored.  The labels and values object might contain a
% translated version of the labels.

P = P(:);

% lvh = getcomponent(h, '-class', 'siggui.labelsandvalues');
% P = get(lvh,'Labels');
% 
% for indx = 1:length(P)
%     P{indx}(end) = [];
% end

% [EOF]
