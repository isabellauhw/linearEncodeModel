classdef kaiserbpmin < fmethod.abstractkaisermin
%KAISERBPMIN   Construct a KAISERBPMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.kaiserbpmin class
%   fmethod.kaiserbpmin extends fmethod.abstractkaisermin.
%
%    fmethod.kaiserbpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Window - Property is of type 'mxArray'  
%       ScalePassband - Property is of type 'bool'  
%
%    fmethod.kaiserbpmin methods:
%       designargs -   Return a cell of inputs to pass to FIR1.
%       getexamples -   Get the examples.
%       getvalidstructs -   Get the validstructs.



methods  % constructor block
  function this = kaiserbpmin

  % this = fmethod.kaiserbpmin;

  this.DesignAlgorithm = 'Kaiser Window';


  end  % kaiserbpmin

end  % constructor block

methods  % public methods
  args = designargs(this,hs)
  examples = getexamples(this)
  validstructs = getvalidstructs(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  [stopbands,passbands,Astop,Apass] = getfbandstomeas(this,hspecs)
  help(this)
  s = thisdesignopts(this,s)
  vso = validspecobj(this)
end  % possibly private or hidden 

end  % classdef

