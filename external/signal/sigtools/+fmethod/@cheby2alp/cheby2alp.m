classdef cheby2alp < fmethod.abstractcheby2
%CHEBY2ALP   Construct a CHEBY2ALP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.cheby2alp class
%   fmethod.cheby2alp extends fmethod.abstractcheby2.
%
%    fmethod.cheby2alp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.cheby2alp methods:



methods  % constructor block
  function h = cheby2alp

  % h = fmethod.cheby2alp;

  %Add dynamic properties to the class
  addsosprops(h);
  
  h.DesignAlgorithm = 'Chebyshev Type II';


  end  % cheby2alp

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

