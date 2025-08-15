classdef eqriplp < fmethod.eqriplpmin
%EQRIPLP   Construct an EQRIPLP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.eqriplp class
%   fmethod.eqriplp extends fmethod.eqriplpmin.
%
%    fmethod.eqriplp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%       Wpass - Property is of type 'posdouble user-defined'  
%       Wstop - Property is of type 'posdouble user-defined'  
%
%    fmethod.eqriplp methods:
%       getdesignpanelstate -   Get the designpanelstate.
%       getexamples -   Get the examples.
%       getvalidstructs -   Get the validstructs.
%       validspecobj -   Returns the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
  %WPASS Property is of type 'posdouble user-defined' 
  Wpass = 1;
  %WSTOP Property is of type 'posdouble user-defined' 
  Wstop = 1;
end


methods  % constructor block
  function this = eqriplp(DensityFactor)

  % this = fmethod.eqriplp;

  this.DesignAlgorithm = 'Equiripple';

  if nargin
      set(this, 'DensityFactor', DensityFactor);
  end

  end  % eqriplp

end  % constructor block

methods 
  function set.Wpass(obj,value)
  validateattributes(value,{'numeric'}, {'positive','scalar'},'','Wpass')
  value=double(value);
  obj.Wpass = value;
  end

  function set.Wstop(obj,value)
  validateattributes(value,{'numeric'}, {'positive','scalar'},'','Wstop')
  value=double(value);
  obj.Wstop = value;
  end

end   % set and get functions 

methods  % public methods
  s = getdesignpanelstate(this)
  examples = getexamples(this)
  validstructs = getvalidstructs(this)
  s = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  args = designargs(this,hs)
  help(this)
end  % possibly private or hidden 

end  % classdef

