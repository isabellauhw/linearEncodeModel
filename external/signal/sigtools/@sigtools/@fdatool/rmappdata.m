function rmappdata(hFDA,fieldname)
%RMAPPDATA Remove application-defined data.
%   RMAPPDATA(HFDA, NAME) removes the application-defined data NAME,
%   from the object specified by handle HFDA.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.

narginchk(2,2);

data = get(hFDA,'ApplicationData');

data = rmfield(data,fieldname);

setappdata(hFDA,data);

