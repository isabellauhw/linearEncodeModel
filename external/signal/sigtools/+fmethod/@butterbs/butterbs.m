classdef butterbs < fmethod.abstractbutter
%BUTTERBS   Construct a BUTTERBS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.butterbs class
%   fmethod.butterbs extends fmethod.abstractbutter.
%
%    fmethod.butterbs properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.butterbs methods:
%       analogspecs -   Compute analog specifications object.
%       bilineardesign -  Design digital filter from analog specs. using bilinear. 
%       getexamples -   Get the examples.
%       getsosreorder -   Get the sosreorder.
%       preprocessspecs -   Process the specifications
%       validate -   Perform algorithm specific spec. validation.



methods  % constructor block
  function h = butterbs

  % h = fmethod.butterbs;
  
  %Add dynamic properties to the class
  addsosprops(h);
  

  h.DesignAlgorithm = 'Butterworth';


  end  % butterbs

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
  str = validspecobj(h)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

