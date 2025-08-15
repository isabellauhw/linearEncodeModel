classdef elliphpastop < fmethod.elliplpastop
%ELLIPHPASTOP   Construct an ELLIPHPASTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.elliphpastop class
%   fmethod.elliphpastop extends fmethod.elliplpastop.
%
%    fmethod.elliphpastop properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstoporboth enumeration: {'passband','stopband','both'}'  
%
%    fmethod.elliphpastop methods:
%       bilineardesign -  Design digital filter from analog specs. using bilinear. 
%       getexamples -   Get the examples.
%       getsosreorder -   Get the sosreorder.



methods  % constructor block
  function h = elliphpastop

  % h = fmethod.elliphpastop;

  h.DesignAlgorithm = 'Elliptic';


  end  % elliphpastop

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

