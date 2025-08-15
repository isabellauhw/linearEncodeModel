classdef (Abstract) abstractrcosmin < fmethod.abstractrcosfir
%ABSTRACTRCOSMIN   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstractrcosmin class
%   fmethod.abstractrcosmin extends fmethod.abstractrcosfir.
%
%    fmethod.abstractrcosmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.abstractrcosmin methods:
%       designargs - Return the arguments for the design method
%       rcosmindesign - Design the filter



methods  % public methods
  args = designargs(this,hspecs)
  b = rcosmindesign(this,hspecs,shape,hd)
end  % public methods 

end  % classdef

