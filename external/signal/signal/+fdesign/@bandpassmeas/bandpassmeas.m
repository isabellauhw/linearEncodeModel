classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) bandpassmeas < fdesign.abstractmeas
%BANDPASSMEAS Construct a BANDPASSMEAS object.

%   Copyright 2004-2015 The MathWorks, Inc.    
  
%fdesign.bandpassmeas class
%   fdesign.bandpassmeas extends fdesign.abstractmeas.
%
%    fdesign.bandpassmeas properties:
%       NormalizedFrequency - Property is of type 'bool' (read only) 
%       Fs - Property is of type 'mxArray' (read only) 
%       Fstop1 - Property is of type 'mxArray' (read only) 
%       F6dB1 - Property is of type 'mxArray' (read only) 
%       F3dB1 - Property is of type 'mxArray' (read only) 
%       Fpass1 - Property is of type 'mxArray' (read only) 
%       Fpass2 - Property is of type 'mxArray' (read only) 
%       F3dB2 - Property is of type 'mxArray' (read only) 
%       F6dB2 - Property is of type 'mxArray' (read only) 
%       Fstop2 - Property is of type 'mxArray' (read only) 
%       Astop1 - Property is of type 'mxArray' (read only) 
%       Apass - Property is of type 'mxArray' (read only) 
%       Astop2 - Property is of type 'mxArray' (read only) 
%       TransitionWidth1 - Property is of type 'mxArray' (read only) 
%       TransitionWidth2 - Property is of type 'mxArray' (read only) 
%
%    fdesign.bandpassmeas methods:
%       getprops2norm -   Get the props2norm.
%       isspecmet -   True if the object is specmet.
%       setprops2norm -   Set the props2norm.


properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
  %FSTOP1 Property is of type 'mxArray' (read only)
  Fstop1 = [];
  %F6DB1 Property is of type 'mxArray' (read only)
  F6dB1 = [];
  %F3DB1 Property is of type 'mxArray' (read only)
  F3dB1 = [];
  %FPASS1 Property is of type 'mxArray' (read only)
  Fpass1 = [];
  %FPASS2 Property is of type 'mxArray' (read only)
  Fpass2 = [];
  %F3DB2 Property is of type 'mxArray' (read only)
  F3dB2 = [];
  %F6DB2 Property is of type 'mxArray' (read only)
  F6dB2 = [];
  %FSTOP2 Property is of type 'mxArray' (read only)
  Fstop2 = [];
  %ASTOP1 Property is of type 'mxArray' (read only)
  Astop1 = [];
  %APASS Property is of type 'mxArray' (read only)
  Apass = [];
  %ASTOP2 Property is of type 'mxArray' (read only)
  Astop2 = [];
  %TRANSITIONWIDTH1 Property is of type 'mxArray' (read only)
  TransitionWidth1 = [];
  %TRANSITIONWIDTH2 Property is of type 'mxArray' (read only)
  TransitionWidth2 = [];
end


