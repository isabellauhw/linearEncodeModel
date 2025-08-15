classdef cheby1alp < fmethod.abstractcheby1
%CHEBY1ALP   Construct a CHEBY1ALP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.cheby1alp class
%   fmethod.cheby1alp extends fmethod.abstractcheby1.
%
%    fmethod.cheby1alp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.cheby1alp methods:



methods  % constructor block
  function h = cheby1alp

  % h = fmethod.cheby1alp;

  %Add dynamic properties to the class
  addsosprops(h);
  
  h.DesignAlgorithm = 'Chebyshev Type I';


  end  % cheby1alp

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

