classdef rcosmin < fmethod.abstractrcosmin
%RCOSMIN  Construct a RCOSMIN object

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.rcosmin class
%   fmethod.rcosmin extends fmethod.abstractrcosmin.
%
%    fmethod.rcosmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.rcosmin methods:
%       actualdesign - Design the filter
%       getexamples -   Get the examples.
%       validspecobj - Return the name of the valid specification object



methods  % constructor block
  function this = rcosmin

  % this = fmethod.rcosmin;

  this.DesignAlgorithm = 'Window';


  end  % rcosmin

end  % constructor block

methods  % public methods
  b = actualdesign(this,hspecs,varargin)
  examples = getexamples(this)
  vso = validspecobj(this)
end  % public methods 

end  % classdef