methods  % constructor block
  function this = bandpassmeas(hfilter, varargin)
    %BANDPASSMEAS   Construct a BANDPASSMEAS object.

    narginchk(1,inf);

    % Create the "empty" object.
    % this = fdesign.bandpassmeas;

    % Parse the inputs to get the specification and the measurements list.
    minfo = parseconstructorinputs(this, hfilter, varargin{:});

    if this.NormalizedFrequency, Fs = 2;
    else Fs = this.Fs; end

    % Measure the bandpass filter remarkable frequencies.
    this.Fstop1 = findfstop(this, reffilter(hfilter), minfo.Fstop1, minfo.Astop1, 'up', ...
        [0 minfo.Fpass1 minfo.Fcutoff1]);
    this.F6dB1  = findfrequency(this, hfilter, 1/2, 'up', 'first');
    this.F3dB1  = findfrequency(this, hfilter, 1/sqrt(2), 'up', 'first');
    this.Fpass1 = findfpass(this, reffilter(hfilter), minfo.Fpass1, minfo.Apass, 'up');
    this.Fpass2 = findfpass(this, reffilter(hfilter), minfo.Fpass2, minfo.Apass, 'down');
    this.F3dB2  = findfrequency(this, hfilter, 1/sqrt(2), 'down', 'last');
    this.F6dB2  = findfrequency(this, hfilter, 1/2, 'down', 'last');
    this.Fstop2 = findfstop(this, reffilter(hfilter), minfo.Fstop2, minfo.Astop2, 'down', ...
        [max([minfo.Fpass2, minfo.Fcutoff2]) Fs/2]);

    % Use the measured Fpass1, Fpass2, Fstop1 and Fstop2 when they are not
    % specified to have a true measure of Apass, Astop1 and Astop2. See
    % G425069.
    if isempty(minfo.Fpass1), minfo.Fpass1 = this.Fpass1; end 
    if isempty(minfo.Fpass2), minfo.Fpass2 = this.Fpass2; end 
    if isempty(minfo.Fstop1), minfo.Fstop1 = this.Fstop1; end
    if isempty(minfo.Fstop2), minfo.Fstop2 = this.Fstop2; end

    % Measure ripples and attenuations.
    this.Astop1 = measureattenuation(this, hfilter, 0, minfo.Fstop1, minfo.Astop1);
    this.Apass  = measureripple(this, hfilter, minfo.Fpass1, minfo.Fpass2, minfo.Apass);
    this.Astop2 = measureattenuation(this, hfilter, minfo.Fstop2, Fs/2, minfo.Astop2);


  end  % bandpassmeas

end  % constructor block

methods 
  function set.Fstop1(obj,value)
  obj.Fstop1 = value;
  end
  %------------------------------------------------------------------------
  function set.F6dB1(obj,value)
  obj.F6dB1 = value;
  end
  %------------------------------------------------------------------------
  function set.F3dB1(obj,value)
  obj.F3dB1 = value;
  end
  %------------------------------------------------------------------------
  function set.Fpass1(obj,value)
  obj.Fpass1 = value;
  end
  %------------------------------------------------------------------------
  function set.Fpass2(obj,value)
  obj.Fpass2 = value;
  end
  %------------------------------------------------------------------------
  function set.F3dB2(obj,value)
  obj.F3dB2 = value;
  end
  %------------------------------------------------------------------------
  function set.F6dB2(obj,value)
  obj.F6dB2 = value;
  end
  %------------------------------------------------------------------------
  function set.Fstop2(obj,value)
  obj.Fstop2 = value;
  end
  %------------------------------------------------------------------------
  function set.Astop1(obj,value)
  obj.Astop1 = value;
  end
  %------------------------------------------------------------------------
  function set.Apass(obj,value)
  obj.Apass = value;
  end
  %------------------------------------------------------------------------
  function set.Astop2(obj,value)
  obj.Astop2 = value;
  end
  %------------------------------------------------------------------------
  function value = get.TransitionWidth1(obj)
  value = get_transitionwidth1(obj,obj.TransitionWidth1);
  end
  function set.TransitionWidth1(obj,value)
  obj.TransitionWidth1 = value;
  end
  %------------------------------------------------------------------------
  function value = get.TransitionWidth2(obj)
  value = get_transitionwidth2(obj,obj.TransitionWidth2);
  end
  %------------------------------------------------------------------------
  function set.TransitionWidth2(obj,value)
  obj.TransitionWidth2 = value;
  end

end   % set and get functions 

methods  % public methods
  props2norm = getprops2norm(this)
  b = isspecmet(this,hfdesign)
  setprops2norm(this,props2norm)
end  % public methods 

end  % classdef

function tw = get_transitionwidth1(this, ~)

tw = get(this, 'Fpass1') - get(this, 'Fstop1');
end  % get_transitionwidth1


% -------------------------------------------------------------------------
function tw = get_transitionwidth2(this, ~)

tw = get(this, 'Fstop2') - get(this, 'Fpass2');
end  % get_transitionwidth2


% [EOF]
