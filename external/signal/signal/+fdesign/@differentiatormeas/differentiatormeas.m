classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) differentiatormeas < fdesign.abstractmeas
%DIFFERENTIATORMEAS Construct a DIFFERENTIATORMEAS object.

%   Copyright 2004-2017 The MathWorks, Inc.
  
%fdesign.differentiatormeas class
%   fdesign.differentiatormeas extends fdesign.abstractmeas.
%
%    fdesign.differentiatormeas properties:
%       NormalizedFrequency - Property is of type 'bool' (read only) 
%       Fs - Property is of type 'mxArray' (read only) 
%       Fpass - Property is of type 'mxArray' (read only) 
%       Fstop - Property is of type 'mxArray' (read only) 
%       Apass - Property is of type 'mxArray' (read only) 
%       Astop - Property is of type 'mxArray' (read only) 
%       TransitionWidth - Property is of type 'mxArray' (read only) 
%
%    fdesign.differentiatormeas methods:
%       getprops2norm -   Get the props2norm.
%       isspecmet -   True if the object is specmet.
%       setprops2norm -   Set the props2norm.


properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
  %FPASS Property is of type 'mxArray' (read only)
  Fpass = [];
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
  function this = differentiatormeas(hfilter, varargin)
    %DIFFERENTIATORMEAS   Construct a DIFFERENTIATORMEAS object.

    narginchk(1,inf);

    % this = fdesign.differentiatormeas;

    minfo = parseconstructorinputs(this, hfilter, varargin{:});

    this.Fpass = get_diff_fpass(hfilter, minfo.Fpass, minfo.Apass);
    this.Fstop = get_diff_fstop(hfilter, this.Fpass, minfo.Fstop, minfo.Astop);

    % Apass represents the passband ripple.
    this.Apass = get_diff_apass(hfilter, minfo.Fpass, minfo.Apass,this.Fs);

    % Astop represents stopband attenuation.
    this.Astop = get_diff_astop(hfilter, minfo.Fpass, minfo.Fstop, minfo.Astop,this.Fs);
  end  % differentiatormeas
    %----------------------------------------------------------------------

end  % constructor block

methods 
  function set.Fpass(obj,value)
  obj.Fpass = value;
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
  b = isspecmet(this,hfdesign)
  setprops2norm(this,props2norm)
end  % public methods 

end  % classdef

function tw = get_transitionwidth(this, tw)

tw = get(this, 'Fstop') - get(this, 'Fpass');
end  % get_transitionwidth


% [EOF]
function measured_fpass = get_diff_fpass (hd, fpass, apass)

measured_fpass = [];

% return fpass if it is specified
if (~isempty(fpass))
    measured_fpass = fpass;
% These two cases are to support type IV Differentiators in which case we
% know the Fpass
elseif (~isempty(apass))
    measured_fpass = 1;
elseif ((isempty(apass) && isempty(fpass)))
    measured_fpass = 1;
end
end  % get_diff_fpass



%--------------------------------------------------------------------------
function measured_fstop = get_diff_fstop (hd, fpass, fstop, astop)

measured_fstop = [];

% Return fstop if it is specified; Will never be in a situation that Astop
% was specified when Fstop was not.
if (~isempty(fstop))
    measured_fstop = fstop;
end
end  % get_diff_fstop



%--------------------------------------------------------------------------
function measured_apass = get_diff_apass (hd, fpass, apass, Fs)

if isempty(fpass)
    fpass = 1;
elseif isnumeric(Fs)
    fpass = fpass/Fs*2;
end

measured_apass = [];
wpass = fpass*pi;

N = 4096;

% Find theoretical Apass
r = hd.getratechangefactors;
htheo = r(1)*linspace(0,wpass,N);

% For a differentiator, the max Apass will be a wpass
hact = freqz(hd, linspace(0, wpass, N));

measured_apass = max(db(htheo(2:end))-db(hact(2:end)))-min(db(htheo(2:end))-db(hact(2:end)));
end  % get_diff_apass


%--------------------------------------------------------------------------
function measured_astop = get_diff_astop (hd, fpass, fstop, astop, Fs)

measured_astop = [];
if isnumeric(Fs)
    fpass = fpass/Fs*2;
    fstop = fstop/Fs*2;
end
wstop = fstop*pi;
wpass = fpass*pi;

% Not all fspecs have a FilterOrder property, we need to determine this so
% that we only compute Astop for type III (even order) filters
ord = order(hd);
isTypeIII = false;
if ~rem(ord,2)
    isTypeIII = true;
end

% Calculate astop if fstop and if type III only (since type IV doesn't have
% a stopband)
if (~isempty(fstop) && isTypeIII)
    % Calculate astop over stopband
    h_maxpass = find_max(hd, 0, wpass);
    h_maxstop = find_max(hd, wstop, pi);
    measured_astop = db(h_maxpass) - db(h_maxstop);

    % else return specified astop if available
elseif (~isempty(astop))
    measured_astop = astop;
end
end  % get_diff_astop



%--------------------------------------------------------------------------
function y = find_max (hd, lo, hi)

N = 1024;
w_lo = lo;
w_hi = hi;

% calculate max of response from w_lo to w_hi
if (w_lo == 0) && (w_hi == pi)
    [h,w] = freqz(hd, N);
    
else
    [h,w] = freqz(hd, linspace(w_lo, w_hi, N));
end

[y,idx] = max(abs(h));
if ((idx == 1) || (idx == N))
    return;

else
    w_lo = w(max(1, idx-1));
    w_hi = w(min(N, idx+1));
end

% repeat for finer resolution
h = freqz(hd, linspace(w_lo, w_hi, N));
y = max(abs(h));
end  % find_max


