classdef kaiserlpmin < fmethod.abstractkaisermin
%KAISERLPMIN   Construct a KAISERLPMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.kaiserlpmin class
%   fmethod.kaiserlpmin extends fmethod.abstractkaisermin.
%
%    fmethod.kaiserlpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Window - Property is of type 'mxArray'  
%       ScalePassband - Property is of type 'bool'  
%
%    fmethod.kaiserlpmin methods:
%       designargs -   Return a cell of inputs to pass to FIR1.
%       getexamples -   Get the examples.
%       getvalidstructs -   Get the validstructs.
%       iscoeffwloptimizable - True if the object is coeffwloptimizable



methods  % constructor block
  function this = kaiserlpmin

  % this = fmethod.kaiserlpmin;

  this.DesignAlgorithm = 'Kaiser Window';


  end  % kaiserlpmin

end  % constructor block

methods  % public methods
  args = designargs(this,hspecs)
  examples = getexamples(this)
  validstructs = getvalidstructs(this)
  b = iscoeffwloptimizable(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  [stopbands,passbands,Astop,Apass] = getfbandstomeas(this,hspecs)
  help(this)
  s = thisdesignopts(this,s)
  vso = validspecobj(this)
end  % possibly private or hidden 

end  % classdef

