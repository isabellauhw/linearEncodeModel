classdef cheby2bs < fmethod.abstractcheby2
%CHEBY2BS   Construct a CHEBY2BS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.cheby2bs class
%   fmethod.cheby2bs extends fmethod.abstractcheby2.
%
%    fmethod.cheby2bs properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.cheby2bs methods:
%       analogspecs -   Compute analog specifications object.
%       bilineardesign -  Design digital filter from analog specs. using bilinear. 
%       getexamples -   Get the examples.
%       getsosreorder -   Get the sosreorder.
%       validate -   Perform algorithm specific spec. validation.



methods  % constructor block
  function h = cheby2bs

  % h = fmethod.cheby2bs;

  %Add dynamic properties to the class
  addsosprops(h);
  
  h.DesignAlgorithm = 'Chebyshev type II';


  end  % cheby2bs

end  % constructor block

methods  % public methods
  has = analogspecs(h,hs)
  [s,g] = bilineardesign(h,has,c)
  examples = getexamples(this)
  sosreorder = getsosreorder(this)
  sosscale(this,Hd)
  validate(h,specs)
end  % public methods 

methods (Hidden) % possibly private or hidden
  str = validspecobj(h)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

