classdef butteralpmin < fmethod.butterlpmin
%BUTTERALPMIN   Construct a BUTTERALPMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.butteralpmin class
%   fmethod.butteralpmin extends fmethod.butterlpmin.
%
%    fmethod.butteralpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.butteralpmin methods:



methods  % constructor block
  function h = butteralpmin

  % h = fmethod.butteralpmin;

  h.DesignAlgorithm = 'Butterworth';


  end  % butteralpmin

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

