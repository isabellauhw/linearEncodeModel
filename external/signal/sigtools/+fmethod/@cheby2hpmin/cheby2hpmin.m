classdef cheby2hpmin < fmethod.cheby2hp
%CHEBY2HPMIN   Construct a CHEBY2HPMIN object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fmethod.cheby2hpmin class
%   fmethod.cheby2hpmin extends fmethod.cheby2hp.
%
%    fmethod.cheby2hpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.cheby2hpmin methods:
%       analogspecs -   Compute analog specifications object.
%       getexamples -   Get the examples.
%       set_matchexactly -   PreSet function for the 'matchexactly' property.



methods  % constructor block
  function h = cheby2hpmin(matchExactly)

  % h = fmethod.cheby2hpmin;

  h.DesignAlgorithm = 'Chebyshev type II';

  if nargin
      h.MatchExactly = matchExactly;
  end


  end  % cheby2hpmin

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

