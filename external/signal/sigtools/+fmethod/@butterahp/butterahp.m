classdef butterahp < fmethod.abstractbutter
%BUTTERAHP   Construct a BUTTERAHP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.butterahp class
%   fmethod.butterahp extends fmethod.abstractbutter.
%
%    fmethod.butterahp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.butterahp methods:

methods  % constructor block
  function h = butterahp

  % h = fmethod.butterahp;
  
  %Add dynamic properties to the class
  addsosprops(h);
  
  h.DesignAlgorithm = 'Butterworth';


  end  % butterahp

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

