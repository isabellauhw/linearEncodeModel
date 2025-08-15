classdef cheby1alpmin < fmethod.cheby1lpmin
%CHEBY1ALPMIN   Construct a CHEBY1ALPMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.
  
%fmethod.cheby1alpmin class
%   fmethod.cheby1alpmin extends fmethod.cheby1lpmin.
%
%    fmethod.cheby1alpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.cheby1alpmin methods:



methods  % constructor block
  function h = cheby1alpmin

  % h = fmethod.cheby1alpmin;

  h.DesignAlgorithm = 'Chebyshev type I';


  end  % cheby1alpmin

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

