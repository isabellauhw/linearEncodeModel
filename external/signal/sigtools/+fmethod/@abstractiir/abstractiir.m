classdef (Abstract) abstractiir < fmethod.abstractdesign
%ABSTRACTIIR   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstractiir class
%   fmethod.abstractiir extends fmethod.abstractdesign.
%
%    fmethod.abstractiir properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.abstractiir methods:
%       get_structure -   PreGet function for the 'structure' property.
%       getvalidstructs -   Get the validstructs.
%       isfir -   True if the object is fir.



methods  % public methods
  structure = get_structure(this,structure)
  validstructs = getvalidstructs(this)
  b = isfir(this)
end  % public methods 

methods (Hidden) % possibly private or hidden
  help_sosscale(this)
end  % possibly private or hidden 

end  % classdef

