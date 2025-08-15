function resizefcn(this, varargin)
% Layout the uis if figure is different from default
% H - Input is the handle to the object after all children have been added
% IdealSize - Size at which the figure would ideally have been created

%   Author(s): Z. Mecklai
%   Copyright 1988-2017 The MathWorks, Inc.

siggui_resizefcn(this, varargin{:});

% Get the children (if any), ignore dialogs
hC = find(allchild(this), '-depth', 0, '-not', '-isa', 'siggui.dialog');

for indx = 1:length(hC)
    if isrendered(hC(indx))
        resizefcn(hC(indx), varargin{:});
    end
end


% [EOF]
