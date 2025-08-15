classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) lowpassmeas < fdesign.abstractmeas
%LOWPASSMEAS Construct a LOWPASSMEAS object.

%   Copyright 2004-2015 The MathWorks, Inc.
  
%fdesign.lowpassmeas class
%   fdesign.lowpassmeas extends fdesign.abstractmeas.
%
%    fdesign.lowpassmeas properties:
%       NormalizedFrequency - Property is of type 'bool' (read only) 
%       Fs - Property is of type 'mxArray' (read only) 
%       Fpass - Property is of type 'mxArray' (read only) 
%       F3dB - Property is of type 'mxArray' (read only) 
%       F6dB - Property is of type 'mxArray' (read only) 
%       Fstop - Property is of type 'mxArray' (read only) 
%       Apass - Property is of type 'mxArray' (read only) 
%       Astop - Property is of type 'mxArray' (read only) 
%       TransitionWidth - Property is of type 'mxArray' (read only) 
%
%    fdesign.lowpassmeas methods:
%       getprops2norm -   Get the props2norm.
%       isspecmet -   True if the object is specmet.
%       setprops2norm -   Set the props2norm.


properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
  %FPASS Property is of type 'mxArray' (read only)
  Fpass = [];
  %F3DB Property is of type 'mxArray' (read only)
  F3dB = [];
  %F6DB Property is of type 'mxArray' (read only)
  F6dB = [];
  %FSTOP Property is of type 'mxArray' (read only)
  Fstop = [];
  %APASS Property is of type 'mxArray' (read only)
  Apass = [];
  %ASTOP Property is of type 'mxArray' (read only)
  Astop = [];
  %TRANSITIONWIDTH Property is of type 'mxArray' (read only)
  TransitionWidth = [];
end


methods  % constructor block
  function this = lowpassmeas(hfilter, varargin)
    %LOWPASSMEAS   Construct a LOWPASSMEAS object.

    narginchk(1,inf);

    % Construct an "empty" object.
    % this = fdesign.lowpassmeas;

    % Parse the inputs.
    minfo = parseconstructorinputs(this, hfilter, varargin{:});

    if this.NormalizedFrequency
      Fs = 2;
    else
      Fs = this.Fs; 
    end

    % Measure the lowpass filter remarkable frequencies.
    this.Fpass = findfpass(this, reffilter(hfilter), minfo.Fpass, minfo.Apass, 'down');
    this.F3dB  = findfrequency(this, hfilter, 1/sqrt(2), 'down', 'first');
    this.F6dB  = findfrequency(this, hfilter, 1/2, 'down', 'first');
    this.Fstop = findfstop(this, reffilter(hfilter), minfo.Fstop, minfo.Astop, 'down');

    % Use the measured Fpass and Fstop when they are not specified to have a
    % true measure of Apass and Astop. See G425069.
    if isempty(minfo.Fpass), minfo.Fpass = this.Fpass; end 
    if isempty(minfo.Fstop), minfo.Fstop = this.Fstop; end

    % Measure ripples and attenuation.
    this.Apass = measureripple(this, hfilter, 0, minfo.Fpass, minfo.Apass);
    this.Astop = measureattenuation(this, hfilter, minfo.Fstop, Fs/2, minfo.Astop);


  end  % lowpassmeas

end  % constructor block

methods 
  function set.Fpass(obj,value)
    obj.Fpass = value;
  end
  %------------------------------------------------------------------------
  function set.F3dB(obj,value)
    obj.F3dB = value;
  end
  %------------------------------------------------------------------------
  function set.F6dB(obj,value)
    obj.F6dB = value;
  end
  %------------------------------------------------------------------------
  function set.Fstop(obj,value)
    obj.Fstop = value;
  end
  %------------------------------------------------------------------------
  function set.Apass(obj,value)
    obj.Apass = value;
  end
  %------------------------------------------------------------------------
  function set.Astop(obj,value)
    obj.Astop = value;
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

function tw = get_transitionwidth(this,~)
  tw = get(this,'Fstop') - get(this,'Fpass');
end  % get_transitionwidth


% [EOF]
