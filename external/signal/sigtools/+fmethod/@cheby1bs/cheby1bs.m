classdef cheby1bs < fmethod.abstractcheby1
%CHEBY1BS   Construct a CHEBY1BS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.cheby1bs class
%   fmethod.cheby1bs extends fmethod.abstractcheby1.
%
%    fmethod.cheby1bs properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.cheby1bs methods:
%       analogspecs -   Compute analog specifications object.
%       bilineardesign -  Design digital filter from analog specs. using bilinear. 
%       getexamples -   Get the examples.
%       getsosreorder -   Get the sosreorder.
%       validate -   Perform algorithm specific spec. validation.



methods  % constructor block
  function h = cheby1bs

  % h = fmethod.cheby1bs;

  %Add dynamic properties to the class
  addsosprops(h);
  
  h.DesignAlgorithm = 'Chebyshev Type I';

  end  % cheby1bs

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

