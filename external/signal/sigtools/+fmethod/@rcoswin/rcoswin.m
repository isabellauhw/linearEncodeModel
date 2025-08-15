classdef rcoswin < fmethod.abstractrcoswin
%RCOSWIN Construct a RCOSWIN object

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.rcoswin class
%   fmethod.rcoswin extends fmethod.abstractrcoswin.
%
%    fmethod.rcoswin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.rcoswin methods:
%       actualdesign - <short description>
%       getexamples -   Get the examples.
%       validspecobj - Return the name of the valid specification object



methods  % constructor block
  function this = rcoswin

  % this = fmethod.rcoswin;

  this.DesignAlgorithm = 'Window';


  end  % rcoswin

end  % constructor block

methods  % public methods
  b = actualdesign(this,hspecs,varargin)
  examples = getexamples(this)
  vso = validspecobj(this)
end  % public methods 

end  % classdef

