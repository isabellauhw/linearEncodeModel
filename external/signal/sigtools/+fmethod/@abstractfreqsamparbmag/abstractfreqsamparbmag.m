classdef (Abstract) abstractfreqsamparbmag < fmethod.abstractfir
%fmethod.abstractfreqsamparbmag class
%   fmethod.abstractfreqsamparbmag extends fmethod.abstractfir.
%
%    fmethod.abstractfreqsamparbmag properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%
%    fmethod.abstractfreqsamparbmag methods:
%       actualdesign -   Perform the actual design.



methods  % public methods
  varargout = actualdesign(this,hspecs,varargin)
end  % public methods 


methods (Hidden) % possibly private or hidden
  b = applywindow(this,b,N)
end  % possibly private or hidden 

end  % classdef

