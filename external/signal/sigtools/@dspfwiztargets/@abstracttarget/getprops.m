function p = getprops(hTar)
%GETPROPS Get the schema.prop of the non-dynamic properties.

%    This function determines which dynamic properties will be created at
%    the container level (parameter class).

%    Copyright 1995-2010 The MathWorks, Inc.

p = get(classhandle(hTar), 'Properties');
