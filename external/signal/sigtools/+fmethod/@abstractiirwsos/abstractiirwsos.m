classdef (Abstract) abstractiirwsos < fmethod.abstractiir & dynamicprops 
%ABSTRACTIIRWSOS   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.
  
%fmethod.abstractiirwsos class
%   fmethod.abstractiirwsos extends fmethod.abstractiir.
%
%    fmethod.abstractiirwsos properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%
%    fmethod.abstractiirwsos methods:
%       createobj -   Create the filter object from the coefficients.
%       getvalidstructs -   Get the validstructs.
%       sosinitbpbs -   Initialize SOS matrix and scalevals vector for
%       sosinitlphp -   Initialize SOS matrix and scalevals vector for
%       sosscale -   Scale the SOS Filter.
%       thisgetdesignoptstostring - Get field names and values that we want displayed by


properties (AbortSet, SetObservable, GetObservable)
%   %SOSSCALENORM Property is of type 'ustring' 
%   SOSScaleNorm = '';
%   %SOSSCALEOPTS Property is of type 'fdopts.sosscaling' 
%   SOSScaleOpts = fdopts.sosscaling;
end


methods 
%   function value = get.SOSScaleNorm(obj)
%   if ~isfdtbxinstalled
%     error(message('MATLAB:class:GetDenied','SOSScaleNorm','fmethod.abstractiirwsos'));
%   end  
%   value = obj.SOSScaleNorm;
%   end
%   %------------------------------------------------------------------------
%   function value = get.SOSScaleOpts(obj)
%   if ~isfdtbxinstalled
%     error(message('MATLAB:class:GetDenied','SOSScaleOpts','fmethod.abstractiirwsos'));
%   end 
%   value = obj.SOSScaleOpts;
%   end
%   %------------------------------------------------------------------------
%   function set.SOSScaleNorm(obj,value)
%   if ~isfdtbxinstalled
%     error(message('MATLAB:class:SetDenied','SOSScaleNorm','fmethod.abstractiirwsos'));
%   end  
%   validateattributes(value,{'char'}, {'vector'},'','SOSScaleNorm')
%   obj.SOSScaleNorm = set_sosscalenorm(obj,value);
%   end
%   %------------------------------------------------------------------------
%   function set.SOSScaleOpts(obj,value)
%   if ~isfdtbxinstalled
%     error(message('MATLAB:class:SetDenied','SOSScaleOpts','fmethod.abstractiirwsos'));
%   end
%   validateattributes(value,{'fdopts.sosscaling'}, {'scalar'},'','SOSScaleOpts')
%   obj.SOSScaleOpts = set_sosscaleopts(obj,value);
%   end

end   % set and get functions 

methods  % public methods
  Hd = createobj(this,coeffs)
  validstructs = getvalidstructs(this)
  [s,g] = sosinitbpbs(h,N,ai1,ai2,ai3,ai4,fog)
  [s,g] = sosinitlphp(h,N)
  sosscale(this,Hd)
  [sOut,fnOut] = thisgetdesignoptstostring(this,s,fn)
end  % public methods 

methods (Access = protected)
  addsosprops(this)
end
  
methods (Hidden) % possibly private or hidden
  validstructs = fdfvalidstructs(this)
end  % possibly private or hidden 

end  % classdef

function norm = set_sosscalenorm(this, norm) %#ok

if ~isempty(norm) && ~any(strcmp(norm, {'Linf', 'linf', 'L1', 'l1', 'L2', 'l2'}))
    error(message('signal:fmethod:abstractiirwsos:schema:InvalidEnum'));
end

end  % set_sosscalenorm


% -------------------------------------------------------------------------
function opts = set_sosscaleopts(this, opts) %#ok

opts = copy(opts);

end  % set_sosscaleopts


% [EOF]
