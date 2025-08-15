classdef kaiserbsmin < fmethod.abstractkaisermin
%KAISERBSMIN   Construct a KAISERBSMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.kaiserbsmin class
%   fmethod.kaiserbsmin extends fmethod.abstractkaisermin.
%
%    fmethod.kaiserbsmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Window - Property is of type 'mxArray'  
%       ScalePassband - Property is of type 'bool'  
%
%    fmethod.kaiserbsmin methods:
%       designargs -   Return a cell of inputs to pass to FIR1.
%       getexamples -   Get the examples.
%       getvalidstructs -   Get the validstructs.
%       updateoddorder - If order is odd, and gain is not zero at nyquist, increase



methods  % constructor block
  function this = kaiserbsmin

  % this = fmethod.kaiserbsmin;

  this.DesignAlgorithm = 'Kaiser Window';


  end  % kaiserbsmin

end  % constructor block

methods  % public methods
  args = designargs(this,hs)
  examples = getexamples(this)
  validstructs = getvalidstructs(this)
  N = updateoddorder(this,N)
end  % public methods 


methods (Hidden) % possibly private or hidden
  [stopbands,passbands,Astop,Apass] = getfbandstomeas(this,hspecs)
  help(this)
  s = thisdesignopts(this,s)
  vso = validspecobj(this)
end  % possibly private or hidden 

end  % classdef

