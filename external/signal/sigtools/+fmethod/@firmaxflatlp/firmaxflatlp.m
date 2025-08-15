classdef firmaxflatlp < fmethod.abstractfirmaxflat
%FIRMFLP   Construct a FIRMAXFLATLP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.firmaxflatlp class
%   fmethod.firmaxflatlp extends fmethod.abstractfirmaxflat.
%
%    fmethod.firmaxflatlp properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.firmaxflatlp methods:
%       actualdesign -   Design the maximally flat lowpass FIR filter
%       getexamples -   Get the examples.
%       validspecobj -   Return the valid specification object.



methods  % constructor block
  function this = firmaxflatlp

  % this = fmethod.firmaxflatlp;

  this.DesignAlgorithm = 'Maximally flat';
  end  % firmaxflatlp

end  % constructor block

methods  % public methods
  varargout = actualdesign(this,hspecs,varargin)
  examples = getexamples(this)
  vso = validspecobj(this)
end  % public methods 

end  % classdef

