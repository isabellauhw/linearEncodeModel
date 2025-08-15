classdef cheby2hp < fmethod.cheby2lp
%CHEBY2HP   Construct a CHEBY2HP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.cheby2hp class
%   fmethod.cheby2hp extends fmethod.cheby2lp.
%
%    fmethod.cheby2hp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.cheby2hp methods:
%       bilineardesign -  Design digital filter from analog specs. using bilinear. 
%       getexamples -   Get the examples.
%       getsosreorder -   Get the sosreorder.



methods  % constructor block
  function h = cheby2hp

  % h = fmethod.cheby2hp;
  
  h.DesignAlgorithm = 'Chebyshev type II';


  end  % cheby2hp

end  % constructor block

methods  % public methods
  [s,g] = bilineardesign(h,has,c)
  examples = getexamples(this)
  sosreorder = getsosreorder(this)
  sosscale(this,Hd)
end  % public methods 


 methods (Hidden) % possibly private or hidden
  Hd = createcaobj(this,struct,branch1,branch2)
  str = validspecobj(h)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

