function setappdata(hFDA,fieldname,val)
%SETAPPDATA  Set the specified data in appdata.
%   SETAPPDATA(hFDA, FIELDNAME, VALUE) sets the data VALUE in 
%   FIELDNAME of the Application Data associated with hFDA.

%   Author(s): R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,3);

if nargin < 3
	set(hFDA,'ApplicationData',fieldname);
	
else
	
	data = get(hFDA,'ApplicationData');
	
	data.(fieldname) = val;
	
	set(hFDA,'ApplicationData',data);
end


