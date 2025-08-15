function msg = fdatoolmessage(id, varargin)
%FDATOOLMESSAGE Translates the string from an ID.

%   Copyright 2009-2010 The MathWorks, Inc.

% Build up the ID.
id = ['signal:fdatool:' id];

% Get the Message catalog object.
mObj = message(id,varargin{:});

% Get the individual message.
msg  = mObj.getString();

% [EOF]
