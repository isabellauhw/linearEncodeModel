classdef eqripsbarbmag < fmethod.abstracteqripsbarbmagord
%EQRIPSBARBMAG   Construct an EQRIPSBARBMAG object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.eqripsbarbmag class
%   fmethod.eqripsbarbmag extends fmethod.abstracteqripsbarbmagord.
%
%    fmethod.eqripsbarbmag properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%       Weights - Property is of type 'double_vector user-defined'  
%
%    fmethod.eqripsbarbmag methods:
%       actualdesign - Perform the actual design.



methods  % constructor block
  function this = eqripsbarbmag

  % this = fmethod.eqripsbarbmag;

  this.DesignAlgorithm = 'Equiripple';


  end  % eqripsbarbmag

end  % constructor block

methods  % public methods
  varargout = actualdesign(this,hspecs,varargin)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
  m = thiscomplexmethod(~)
  s = thisdesignopts(~,s)
  m = thisrealmethod(~)
end  % possibly private or hidden 

end  % classdef

