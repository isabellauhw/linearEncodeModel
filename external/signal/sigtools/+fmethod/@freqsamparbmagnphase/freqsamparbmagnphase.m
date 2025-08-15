classdef freqsamparbmagnphase < fmethod.abstractfreqsamparbmag
%FREQSAMPARBMAGNPHASE   Construct a FREQSAMPARBMAGNPHASE object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.freqsamparbmagnphase class
%   fmethod.freqsamparbmagnphase extends fmethod.abstractfreqsamparbmag.
%
%    fmethod.freqsamparbmagnphase properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.freqsamparbmagnphase methods:
%       getexamples -   Get the examples.
%       validspecobj -   Return the name of the valid specification object.



methods  % constructor block
  function this = freqsamparbmagnphase

  % this = fmethod.freqsamparbmagnphase;

  this.DesignAlgorithm = 'Frequency sampling';


  end  % freqsamparbmagnphase

end  % constructor block

methods  % public methods
  examples = getexamples(this)
  vso = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help(this)
end  % possibly private or hidden 

end  % classdef

