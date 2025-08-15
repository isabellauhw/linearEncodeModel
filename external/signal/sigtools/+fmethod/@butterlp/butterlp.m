classdef butterlp < fmethod.abstractbutter
%BUTTERLP   Construct a BUTTERLP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.butterlp class
%   fmethod.butterlp extends fmethod.abstractbutter.
%
%    fmethod.butterlp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.butterlp methods:
%       analogspecs -   Compute analog specifications object.
%       bilineardesign -  Design digital filter from analog specs. using bilinear. 
%       getexamples -   Get the examples.
%       getsosreorder -   Get the sosreorder.
%       validspecobj -   Returns the valid specification object.



methods  % constructor block
  function h = butterlp

  % h = fmethod.butterlp;
  
  %Add dynamic properties to the class
  addsosprops(h);
  
  h.DesignAlgorithm = 'Butterworth';


  end  % butterlp

end  % constructor block

methods  % public methods
  has = analogspecs(h,hs)
  [s,g] = bilineardesign(h,has,c)
  examples = getexamples(this)
  sosreorder = getsosreorder(this)
  sosscale(this,Hd)
  str = validspecobj(h)
end  % public methods 


methods (Hidden) % possibly private or hidden
  specs = preprocessspecs(this,specs)
  [s,g] = thisbilineardesign(h,has,c)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

