function msg = message(id, varargin)
%MESSAGE  Message generates the message from the xlate file
%   MES = MESSAGE(ID) 

%   Copyright 2011 The MathWorks, Inc.

% Get the Message catalog object.
mObj = message(id,varargin{:});

% Get the individual message.
msg  = mObj.getString();

% [EOF]
