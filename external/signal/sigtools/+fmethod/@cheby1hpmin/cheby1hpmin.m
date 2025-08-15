classdef cheby1hpmin < fmethod.cheby1hp
%CHEBY1HPMIN   Construct a CHEBY1HPMIN object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fmethod.cheby1hpmin class
%   fmethod.cheby1hpmin extends fmethod.cheby1hp.
%
%    fmethod.cheby1hpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.cheby1hpmin methods:
%       analogspecs -   Compute analog specifications object.
%       getexamples -   Get the examples.
%       getsosreorder -   Get the sosreorder.
%       set_matchexactly -   PreSet function for the 'matchexactly' property.



methods  % constructor block
  function h = cheby1hpmin(matchExactly)

  % h = fmethod.cheby1hpmin;
  
  h.DesignAlgorithm = 'Chebyshev type I';

  if nargin
      h.MatchExactly = matchExactly;
  end


  end  % cheby1hpmin

end  % constructor block

methods  % public methods
  has = analogspecs(h,hs)
  examples = getexamples(this)
  sosreorder = getsosreorder(this)
  sosscale(this,Hd)
  matchexactly = set_matchexactly(this,matchexactly)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
  N = modifyord(this,N)
  s = thisdesignopts(this,s)
  str = validspecobj(h)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

