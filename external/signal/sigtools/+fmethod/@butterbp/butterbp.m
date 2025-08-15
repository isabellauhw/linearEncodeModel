classdef butterbp < fmethod.abstractbutter
%BUTTERBP   Construct a BUTTERBP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.butterbp class
%   fmethod.butterbp extends fmethod.abstractbutter.
%
%    fmethod.butterbp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.butterbp methods:
%       analogspecs -   Compute analog specifications object.
%       bilineardesign -  Design digital filter from analog specs. using bilinear. 
%       getexamples -   Get the examples.
%       getsosreorder -   Get the sosreorder.
%       preprocessspecs -   Process the specifications
%       validate -   Perform algorithm specific spec. validation.



methods  % constructor block
  function h = butterbp

  % h = fmethod.butterbp;

  %Add dynamic properties to the class
  addsosprops(h);
  
  h.DesignAlgorithm = 'Butterworth';


  end  % butterbp

end  % constructor block

methods  % public methods
  has = analogspecs(h,hs)
  [s,g] = bilineardesign(h,has,c)
  examples = getexamples(this)
  sosreorder = getsosreorder(this)
  sosscale(this,Hd)
  specs = preprocessspecs(this,specs)
  validate(h,specs)
end  % public methods 


methods (Hidden) % possibly private or hidden
  Hd = createcaobj(this,struct,branch1,branch2)
  str = validspecobj(h)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

