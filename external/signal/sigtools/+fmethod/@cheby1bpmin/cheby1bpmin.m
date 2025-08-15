classdef cheby1bpmin < fmethod.cheby1bp
%CHEBY1BPMIN   Construct a CHEBY1BPMIN object.

%   Copyright 1999-2017 The MathWorks, Inc.
  
%fmethod.cheby1bpmin class
%   fmethod.cheby1bpmin extends fmethod.cheby1bp.
%
%    fmethod.cheby1bpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.cheby1bpmin methods:
%       analogspecs -   Compute analog specifications object.
%       doubleord -   Return true if filter order must be doubled.
%       getexamples -   Get the examples.
%       set_matchexactly -   PreSet function for the 'matchexactly' property.
%       validate -   Perform algorithm specific spec. validation.



methods  % constructor block
  function h = cheby1bpmin(matchExactly)

  % h = fmethod.cheby1bpmin;
  
  h.DesignAlgorithm = 'Chebyshev type I';

  if nargin
      h.MatchExactly = matchExactly;
  end


  end  % cheby1bpmin

end  % constructor block

methods  % public methods
  has = analogspecs(h,hs)
  bl = doubleord(h)
  examples = getexamples(this)
  matchexactly = set_matchexactly(this,matchexactly)
  sosscale(this,Hd)
  validate(h,specs)
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

