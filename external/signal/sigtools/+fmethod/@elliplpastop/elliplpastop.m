classdef elliplpastop < fmethod.elliplpfstop
%ELLIPLPASTOP   Construct an ELLIPLPASTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.elliplpastop class
%   fmethod.elliplpastop extends fmethod.elliplpfstop.
%
%    fmethod.elliplpastop properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstoporboth enumeration: {'passband','stopband','both'}'  
%
%    fmethod.elliplpastop methods:
%       bilineardesign -  Design digital filter from analog specs. using bilinear. 
%       getexamples -   Get the examples.



methods  % constructor block
  function h = elliplpastop

  % h = fmethod.elliplpastop;
  
  h.DesignAlgorithm = 'Elliptic';


  end  % elliplpastop

end  % constructor block

methods  % public methods
  [s,g] = bilineardesign(h,has,c)
  examples = getexamples(this)
  sosscale(this,Hd)
end  % public methods 


methods (Hidden) % possibly private or hidden
  [s,g] = mybilineardesign(h,has,c)
  str = validspecobj(h)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end
end  % classdef

