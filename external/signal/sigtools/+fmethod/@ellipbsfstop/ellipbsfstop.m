classdef ellipbsfstop < fmethod.abstractellip
%ELLIPBSFSTOP   Construct an ELLIPBSFSTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.ellipbsfstop class
%   fmethod.ellipbsfstop extends fmethod.abstractellip.
%
%    fmethod.ellipbsfstop properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstoporboth enumeration: {'passband','stopband','both'}'  
%
%    fmethod.ellipbsfstop methods:
%       analogspecs -   Compute analog specifications object.
%       bilineardesign -  Design digital filter from analog specs. using bilinear. 
%       getexamples -   Get the examples.
%       getsosreorder -   Get the sosreorder.



methods  % constructor block
  function h = ellipbsfstop

  % h = fmethod.ellipbsfstop;

  %Add dynamic properties to the class
  addsosprops(h);
  
  h.DesignAlgorithm = 'Elliptic';


  end  % ellipbsfstop

end  % constructor block

methods  % public methods
  has = analogspecs(h,hs)
  [s,g] = bilineardesign(h,has,c)
  examples = getexamples(this)
  sosreorder = getsosreorder(this)
  sosscale(this,Hd)
end  % public methods 


methods (Hidden) % possibly private or hidden
  [s,g] = mybilineardesign(h,has,c)
  [s,g] = thisbilineardesign(h,N,sa,ga,c)
  str = validspecobj(h)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

