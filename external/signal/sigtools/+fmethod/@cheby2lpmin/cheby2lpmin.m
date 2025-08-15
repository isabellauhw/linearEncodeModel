classdef cheby2lpmin < fmethod.cheby2lp
%CHEBY2LPMIN   Construct a CHEBY2LPMIN object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fmethod.cheby2lpmin class
%   fmethod.cheby2lpmin extends fmethod.cheby2lp.
%
%    fmethod.cheby2lpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.cheby2lpmin methods:
%       analogspecs -   Compute analog specifications object.
%       getexamples -   Get the examples.
%       set_matchexactly -   PreSet function for the 'matchexactly' property.



methods  % constructor block
  function h = cheby2lpmin(matchExactly)

  % h = fmethod.cheby2lpmin;

  h.DesignAlgorithm = 'Chebyshev type II';

  if nargin
      h.MatchExactly = matchExactly;
  end


  end  % cheby2lpmin

end  % constructor block

 methods  % public methods
  has = analogspecs(h,hs)
  examples = getexamples(this)
  matchexactly = set_matchexactly(this,matchexactly)
  sosscale(this,Hd)
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

