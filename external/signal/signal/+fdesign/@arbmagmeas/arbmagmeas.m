classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) arbmagmeas < fdesign.abstractmeas
%ARBMAGMEAS Construct an ARBMAGMEAS object.  
  
%   Copyright 2004-2015 The MathWorks, Inc.

%fdesign.arbmagmeas class
%   fdesign.arbmagmeas extends fdesign.abstractmeas.
%
%    fdesign.arbmagmeas properties:
%       NormalizedFrequency - Property is of type 'bool' (read only) 
%       Fs - Property is of type 'mxArray' (read only) 
%       Frequencies - Property is of type 'mxArray' (read only) 
%       Amplitudes - Property is of type 'mxArray' (read only) 
%
%    fdesign.arbmagmeas methods:
%       getprops2norm -   Get the props2norm.
%       setprops2norm -   Set the props2norm.


properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
  %FREQUENCIES Property is of type 'mxArray' (read only)
  Frequencies = [];
  %AMPLITUDES Property is of type 'mxArray' (read only)
  Amplitudes = [];
end


methods  % constructor block
  function this = arbmagmeas(hfilter, varargin)
  %ARBMAGMEAS Construct an ARBMAGMEAS object.


  narginchk(1,inf);
  % this = fdesign.arbmagmeas;

  normFlag = false;
  removeFreqPointFlag = false;

  % Parse the inputs.
  if length(varargin) > 1
    % Expect specified frequencies to be correctly normalized if a sampling
    % frequency has been specified in the design.
    F = varargin{2};  
    if length(F) < 2
      % Freqz only supports 2 or more frequency points, so add a dummy point
      % instead of returning an error. Remove the point after measuring.
      F = [0 F];
      removeFreqPointFlag = true;
    end
    varargin(2) = [];
    parseconstructorinputs(this, hfilter, varargin{:});
  else
    % minfo always returns normalized frequencies
    minfo = parseconstructorinputs(this, hfilter, varargin{:});
    F = minfo.Frequencies;
    normFlag = true; 
  end
  if this.NormalizedFrequency
    Fs = 2;
  else
    Fs = this.Fs;
  end

  if normFlag
     F = F*Fs/2;
  end
  this.Frequencies = F;

  try
      A = zerophase(hfilter,F,Fs);
  catch %#ok<CTCH>
      A = abs(freqz(hfilter,F,Fs));
  end

  if removeFreqPointFlag
    this.Frequencies = this.Frequencies(2);
    A = A(2);
  end

  this.Amplitudes = A(:).';

  end  % arbmagmeas
end  % constructor block

methods 
  function set.Frequencies(obj,value)
    obj.Frequencies = value;
  end
  %------------------------------------------------------------------------
  function set.Amplitudes(obj,value)
    obj.Amplitudes = value;
  end
end   % set and get functions 

methods  % public methods
  props2norm = getprops2norm(this)
  setprops2norm(this,props2norm)
end  % public methods 

end  % classdef

