classdef ellipbpmin < fmethod.ellipbpastop
%ELLIPBPMIN   Construct an ELLIPBPMIN object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fmethod.ellipbpmin class
%   fmethod.ellipbpmin extends fmethod.ellipbpastop.
%
%    fmethod.ellipbpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstoporboth enumeration: {'passband','stopband','both'}'  
%
%    fmethod.ellipbpmin methods:
%       analogspecs -   Compute analog specifications object.
%       doubleord -   Return true if filter order must be doubled.
%       getexamples -   Get the examples.
%       set_matchexactly -   PreSet function for the 'matchexactly' property.
%       validspecobj -   Return the name of the valid specification object.



methods  % constructor block
  function h = ellipbpmin(mode)

  % h = fmethod.ellipbpmin;
  
  h.DesignAlgorithm = 'Elliptic';

  if nargin > 0
      h.MatchExactly = mode;
  end

  end  % ellipbpmin

end  % constructor block

 methods  % public methods
  has = analogspecs(h,hs)
  bl = doubleord(h)
  examples = getexamples(this)
  matchexactly = set_matchexactly(this,matchexactly)
  sosscale(this,Hd)
  vso = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
  N = modifyord(this,N)
  s = thisdesignopts(this,s)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

