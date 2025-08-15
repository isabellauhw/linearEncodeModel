function obj = notificationeventdata(hSrc, NType, data)
%SIGEVENTDATA Constructor for the sigeventdata object.

%   Author(s): V. Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.

narginchk(2,3);
if nargin < 3, data = []; end

% Call the built-in constructor which inherits its two
% arguments from the handle.EventData constructor
% which takes a source handle and the name of an event
% that is defined by the class of the source handle.
obj = sigdatatypes.notificationeventdata(hSrc, 'Notification');
% Initialize the Data field with the passed-in value
obj.NotificationType = NType;
obj.Data = data;

% [EOF]
