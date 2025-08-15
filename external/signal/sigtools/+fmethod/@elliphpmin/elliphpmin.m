classdef elliphpmin < fmethod.elliphpastop
%ELLIPHPMIN   Construct an ELLIPHPMIN object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fmethod.elliphpmin class
%   fmethod.elliphpmin extends fmethod.elliphpastop.
%
%    fmethod.elliphpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%       MatchExactly - Property is of type 'passstoporboth enumeration: {'passband','stopband','both'}'  
%
%    fmethod.elliphpmin methods:
%       analogspecs -   Compute analog specifications object.
%       set_matchexactly -   PreSet function for the 'matchexactly' property.
%       validspecobj -   Return the name of the valid specification object.



methods  % constructor block
  function h = elliphpmin(mode)

  % h = fmethod.elliphpmin;
  
  h.DesignAlgorithm = 'Elliptic';

  if nargin > 0
      h.MatchExactly = mode;
  end


  end  % elliphpmin

end  % constructor block

methods  % public methods
  has = analogspecs(h,hs)
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

