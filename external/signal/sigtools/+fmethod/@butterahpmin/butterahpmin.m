classdef butterahpmin < fmethod.butterlpmin
%BUTTERAHPMIN   Construct a BUTTERAHPMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.butterahpmin class
%   fmethod.butterahpmin extends fmethod.butterlpmin.
%
%    fmethod.butterahpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.butterahpmin methods:



methods  % constructor block
  function h = butterahpmin

  % h = fmethod.butterahpmin;
  
  h.DesignAlgorithm = 'Butterworth';


  end  % butterahpmin

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

