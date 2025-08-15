classdef elliphpfstop < fmethod.elliplpfstop
%ELLIPHPFSTOP   Construct an ELLIPHPFSTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.elliphpfstop class
%   fmethod.elliphpfstop extends fmethod.elliplpfstop.
%
%    fmethod.elliphpfstop properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstoporboth enumeration: {'passband','stopband','both'}'  
%
%    fmethod.elliphpfstop methods:
%       bilineardesign -  Design digital filter from analog specs. using bilinear. 
%       getexamples -   Get the examples.



methods  % constructor block
  function h = elliphpfstop

  % h = fmethod.elliphpfstop;
  
  h.DesignAlgorithm = 'Elliptic';


  end  % elliphpfstop

end  % constructor block

methods  % public methods
  [s,g] = bilineardesign(h,has,c)
  examples = getexamples(this)
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

