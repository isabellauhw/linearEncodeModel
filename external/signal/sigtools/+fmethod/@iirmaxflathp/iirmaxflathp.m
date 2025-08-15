classdef iirmaxflathp < fmethod.abstractiirmaxflat
%FIRMFLP Construct a IIRMAXFLATHP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.iirmaxflathp class
%   fmethod.iirmaxflathp extends fmethod.abstractiirmaxflat.
%
%    fmethod.iirmaxflathp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%
%    fmethod.iirmaxflathp methods:
%       actualdesign - Design the maximally flat highpass IIR filter
%       designargs - Return the arguments for MAXFLAT
%       getexamples - Get the examples.
%       getsosreorder - Get the sosreorder.
%       validspecobj - Return the valid specification object.



methods  % constructor block
  function this = iirmaxflathp

  %Add dynamic properties to the class
  addsosprops(this);
  
  % this = fmethod.iirmaxflathp;
  this.DesignAlgorithm = 'Generalized Butterworth';


  end  % iirmaxflathp

end  % constructor block

methods  % public methods
  varargout = actualdesign(this,hspecs,varargin)
  args = designargs(~,hspecs)
  examples = getexamples(~)
  sosreorder = getsosreorder(~)
  sosscale(this,Hd)
  vso = validspecobj(~)
end  % public methods 

methods (Static)
   this = loadobj(s)
end

end  % classdef

