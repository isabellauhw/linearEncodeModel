classdef butterhpmin < fmethod.butterhp
%BUTTERHPMIN   Construct a BUTTERHPMIN object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fmethod.butterhpmin class
%   fmethod.butterhpmin extends fmethod.butterhp.
%
%    fmethod.butterhpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstop enumeration: {'passband','stopband'}'  
%
%    fmethod.butterhpmin methods:
%       analogspecs -   Compute analog specifications object.
%       getexamples -   Get the examples.
%       getsosreorder -   Get the sosreorder.
%       help -   Help for the Highpass minimum order butterworth design.
%       set_matchexactly -   PreSet function for the 'matchexactly' property.



methods  % constructor block
  function h = butterhpmin(matchExactly)

  % h = fmethod.butterhpmin;
  
  h.DesignAlgorithm = 'Butterworth';

  if nargin
      h.MatchExactly = matchExactly;
  end

  end  % butterhpmin

end  % constructor block

 methods  % public methods
  has = analogspecs(h,hs)
  examples = getexamples(this)
  sosreorder = getsosreorder(this)
  sosscale(this,Hd)
  help(this)
  matchexactly = set_matchexactly(this,matchexactly)
end  % public methods 


methods (Hidden) % possibly private or hidden
  N = modifyord(this,N)
  s = thisdesignopts(this,s)
  str = validspecobj(h)
end  % possibly private or hidden 

methods (Static)
   this = loadobj(s)
end

end  % classdef

