classdef (Abstract) abstractbutter < fmethod.abstractclassiciir
%ABSTRACTBUTTER   Construct an ABSTRACTBUTTER object.

%   Copyright 1999-2015 The MathWorks, Inc.
  
%fmethod.abstractbutter class
%   fmethod.abstractbutter extends fmethod.abstractclassiciir.
%
%    fmethod.abstractbutter properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.abstractbutter methods:
%       get_matchexactly -   PreGet function for the 'matchexactly' property.
%       getdesignpanelstate -   Get the designpanelstate.
%       help -   Generic help for butterworth designs.
%       help_matchexactly -   Display help for MatchExactly.
%       set_matchexactly -   PreSet function for the 'matchexactly' property.
%       tospecifyord -   Convert from minimum-order to specify order.


properties (Access=protected, AbortSet, SetObservable, GetObservable)
  %PRIVMATCHEXACTLY Property is of type 'passstop enumeration: {'passband','stopband'}'
  privMatchExactly = 'stopband';
end

properties (Transient, SetObservable, GetObservable)
  %MATCHEXACTLY Property is of type 'passstop enumeration: {'passband','stopband'}' 
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
    % Enumerated DataType = 'passstop enumeration: {'passband','stopband'}'
    value = validatestring(value,{'passband','stopband'},'','privMatchExactly');
    obj.privMatchExactly = value;
    end

end   % set and get functions 
    
methods
  %This function will produce the list of values for an enumerated
  %property
  function vals = getAllowedStringValues(obj,prop)
    if strcmp(prop,'MatchExactly')
      vals = {'passband','stopband'}';
    else
      vals = {};
    end
  end
end 

methods  % public methods
  matchexactly = get_matchexactly(this,matchexactly)
  s = getdesignpanelstate(this)
  help(this)
  help_matchexactly(this)
  matchexactly = set_matchexactly(this,matchexactly)
  has = tospecifyord(h,hasmin)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help_butter(this)
  s = thisdesignopts(this,s)
end  % possibly private or hidden 

end  % classdef

