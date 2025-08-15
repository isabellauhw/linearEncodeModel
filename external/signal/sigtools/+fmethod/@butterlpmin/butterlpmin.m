classdef butterlpmin < fmethod.butterlp
%BUTTERLPMIN   Construct a BUTTERLPMIN object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fmethod.butterlpmin class
%   fmethod.butterlpmin extends fmethod.butterlp.
%
%    fmethod.butterlpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.butterlpmin methods:
%       analogspecs -   Compute analog specifications object.
%       getexamples -   Get the examples.
%       set_matchexactly -   PreSet function for the 'matchexactly' property.



methods  % constructor block
  function h = butterlpmin(matchExactly)

  % h = fmethod.butterlpmin;

 
  h.DesignAlgorithm = 'Butterworth';

  if nargin
      h.MatchExactly = matchExactly;
  end


  end  % butterlpmin

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

