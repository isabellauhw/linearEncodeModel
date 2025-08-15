classdef butterhp < fmethod.butterlp
%BUTTERHP   Construct a BUTTERHP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.butterhp class
%   fmethod.butterhp extends fmethod.butterlp.
%
%    fmethod.butterhp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.butterhp methods:
%       bilineardesign -  Design digital filter from analog specs. using bilinear. 
%       getexamples -   Get the examples.
%       getsosreorder -   Get the sosreorder.
%       preprocessspecs -   Processes the specifications
%       validspecobj -   Return the name of the valid specification object.



methods  % constructor block
  function h = butterhp

  % h = fmethod.butterhp;

  h.DesignAlgorithm = 'Butterworth';


  end  % butterhp

end  % constructor block

 methods  % public methods
  [s,g] = bilineardesign(h,has,c)
  examples = getexamples(this)
  sosreorder = getsosreorder(this)
  sosscale(this,Hd)
  specs = preprocessspecs(this,specs)
  str = validspecobj(h)
end  % public methods 


methods (Hidden) % possibly private or hidden
  Hd = createcaobj(this,struct,branch1,branch2)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

