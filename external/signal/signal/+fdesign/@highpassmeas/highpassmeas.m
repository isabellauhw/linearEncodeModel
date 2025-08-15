classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) highpassmeas < fdesign.abstractmeas
%HIGHPASSMEAS Construct a HIGHPASSMEAS object.

%   Copyright 2004-2015 The MathWorks, Inc.  
  
%fdesign.highpassmeas class
%   fdesign.highpassmeas extends fdesign.abstractmeas.
%
%    fdesign.highpassmeas properties:
%       NormalizedFrequency - Property is of type 'bool' (read only) 
%       Fs - Property is of type 'mxArray' (read only) 
%       Fstop - Property is of type 'mxArray' (read only) 
%       F6dB - Property is of type 'mxArray' (read only) 
%       F3dB - Property is of type 'mxArray' (read only) 
%       Fpass - Property is of type 'mxArray' (read only) 
%       Astop - Property is of type 'mxArray' (read only) 
%       Apass - Property is of type 'mxArray' (read only) 
%       TransitionWidth - Property is of type 'mxArray' (read only) 
%
%    fdesign.highpassmeas methods:
%       getprops2norm -   Get the props2norm.
%       isspecmet -   True if the object is specmet.
%       setprops2norm -   Set the props2norm.


properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
  %FSTOP Property is of type 'mxArray' (read only)
  Fstop = [];
  %F6DB Property is of type 'mxArray' (read only)
  F6dB = [];
  %F3DB Property is of type 'mxArray' (read only)
  F3dB = [];
  %FPASS Property is of type 'mxArray' (read only)
  Fpass = [];
  %ASTOP Property is of type 'mxArray' (read only)
  Astop = [];
  %APASS Property is of type 'mxArray' (read only)
  Apass = [];
  %TRANSITIONWIDTH Property is of type 'mxArray' (read only)
  TransitionWidth = [];
end


methods  % constructor block
  function this = highpassmeas(hfilter, varargin)
  %HIGHPASSMEAS   Construct a HIGHPASSMEAS object.

  narginchk(1,inf);

  % Construct and "empty" object.
  % this = fdesign.highpassmeas;

  % Parse the inputs.
  minfo = parseconstructorinputs(this, hfilter, varargin{:});

  if this.NormalizedFrequency, Fs = 2;
  else Fs = this.Fs; end

  % Measure the highpass filter remarkable frequencies.
  this.Fstop = findfstop(this, reffilter(hfilter), minfo.Fstop, minfo.Astop, 'up');
  this.F6dB  = findfrequency(this, hfilter, 1/2, 'up', 'first');
  this.F3dB  = findfrequency(this, hfilter, 1/sqrt(2), 'up', 'first');
  this.Fpass = findfpass(this, reffilter(hfilter), minfo.Fpass, minfo.Apass, 'up');

  % Use the measured Fpass and Fstop when they are not specified to have a
  % true measure of Apass and Astop. See G425069.
  if isempty(minfo.Fpass), minfo.Fpass = this.Fpass; end 
  if isempty(minfo.Fstop), minfo.Fstop = this.Fstop; end

  % Measure ripples and attenuation.
  this.Astop = measureattenuation(this, hfilter, 0, minfo.Fstop, minfo.Astop);
  this.Apass = measureripple(this, hfilter, minfo.Fpass, Fs/2, minfo.Apass);


  end  % highpassmeas
        
end  % constructor block

methods 
  function set.Fstop(obj,value)
  obj.Fstop = value;
  end
  %------------------------------------------------------------------------
  function set.F6dB(obj,value)
  obj.F6dB = value;
  end
  %------------------------------------------------------------------------
  function set.F3dB(obj,value)
  obj.F3dB = value;
  end
  %------------------------------------------------------------------------
  function set.Fpass(obj,value)
  obj.Fpass = value;
  end
  %------------------------------------------------------------------------
  function set.Astop(obj,value)
  obj.Astop = value;
  end
  %------------------------------------------------------------------------
  function set.Apass(obj,value)
  obj.Apass = value;
  end
  %------------------------------------------------------------------------
  function value = get.TransitionWidth(obj)
  value = get_transitionwidth(obj,obj.TransitionWidth);
  end
  %------------------------------------------------------------------------
  function set.TransitionWidth(obj,value)
  obj.TransitionWidth = value;
  end

    end   % set and get functions 

methods  % public methods
    props2norm = getprops2norm(this)
    b = isspecmet(this,hfdesign,args)
    setprops2norm(this,props2norm)
end  % public methods 

end  % classdef

function tw = get_transitionwidth(this, ~)

tw = get(this, 'Fpass') - get(this, 'Fstop');
end  % get_transitionwidth


% [EOF]
