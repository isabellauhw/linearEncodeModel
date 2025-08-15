classdef kaiserhpmin < fmethod.abstractkaisermin
%KAISERHPMIN   Construct a KAISERHPMIN object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.kaiserhpmin class
%   fmethod.kaiserhpmin extends fmethod.abstractkaisermin.
%
%    fmethod.kaiserhpmin properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Window - Property is of type 'mxArray'  
%       ScalePassband - Property is of type 'bool'  
%
%    fmethod.kaiserhpmin methods:
%       designargs -   Return a cell of inputs to pass to FIR1.
%       getexamples -   Get the examples.
%       updateoddorder - If order is odd, and gain is not zero at nyquist, increase



methods  % constructor block
  function this = kaiserhpmin

  % this = fmethod.kaiserhpmin;

  this.DesignAlgorithm = 'Kaiser Window';


  end  % kaiserhpmin

end  % constructor block

methods  % public methods
  args = designargs(this,hspecs)
  examples = getexamples(this)
  N = updateoddorder(this,N)
end  % public methods 


methods (Hidden) % possibly private or hidden
  [stopbands,passbands,Astop,Apass] = getfbandstomeas(this,hspecs)
  help(this)
  s = thisdesignopts(this,s)
  vso = validspecobj(this)
end  % possibly private or hidden 

end  % classdef

