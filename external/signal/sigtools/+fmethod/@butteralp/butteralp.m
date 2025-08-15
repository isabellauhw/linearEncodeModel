classdef butteralp < fmethod.abstractbutter
%BUTTERALP   Construct a BUTTERALP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.butteralp class
%   fmethod.butteralp extends fmethod.abstractbutter.
%
%    fmethod.butteralp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.butteralp methods:



methods  % constructor block
  function h = butteralp

  % h = fmethod.butteralp;
  
  %Add dynamic properties to the class
  addsosprops(h);
  
  h.DesignAlgorithm = 'Butterworth';


  end  % butteralp

end  % constructor block

methods
  sosscale(this,Hd)
end

methods (Hidden) % possibly private or hidden
  Ha = design(h,hs)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

