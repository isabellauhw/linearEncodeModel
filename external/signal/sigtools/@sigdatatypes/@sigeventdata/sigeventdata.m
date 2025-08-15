function obj = sigeventdata(hSrc, eventName, data)
%SIGEVENTDATA Constructor for the sigeventdata object.

%   Author(s): V. Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.

narginchk(3,3);

% Call the built-in constructor which inherits its two
% arguments from the handle.EventData constructor
% which takes a source handle and the name of an event
% that is defined by the class of the source handle.
if isobject(hSrc)
  obj = sigdatatypes.sigeventdataMCOS(hSrc, eventName,data);
else
  obj = sigdatatypes.sigeventdata(hSrc, eventName);
end
% Initialize the Data field with the passed-in value
obj.Data = data;



% [EOF]
