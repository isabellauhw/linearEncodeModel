classdef cheby2bpmin < fmethod.cheby2bp
%CHEBY2BPMIN   Construct a CHEBY2BPMIN object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fmethod.cheby2bpmin class
%   fmethod.cheby2bpmin extends fmethod.cheby2bp.
%
%    fmethod.cheby2bpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.cheby2bpmin methods:
%       analogspecs -   Compute analog specifications object.
%       doubleord -   Return true if filter order must be doubled.
%       getexamples -   Get the examples.
%       set_matchexactly -   PreSet function for the 'matchexactly' property.
%       validate -   Perform algorithm specific spec. validation.



methods  % constructor block
  function h = cheby2bpmin(matchExactly)


  % h = fmethod.cheby2bpmin;

  h.DesignAlgorithm = 'Chebyshev type II';

  if nargin
      h.MatchExactly = matchExactly;
  end


  end  % cheby2bpmin

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

