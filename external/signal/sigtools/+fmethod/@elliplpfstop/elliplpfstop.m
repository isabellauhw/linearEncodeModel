classdef elliplpfstop < fmethod.abstractellip
%ELLIPLPFSTOP   Construct an ELLIPLPFSTOP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.elliplpfstop class
%   fmethod.elliplpfstop extends fmethod.abstractellip.
%
%    fmethod.elliplpfstop properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstoporboth enumeration: {'passband','stopband','both'}'  
%
%    fmethod.elliplpfstop methods:
%       analogspecs -   Compute analog specifications object.
%       bilineardesign -  Design digital filter from analog specs. using bilinear. 
%       getexamples -   Get the examples.
%       getsosreorder -   Get the sosreorder.
%       set_matchexactly -   PreSet function for the 'matchexactly' property.



methods  % constructor block
  function h = elliplpfstop

  % h = fmethod.elliplpfstop;

  %Add dynamic properties to the class
  addsosprops(h);
  
  h.DesignAlgorithm = 'Elliptic';


  end  % elliplpfstop

end  % constructor block

methods  % public methods
  has = analogspecs(h,hs)
  [s,g] = bilineardesign(h,has,c)
  examples = getexamples(this)
  sosscale(this,Hd)
  sosreorder = getsosreorder(this)
  matchexactly = set_matchexactly(this,matchexactly)
end  % public methods 


methods (Hidden) % possibly private or hidden
  [s,g] = mybilineardesign(h,has,c)
  [s,g] = thisbilineardesign(h,N,sa,ga)
  str = validspecobj(h)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

