function updatenumbers(this)
%UPDATENUMBERS Update the numbers

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

h = get(this, 'Handles');

roots = get(this, 'Roots');

if isfield(h, 'numbers')
    delete(h.numbers(ishghandle(h.numbers)));
end
h.numbers = [];

if ~isempty(roots)
    h.numbers = drawpznumbers(double(roots, 'conj'), h.axes, 'Visible', this.Visible);
end
set(this, 'Handles', h);

% [EOF]
