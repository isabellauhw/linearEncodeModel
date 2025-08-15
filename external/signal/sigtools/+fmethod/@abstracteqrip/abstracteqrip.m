classdef (Abstract) abstracteqrip < fmethod.abstractfir
%ABSTRACTEQRIP   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.
  
%fmethod.abstracteqrip class
%   fmethod.abstracteqrip extends fmethod.abstractfir.
%
%    fmethod.abstracteqrip properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%
%    fmethod.abstracteqrip methods:
%       actualdesign - Perform the actual design.
%       get_densityfactor -   PreGet function for the 'densityfactor' property.
%       get_minphase -   PreGet function for the 'minphase' property.
%       getdesignfunction -   Return the design function to be used in the
%       getdesignpanelstate -   Get the designpanelstate.
%       getminorder -   Get the minorder.
%       help_maxphase - HELP_MINPHASE   
%       isminordereven -   True if the object is minordereven.
%       isminorderodd -   True if the object is minorderodd.
%       postprocessminorderargs - Test that the spec is met.
%       privupdateargs - Utility fcn called by POSTPROCESSMINORDERARGS
%       set_densityfactor - PreSet function for the 'densityfactor' property.
%       set_maxphase -   PreSet function for the 'maxphase' property.
%       set_minphase -   PreSet function for the 'minphase' property.
%       thisset_maxphase - SET_MAXPHASE   PreSet function for the 'maxphase' property.


properties (Access=protected, AbortSet, SetObservable, GetObservable)
  %PRIVDENSITYFACTOR Property is of type 'double'
  privDensityFactor = 16;
  %PRIVMINPHASE Property is of type 'bool'
  privMinPhase = false;
end

properties (Transient, SetObservable, GetObservable)
  %DENSITYFACTOR Property is of type 'double' 
  DensityFactor
  %MINPHASE Property is of type 'bool' 
  MinPhase
end


methods 
  function value = get.DensityFactor(obj)
  value = get_densityfactor(obj,obj.DensityFactor);
  end
  %------------------------------------------------------------------------
  function set.DensityFactor(obj,value)
  validateattributes(value,{'numeric'}, {'scalar'},'','DensityFactor')
  value = double(value);
  obj.DensityFactor = set_densityfactor(obj,value);
  end
  %------------------------------------------------------------------------
  function set.privDensityFactor(obj,value)
  obj.privDensityFactor = value;
  end
  %------------------------------------------------------------------------
  function value = get.MinPhase(obj)
  value = get_minphase(obj,obj.MinPhase);
  end
  %------------------------------------------------------------------------
  function set.MinPhase(obj,value)
  validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','MinPhase')
  value = logical(value);
  obj.MinPhase = set_minphase(obj,value);
  end
  %------------------------------------------------------------------------
  function set.privMinPhase(obj,value)
  obj.privMinPhase = value;
  end

end   % set and get functions 

methods  % public methods
  varargout = actualdesign(this,hs)
  densityfactor = get_densityfactor(this,densityfactor)
  minphase = get_minphase(this,minphase)
  desfcn = getdesignfunction(this)
  s = getdesignpanelstate(this)
  minorder = getminorder(this,varargin)
  help_maxphase(this)
  b = isminordereven(this)
  b = isminorderodd(this)
  args = postprocessminorderargs(this,args,hspecs)
  args = privupdateargs(this,args,Nstep)
  densityfactor = set_densityfactor(this,densityfactor)
  maxphase = set_maxphase(this,maxphase)
  minphase = set_minphase(this,minphase)
  maxphase = thisset_maxphase(this,maxphase)
end  % public methods 


methods (Hidden) % possibly private or hidden
  s = eqrip_getdesignpanelstate(this)
  help(this)
  help_equiripple(this)
  help_force(~)
  help_limitedstopband(this)
  help_minphase(this)
  help_stopband(this)
  s = thisdesignopts(this,s)
end  % possibly private or hidden 

end  % classdef

