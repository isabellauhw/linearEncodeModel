classdef (Abstract) abstractwindow < fmethod.abstractfir
%ABSTRACTWINDOW   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstractwindow class
%   fmethod.abstractwindow extends fmethod.abstractfir.
%
%    fmethod.abstractwindow properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       Window - Property is of type 'mxArray'  
%       ScalePassband - Property is of type 'bool'  
%
%    fmethod.abstractwindow methods:
%       actualdesign -   Design the lowpass kaiser window.
%       calculatewin -   Calculate the window.
%       getdesignpanelstate -   Get the designpanelstate.
%       getscalingflag -   Get the scalingflag.


properties (AbortSet, SetObservable, GetObservable)
  %WINDOW Property is of type 'mxArray' 
  Window = 'hamming';
  %SCALEPASSBAND Property is of type 'bool' 
  ScalePassband = true;
end


methods 
  function set.Window(obj,value)
  validateattributes(value,{'char','function_handle','cell','double'}, {}, '','Window')  
  obj.Window = value;
  end
  %------------------------------------------------------------------------
  function set.ScalePassband(obj,value)
  validateattributes(value,{'logical','numeric'}, {'scalar','nonnan'},'','ScalePassband')
  value = logical(value);
  obj.ScalePassband = value;
  end

end   % set and get functions 

methods  % public methods
  b = actualdesign(this,hspecs,varargin)
  win = calculatewin(this,N,win)
  s = getdesignpanelstate(this)
  flag = getscalingflag(this)
end  % public methods 


methods (Hidden) % possibly private or hidden
  help_kaiser(this)
  help_scalepassband(this)
  help_window(this)
  help_windowprop(this)
end  % possibly private or hidden 

end  % classdef

