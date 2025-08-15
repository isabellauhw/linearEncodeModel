function s = getstate(this)
%GETSTATE Return the information necessary to recreate the design panel

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

s = siggui_getstate(this);

% Make sure that we have all of the components so that the state is complete.
if isempty(this.CurrentDesignMethod)
    listeners(this, [], 'usermodifiedspecs_listener');
end

h = find(allchild(this), '-not', 'Name', 'Design Method', '-and', ...
    '-not', 'Name', 'Response Type', '-depth', 0);
for indx = 1:length(h)
    s.Components{indx} = getstate(h(indx));
end

% [EOF]
