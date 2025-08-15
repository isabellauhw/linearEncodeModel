classdef iirmaxflatlp < fmethod.abstractiirmaxflat
%FIRMFLP   Construct a IIRMAXFLATLP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.iirmaxflatlp class
%   fmethod.iirmaxflatlp extends fmethod.abstractiirmaxflat.
%
%    fmethod.iirmaxflatlp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%
%    fmethod.iirmaxflatlp methods:
%       actualdesign -   Design the maximally flat lowpass IIR filter
%       designargs -   Return the arguments for MAXFLAT
%       getexamples -   Get the examples.
%       getsosreorder -   Get the sosreorder.
%       validspecobj -   Return the valid specification object.



methods  % constructor block
  function this = iirmaxflatlp

  %Add dynamic properties to the class
  addsosprops(this);
  
  % this = fmethod.iirmaxflatlp;
  this.DesignAlgorithm = 'Generalized Butterworth';


  end  % iirmaxflatlp

end  % constructor block

methods  % public methods
  varargout = actualdesign(this,hspecs,varargin)
  args = designargs(this,hspecs)
  examples = getexamples(this)
  sosreorder = getsosreorder(this)
  sosscale(this,Hd)
  vso = validspecobj(this)
end  % public methods 

methods (Static)
   this = loadobj(s)
end

end  % classdef

