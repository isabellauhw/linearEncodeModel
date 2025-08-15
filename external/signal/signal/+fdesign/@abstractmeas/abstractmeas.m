classdef (Abstract) abstractmeas < matlab.mixin.SetGet & matlab.mixin.Copyable 
%ABSTRACTMEAS Abstract constructor produces an error.

%   Copyright 2004-2015 The MathWorks, Inc.
  
%fdesign.abstractmeas class
%    fdesign.abstractmeas properties:
%       NormalizedFrequency - Property is of type 'bool' (read only) 
%       Fs - Property is of type 'mxArray' (read only) 
%
%    fdesign.abstractmeas methods:
%       disp -   Display this object.
%       findfpass -   Find the FPass value.
%       findfrequency -   Find the frequency point for the given amplitude
%       findfstop -   Find the FStop value.
%       getrange -   Get the range.
%       measureattenuation -   Return the attenuation in the stopband.
%       measureripple -   Return the ripple in the passband.
%       normalizefreq -   Normalize frequency specifications.
%       parseconstructorinputs -   Parse the constructor inputs.
%       thisfindfpass -  If both Fpass and Apass are empty we cannot find an Fpass. 


properties (Access=protected, AbortSet, SetObservable, GetObservable)
  %SPECIFICATION Property is of type 'mxArray'
  Specification = [];
end

properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
  %NORMALIZEDFREQUENCY Property is of type 'bool' (read only)
  NormalizedFrequency = true;
  %FS Property is of type 'mxArray' (read only)
  Fs = 1;
end


methods 
  function set.NormalizedFrequency(obj,value)
    % DataType = 'bool'
    obj.NormalizedFrequency = value;
  end
  %------------------------------------------------------------------------
  function value = get.Fs(obj)
    value = get_fs(obj,obj.Fs);
  end
  %------------------------------------------------------------------------
  function set.Fs(obj,value)
    obj.Fs = value;
  end
  %------------------------------------------------------------------------
  function set.Specification(obj,value)
    obj.Specification = value;
  end

end   % set and get functions 

methods  % public methods
  disp(this)
  F = findfpass(this,hfilter,Fpass,Apass,direction,Frange,idealfcn)
  F = findfrequency(this,hfilter,A,direction,place)
  F = findfstop(this,hfilter,Fstop,Astop,direction,varargin)
  Frange = getrange(this,H,w,minfo)
  atten = measureattenuation(this,hfilter,Fstart,Fend,Astop)
  rip = measureripple(this,hfilter,Fstart,Fend,Apass,idealfcn)
  normalizefreq(this,newNormFreq,Fs)
  specs = parseconstructorinputs(this,hfilter,hfdesign,varargin)
  F = thisfindfpass(this,hfilter,idealfcn)
end  % public methods 


methods (Hidden) % possibly private or hidden
  str = tostring(this)
end  % possibly private or hidden 

end  % classdef

function fs = get_fs(this, fs)

if this.NormalizedFrequency
  fs = 'normalized';
end

end  % get_fs


% [EOF]
