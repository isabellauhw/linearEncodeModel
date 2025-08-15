classdef cheby1ahp < fmethod.abstractcheby1
%CHEBY1AHP   Construct a CHEBY1AHP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.cheby1ahp class
%   fmethod.cheby1ahp extends fmethod.abstractcheby1.
%
%    fmethod.cheby1ahp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.cheby1ahp methods:



methods  % constructor block
  function h = cheby1ahp

  % h = fmethod.cheby1ahp;
  
  %Add dynamic properties to the class
  addsosprops(h);
  
  h.DesignAlgorithm = 'Chebyshev type I';


  end  % cheby1ahp

end  % constructor block

methods
  sosscale(this,Hd)
end

methods (Hidden) % possibly private or hidden
  Ha = design(h,N,wp,rp)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

