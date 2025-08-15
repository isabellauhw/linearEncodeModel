classdef freqsamparbmag < fmethod.abstractfreqsamparbmag
%FREQSAMPARBMAG   Construct a FREQSAMPARBMAG object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.freqsamparbmag class
%   fmethod.freqsamparbmag extends fmethod.abstractfreqsamparbmag.
%
%    fmethod.freqsamparbmag properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Window - Property is of type 'mxArray'  
%
%    fmethod.freqsamparbmag methods:
%       getexamples -   Get the examples.
%       validspecobj -   Return the name of the valid specification object.


properties (AbortSet, SetObservable, GetObservable)
  %WINDOW Property is of type 'mxArray' 
  Window = [];
end


methods  % constructor block
  function this = freqsamparbmag

  % this = fmethod.freqsamparbmag;
  this.DesignAlgorithm = 'Frequency sampling';


  end  % freqsamparbmag

end  % constructor block

methods 
  function set.Window(obj,value)
  validateattributes(value,{'char','function_handle','cell','double'}, {'vector'},'','Window')  
  obj.Window = value;
  end
end   % set and get functions 

methods  % public methods
  examples = getexamples(this)
  vso = validspecobj(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  b = applywindow(this,b,N)
  help(this)
end  % possibly private or hidden 

end  % classdef

