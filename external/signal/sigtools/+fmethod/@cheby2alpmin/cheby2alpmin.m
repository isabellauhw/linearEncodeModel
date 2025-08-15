classdef cheby2alpmin < fmethod.cheby2lpmin
%CHEBY2ALPMIN   Construct a CHEBY2ALPMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.cheby2alpmin class
%   fmethod.cheby2alpmin extends fmethod.cheby2lpmin.
%
%    fmethod.cheby2alpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.cheby2alpmin methods:



methods  % constructor block
  function h = cheby2alpmin

  % h = fmethod.cheby2alpmin;
  
  h.DesignAlgorithm = 'Chebyshev Type II';


  end  % cheby2alpmin

end  % constructor block

methods
  sosscale(this,Hd)
end

methods (Hidden) % possibly private or hidden
  [s,g] = design(h,wp,ws,rp,rs)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

