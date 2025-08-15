function boolflag = isappdata(hFDA,fieldname)
%ISAPPDATA  True if application-defined data exists.
%   ISAPPDATA(hFDA, FIELDNAME) Returns true if FIELDNAME exists as
%   an application-defined field associated with hFDA.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.

narginchk(2,2);

data = get(hFDA,'ApplicationData');

boolflag = isfield(data,fieldname);

