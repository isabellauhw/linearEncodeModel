classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) hilbertmeas < fdesign.abstractmeas
%HILBERTMEAS Construct a HILBERTMEAS object.

%   Copyright 2004-2015 The MathWorks, Inc.  
  
%fdesign.hilbertmeas class
%   fdesign.hilbertmeas extends fdesign.abstractmeas.
%
%    fdesign.hilbertmeas properties:
%       NormalizedFrequency - Property is of type 'bool' (read only) 
%       Fs - Property is of type 'mxArray' (read only) 
%       TransitionWidth - Property is of type 'mxArray' (read only) 
%       Apass - Property is of type 'mxArray' (read only) 
%
%    fdesign.hilbertmeas methods:
%       getprops2norm -   Get the props2norm.
%       isspecmet -   True if the object is specmet.
%       setprops2norm -   Set the props2norm.


properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
  %TRANSITIONWIDTH Property is of type 'mxArray' (read only)
  TransitionWidth = [];
  %APASS Property is of type 'mxArray' (read only)
  Apass = [];
end


methods  % constructor block
  function this = hilbertmeas(hfilter, varargin)
    %HILBERTMEAS   Construct a HILBERTMEAS object.

    narginchk(1,inf);

    % this = fdesign.hilbertmeas;

    minfo = parseconstructorinputs(this, hfilter, varargin{:});

    this.TransitionWidth = minfo.TransitionWidth;

    % Apass represents the passband ripple!
    if this.NormalizedFrequency, Fs = 2;
    else Fs = this.Fs; end

    wpass1 = this.TransitionWidth/2;
    wpass2 = Fs/2-this.TransitionWidth/2;

    this.Apass = measureripple(this, hfilter, wpass1, wpass2, minfo.Apass);


  end  % hilbertmeas

end  % constructor block

methods 
  function set.TransitionWidth(obj,value)
  obj.TransitionWidth = value;
  end
  %------------------------------------------------------------------------
  function set.Apass(obj,value)
  obj.Apass = value;
  end

end   % set and get functions 

methods  % public methods
  props2norm = getprops2norm(this)
  b = isspecmet(this,hfdesign)
  setprops2norm(this,props2norm)
end  % public methods 

end  % classdef

