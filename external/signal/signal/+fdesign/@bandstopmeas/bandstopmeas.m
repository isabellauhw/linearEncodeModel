classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) bandstopmeas < fdesign.abstractmeas
%BANDSTOPMEAS Construct a BANDSTOPMEAS object.

%   Copyright 2004-2015 The MathWorks, Inc.    
  
%fdesign.bandstopmeas class
%   fdesign.bandstopmeas extends fdesign.abstractmeas.
%
%    fdesign.bandstopmeas properties:
%       NormalizedFrequency - Property is of type 'bool' (read only) 
%       Fs - Property is of type 'mxArray' (read only) 
%       Fpass1 - Property is of type 'mxArray' (read only) 
%       F3dB1 - Property is of type 'mxArray' (read only) 
%       F6dB1 - Property is of type 'mxArray' (read only) 
%       Fstop1 - Property is of type 'mxArray' (read only) 
%       Fstop2 - Property is of type 'mxArray' (read only) 
%       F6dB2 - Property is of type 'mxArray' (read only) 
%       F3dB2 - Property is of type 'mxArray' (read only) 
%       Fpass2 - Property is of type 'mxArray' (read only) 
%       Apass1 - Property is of type 'mxArray' (read only) 
%       Astop - Property is of type 'mxArray' (read only) 
%       Apass2 - Property is of type 'mxArray' (read only) 
%       TransitionWidth1 - Property is of type 'mxArray' (read only) 
%       TransitionWidth2 - Property is of type 'mxArray' (read only) 
%
%    fdesign.bandstopmeas methods:
%       getprops2norm -   Get the props2norm.
%       isspecmet -   True if the object is specmet.
%       setprops2norm -   Set the props2norm.


properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
  %FPASS1 Property is of type 'mxArray' (read only)
  Fpass1 = [];
  %F3DB1 Property is of type 'mxArray' (read only)
  F3dB1 = [];
  %F6DB1 Property is of type 'mxArray' (read only)
  F6dB1 = [];
  %FSTOP1 Property is of type 'mxArray' (read only)
  Fstop1 = [];
  %FSTOP2 Property is of type 'mxArray' (read only)
  Fstop2 = [];
  %F6DB2 Property is of type 'mxArray' (read only)
  F6dB2 = [];
  %F3DB2 Property is of type 'mxArray' (read only)
  F3dB2 = [];
  %FPASS2 Property is of type 'mxArray' (read only)
  Fpass2 = [];
  %APASS1 Property is of type 'mxArray' (read only)
  Apass1 = [];
  %ASTOP Property is of type 'mxArray' (read only)
  Astop = [];
  %APASS2 Property is of type 'mxArray' (read only)
  Apass2 = [];
  %TRANSITIONWIDTH1 Property is of type 'mxArray' (read only)
  TransitionWidth1 = [];
  %TRANSITIONWIDTH2 Property is of type 'mxArray' (read only)
  TransitionWidth2 = [];
end


methods  % constructor block
  function this = bandstopmeas(hfilter, varargin)
    %BANDSTOPMEAS   Construct a BANDSTOPMEAS object.

    narginchk(1,inf);

    % Constructor an "empty" object.
    % this = fdesign.bandstopmeas;

    % Parse the inputs for the fdesign object.
    minfo = parseconstructorinputs(this, hfilter, varargin{:});

    if this.NormalizedFrequency, Fs = 2;
    else Fs = this.Fs; end

    % Measure the bandstop filter remarkable frequencies.
    this.Fpass1 = findfpass(this, reffilter(hfilter), minfo.Fpass1, minfo.Apass1, 'down', ...
        [0 minfo.Fcutoff1 minfo.Fstop1]);
    this.F3dB1  = findfrequency(this, hfilter, 1/sqrt(2), 'down', 'first');
    this.F6dB1  = findfrequency(this, hfilter, 1/2, 'down', 'first');
    this.Fstop1 = findfstop(this, reffilter(hfilter), minfo.Fstop1, minfo.Astop, 'down');
    this.Fstop2 = findfstop(this, reffilter(hfilter), minfo.Fstop2, minfo.Astop, 'up');
    this.F6dB2  = findfrequency(this, hfilter, 1/2, 'up', 'last');
    this.F3dB2  = findfrequency(this, hfilter, 1/sqrt(2), 'up', 'last');
    this.Fpass2 = findfpass(this, reffilter(hfilter), minfo.Fpass2, minfo.Apass2, 'up', ...
        [max([minfo.Fstop2 minfo.Fcutoff2]) Fs/2]);

    % Use the measured Fpass1, Fpass2, Fstop1 and Fstop2 when they are not
    % specified to have a true measure of Apass1, Apass2 and Astop. See
    % G425069.
    if isempty(minfo.Fpass1), minfo.Fpass1 = this.Fpass1; end 
    if isempty(minfo.Fpass2), minfo.Fpass2 = this.Fpass2; end 
    if isempty(minfo.Fstop1), minfo.Fstop1 = this.Fstop1; end
    if isempty(minfo.Fstop2), minfo.Fstop2 = this.Fstop2; end

    % Measure ripples and attenuations.
    this.Apass1 = measureripple(this, hfilter, 0, minfo.Fpass1, minfo.Apass1);
    this.Astop  = measureattenuation(this, hfilter, minfo.Fstop1, minfo.Fstop2, minfo.Astop);
    this.Apass2 = measureripple(this, hfilter, minfo.Fpass2, Fs/2, minfo.Apass2);
  end  % bandstopmeas

end  % constructor block

methods 
  function set.Fpass1(obj,value)
  obj.Fpass1 = value;
  end
  %------------------------------------------------------------------------
  function set.F3dB1(obj,value)
  obj.F3dB1 = value;
  end
  %------------------------------------------------------------------------
  function set.F6dB1(obj,value)
  obj.F6dB1 = value;
  end
  %------------------------------------------------------------------------
  function set.Fstop1(obj,value)
  obj.Fstop1 = value;
  end
  %------------------------------------------------------------------------
  function set.Fstop2(obj,value)
  obj.Fstop2 = value;
  end
  %------------------------------------------------------------------------
  function set.F6dB2(obj,value)
  obj.F6dB2 = value;
  end
  %------------------------------------------------------------------------
  function set.F3dB2(obj,value)
  obj.F3dB2 = value;
  end
  %------------------------------------------------------------------------
  function set.Fpass2(obj,value)
  obj.Fpass2 = value;
  end
  %------------------------------------------------------------------------
  function set.Apass1(obj,value)
  obj.Apass1 = value;
  end
  %------------------------------------------------------------------------
  function set.Astop(obj,value)
  obj.Astop = value;
  end
  %------------------------------------------------------------------------
  function set.Apass2(obj,value)
  obj.Apass2 = value;
  end
  %------------------------------------------------------------------------
  function value = get.TransitionWidth1(obj)
  value = get_transitionwidth1(obj,obj.TransitionWidth1);
  end
  %------------------------------------------------------------------------
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

tw = get(this, 'Fstop1') - get(this, 'Fpass1');
end  % get_transitionwidth1


% -------------------------------------------------------------------------
function tw = get_transitionwidth2(this, ~)

tw = get(this, 'Fpass2') - get(this, 'Fstop2');
end  % get_transitionwidth2


% [EOF]
