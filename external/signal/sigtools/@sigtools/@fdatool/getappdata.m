function data = getappdata(hFDA,fieldname)
%GETAPPDATA  Get the specified data stored in appdata.
%   GETAPPDATA(hFDA, FIELDNAME) get the data specified by FIELDNAME
%   in hFDA's Application Data.

%   Author(s): R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(1,2);

data = get(hFDA,'ApplicationData');
if nargin > 1
    try
        data = data.(fieldname);
    catch ME %#ok<NASGU>
        data = [];
    end
end

