function thisunrender(this, varargin)
%THISUNRENDER Allow the subclass to take control

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.

delete(handles2vector(this));

if ~isempty(this.Container) && ishghandle(this.Container)
    delete(this.Container);
end

% [EOF]
