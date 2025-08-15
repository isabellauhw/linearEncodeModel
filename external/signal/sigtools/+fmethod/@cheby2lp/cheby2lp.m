classdef cheby2lp < fmethod.abstractcheby2
%CHEBY2LP   Construct a CHEBY2LP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.cheby2lp class
%   fmethod.cheby2lp extends fmethod.abstractcheby2.
%
%    fmethod.cheby2lp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.cheby2lp methods:
%       analogspecs -   Compute analog specifications object.
%       bilineardesign -  Design digital filter from analog specs. using bilinear. 
%       getexamples -   Get the examples.
%       getsosreorder -   Get the sosreorder.



methods  % constructor block
  function h = cheby2lp


  % h = fmethod.cheby2lp;
  
  %Add dynamic properties to the class
  addsosprops(h);
  
  h.DesignAlgorithm = 'Chebyshev type II';


  end  % cheby2lp

end  % constructor block

 methods  % public methods
  has = analogspecs(h,hs)
  [s,g] = bilineardesign(h,has,c)
  examples = getexamples(this)
  sosreorder = getsosreorder(this)
  sosscale(this,Hd)
end  % public methods 


methods (Hidden) % possibly private or hidden
  [s,g] = thisbilineardesign(h,has,c)
  str = validspecobj(h)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

