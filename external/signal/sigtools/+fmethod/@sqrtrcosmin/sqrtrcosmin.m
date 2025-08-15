classdef sqrtrcosmin < fmethod.abstractrcosmin
%SQRTRCOSMIN  Construct a SQRTRCOSMIN object

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.sqrtrcosmin class
%   fmethod.sqrtrcosmin extends fmethod.abstractrcosmin.
%
%    fmethod.sqrtrcosmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.sqrtrcosmin methods:
%       actualdesign - Design the filter
%       getexamples -   Get the examples.
%       validspecobj - Return the name of the valid specification object



methods  % constructor block
  function this = sqrtrcosmin

  % this = fmethod.sqrtrcosmin;

  this.DesignAlgorithm = 'Window';


  end  % sqrtrcosmin

end  % constructor block

methods  % public methods
  b = actualdesign(this,hspecs,varargin)
  examples = getexamples(this)
  vso = validspecobj(this)
end  % public methods 

end  % classdef

