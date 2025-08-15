classdef sqrtrcoswin < fmethod.abstractrcoswin
%SQRTRCOSWIN Construct a SQRTRCOSWIN object

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.sqrtrcoswin class
%   fmethod.sqrtrcoswin extends fmethod.abstractrcoswin.
%
%    fmethod.sqrtrcoswin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.sqrtrcoswin methods:
%       actualdesign - <short description>
%       getexamples -   Get the examples.
%       validspecobj - Return the name of the valid specification object



methods  % constructor block
  function this = sqrtrcoswin

  % this = fmethod.sqrtrcoswin;

  this.DesignAlgorithm = 'Window';


  end  % sqrtrcoswin

end  % constructor block

methods  % public methods
  b = actualdesign(this,hspecs,varargin)
  examples = getexamples(this)
  vso = validspecobj(this)
end  % public methods 

end  % classdef

