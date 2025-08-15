classdef (Abstract) abstractellip < fmethod.abstractclassiciir
%ABSTRACTELLIP   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstractellip class
%   fmethod.abstractellip extends fmethod.abstractclassiciir.
%
%    fmethod.abstractellip properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstoporboth enumeration: {'passband','stopband','both'}'  
%
%    fmethod.abstractellip methods:
%       apspecord -  Specify order ellip analog prototype.
%       computeq2 -   Alternate algorithm to compute q
%       get_matchexactly -   PreGet function for the 'matchexactly' property.
%       getdesignpanelstate -   Get the designpanelstate.
%       set_matchexactly -   PreSet function for the 'matchexactly' property.
%       tospecifyord -   Convert from minimum-order to specify order.


properties (Access=protected, AbortSet, SetObservable, GetObservable)
  %PRIVMATCHEXACTLY Property is of type 'passstoporboth enumeration: {'passband','stopband','both'}'
  privMatchExactly = 'both';
end

properties (Transient, SetObservable, GetObservable)
  %MATCHEXACTLY Property is of type 'passstoporboth enumeration: {'passband','stopband','both'}' 
  MatchExactly 
end


methods 
    function value = get.MatchExactly(obj)
    value = get_matchexactly(obj,obj.MatchExactly);
    end
    %----------------------------------------------------------------------
    function set.MatchExactly(obj,value)
    value = validatestring(value,getAllowedStringValues(obj,'MatchExactly'),'','MatchExactly');
    obj.MatchExactly = set_matchexactly(obj,value);
    end
    %----------------------------------------------------------------------
    function set.privMatchExactly(obj,value)
    value = validatestring(value,{'passband','stopband','both'},'','privMatchExactly');
    obj.privMatchExactly = value;
    end

end   % set and get functions 

methods
  %This function will produce the list of values for an enumerated
  %property
  function vals = getAllowedStringValues(obj,prop)
    if strcmp(prop,'MatchExactly')
      vals = {'passband','stopband','both'}';
    else
      vals = {};
    end
  end
end

methods  % public methods
  [sos,g,Astop] = apspecord(h,N,Wp,Apass,k,q)
  [q,k] = computeq2(this,N,D)
  matchexactly = get_matchexactly(this,matchexactly)
  s = getdesignpanelstate(this)
  matchexactly = set_matchexactly(this,matchexactly)
  has = tospecifyord(h,hasmin)
end  % public methods 


methods (Hidden) % possibly private or hidden
  [sos,g] = alpastop(h,N,Wp,Apass,Astop)
  [sos,g,Astop] = alpfstop(h,N,Wp,Ws,Apass)
  [Omega,V] = computeOmega(this,N,q,k)
  [q,k] = computeq(h,Wp)
  help(this)
  help_ellip(this)
  help_matchexactly(this)
  sos = stosbywc(h,sos,Wc)
  s = thisdesignopts(this,s)
end  % possibly private or hidden 

end  % classdef

