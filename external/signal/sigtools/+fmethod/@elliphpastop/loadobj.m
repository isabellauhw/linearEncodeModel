function this = loadobj(s)
%LOADOBJ   Load the object.

%   Copyright 1999-2015 The MathWorks, Inc.

% The input s will be a structure when loading UDD objects, and an object
% when loading MCOS objects. When loading a UDD object, call the
% constructor and assign properties from the input structure.
if isstruct(s)
  this = fmethod.elliphpastop;
  b = fieldnames(s);
  for i = 1:length(b)
    this.(b{i}) = s.(b{i});
  end
else
  this = s;
end

