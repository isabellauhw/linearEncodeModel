function s = getvalidsysobjstructures(this)
%GETVALIDSYSOBJSTRUCTURES Get valid System object structures for the
%design method at hand

%   Copyright 1999-2017 The MathWorks, Inc.

  % Get all the structures supported by System objects.
  sysObjSupportedStrucs = getsysobjsupportedstructs(this);
  
  % Get structures supported by the design method at hand
  validStructs = getvalidstructs(this);
  
  % Get intersection of structures without changing the order as returned by
  % the getvalidstructs method
  [x, idx] = intersect(validStructs,sysObjSupportedStrucs);  %#ok<ASGLU>
  s = validStructs(sort(idx));
end
