classdef ellipbpastop < fmethod.ellipbpfstop
%ELLIPBPASTOP   Construct an ELLIPBPASTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.ellipbpastop class
%   fmethod.ellipbpastop extends fmethod.ellipbpfstop.
%
%    fmethod.ellipbpastop properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstoporboth enumeration: {'passband','stopband','both'}'  
%
%    fmethod.ellipbpastop methods:
%       getexamples -   Get the examples.



methods  % constructor block
  function h = ellipbpastop

  % h = fmethod.ellipbpastop;
  
  h.DesignAlgorithm = 'Elliptic';


  end  % ellipbpastop

end  % constructor block

methods  % public methods
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

