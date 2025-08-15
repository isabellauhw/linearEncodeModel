classdef (Abstract) abstractrcoswin < fmethod.abstractrcosfir
%ABSTRACTRCOSWIN   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstractrcoswin class
%   fmethod.abstractrcoswin extends fmethod.abstractrcosfir.
%
%    fmethod.abstractrcoswin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.abstractrcoswin methods:
%       designargs - Return the arguments for the design method
%       rcoswindesign - Design a raised cosine filter



methods  % public methods
  args = designargs(this,hspecs)
  b = rcoswindesign(this,hspecs,shape)
end  % public methods 

end  % classdef

