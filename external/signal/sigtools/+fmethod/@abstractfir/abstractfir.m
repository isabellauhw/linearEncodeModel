classdef (Abstract) abstractfir < fmethod.abstractdesign
%ABSTRACTFIR Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstractfir class
%   fmethod.abstractfir extends fmethod.abstractdesign.
%
%    fmethod.abstractfir properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.abstractfir methods:
%       get_structure -   PreGet function for the 'structure' property.
%       getvalidstructs -   Get the validstructs.
%       isconstrained -   True if the object is constrained.
%       iskaisereqripminspecmet - Test that the spec is met in Kaiser and
%       searchmincoeffwl - Search for min. coeff wordlength.
%       searchmincoeffwlmin - SEARCHMINCOEFFWL Search for min. coeff wordlength.
%       searchmincoeffwlword - Find min coeff word length filter when order
%       searchmincoeffwlwordhb - SEARCHMINCOEFFWLWORD Find min coeff word length filter when order



methods  % public methods
  structure = get_structure(this,structure)
  validstructs = getvalidstructs(this)
  b = isconstrained(this)
  status = iskaisereqripminspecmet(this,hfilter,hspecs)
  Hbest = searchmincoeffwl(this,args,varargin)
  Hbest = searchmincoeffwlmin(this,args,varargin)
  Hbest = searchmincoeffwlword(this,args,minordspec,designargs,varargin)
  Hbest = searchmincoeffwlwordhb(this,args,minordspec,designargs,varargin)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help_window(this)
end  % possibly private or hidden 

end  % classdef

