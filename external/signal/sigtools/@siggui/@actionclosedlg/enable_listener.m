function enable_listener(this, varargin)
%ENABLE_LISTENER   Listener to 'enable'.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

sigcontainer_enable_listener(this, varargin{:})

hd = convert2vector(rmfield(get(this, 'DialogHandles'), 'close'));

set(hd, 'Enable', this.Enable);

% [EOF]
