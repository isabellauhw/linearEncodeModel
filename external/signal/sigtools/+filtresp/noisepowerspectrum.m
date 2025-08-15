classdef noisepowerspectrum < filtresp.nlm
  %filtresp.noisepowerspectrum class
  %   filtresp.noisepowerspectrum extends filtresp.nlm.
  %
  %    filtresp.noisepowerspectrum properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %       Legend - Property is of type 'on/off'
  %       Grid - Property is of type 'on/off'
  %       Title - Property is of type 'on/off'
  %       FrequencyScale - Property is of type 'string'
  %       NormalizedFrequency - Property is of type 'string'
  %       FrequencyRange - Property is of type 'string'
  %       NumberOfPoints - Property is of type 'double'
  %       NumberOfTrials - Property is of type 'double'
  %
  %    filtresp.noisepowerspectrum methods:
  %       getplotdata - Return the data to plot
  %       getylabel - Returns the YLabel string
  %       getyparams - Get the yparams.
  %       objspecificdraw - Draw the NOISEPOWERSPECTRUM

%   Copyright 2015-2017 The MathWorks, Inc.
  
   
  methods  % constructor block
    function h = noisepowerspectrum(varargin)
      %NOISEPOWERSPECTRUM Construct a noisepowerspectrum object

      h.nlm_construct(varargin{:});
      
      h.Name = getString(message('signal:sigtools:filtresp:RoundoffNoisePowerSpectrum'));
      
      
    end  % noisepowerspectrum
    
  end  % constructor block
  
  methods  %% public methods
    function [W, P] = getplotdata(hObj, H, W, P, Nf)
      %GETPLOTDATA Return the data to plot

      for indx = 1:length(P)
        
        % Divide by two because this is already in power.
        P{indx} = convert2db(P{indx})/2;
      end
      
    end
    
    
    function ylbl = getylabel(this)
      %GETYLABEL Returns the YLabel string

      if strcmpi(this.NormalizedFrequency, 'On')
        ylbl = getString(message('signal:sigtools:filtresp:Radsample'));
      else
        ylbl = 'Hz';
      end
      
      ylbl = sprintf('%s (dB/%s)', getString(message('signal:sigtools:filtresp:Powerfrequency')), ylbl);
      
      
    end
    
    
    function yparams = getyparams(~)
      %GETYPARAMS Get the yparams.
      %   OUT = GETYPARAMS

      yparams = {'freqmode','unitcirclewnofreqvec'};
      
    end
    
    function [m, xunits] = objspecificdraw(this)
      %OBJSPECIFICDRAW Draw the NOISEPOWERSPECTRUM

      h              = this.Handles;
      h.axes         = h.axes(end);
      [indices, mssgObj] = checkfilters(this);
      if isempty(indices)
        if ~isempty(this.Filters) && ~isempty(mssgObj)
          warning(mssgObj)
        end
        
        % Make sure we remove the old line from the structure.
        h.line = [];
        this.Handles = h;
        m      = 1;
        xunits = '';
        return;
      end
      
      Hd = this.Filters;
      Hd = Hd(indices);
      
      opts = uddpvparse('dspopts.spectrum', 'NFFT', this.NumberOfPoints);
      
      switch lower(this.FrequencyRange)
        case {'[0, pi)', '[0, fs/2)'}
          opts.SpectrumType = 'onesided';
        case {'[0, 2pi)', '[0, fs)'}
          opts.SpectrumType = 'twosided';
        case {'[-pi, pi)', '[-fs/2, fs/2)'}
          opts.SpectrumType = 'twosided';
          opts.CenterDC      = true;
      end
      
      optsstruct.sosview = this.SOSViewOpts;
      optsstruct.showref = strcmpi(this.ShowReference, 'on');
      
      [P, W] = noisepsd(Hd, this.NumberOfTrials, opts, optsstruct);
      
      [~, wid] = lastwarn;
      if any(strcmpi(wid, {'fixed:fi:underflow', 'fixed:fi:overflow'}))
        lastwarn('');
      end
      
      % Calculate the data
      [W, m, xunits] = normalize_w(this, W);
      
      % Remove INFs from vector so HG doesn't act up.
      for indx = 1:length(P)
        P{indx}(P{indx} == Inf)  = NaN;
        P{indx}(P{indx} == -Inf) = NaN;
      end
      
      % Normalize data if a sampling frequency was specified.
      if strcmpi(this.NormalizedFrequency,'off')
        mfs = getmaxfs(this);
        for indx = 1:length(P)
          P{indx} = P{indx}+10*log10(2*pi/mfs);
        end
      end
      
      % Plot the data
      if ishandlefield(this,'line') && length(h.line) == size(P{1}, 2)
        for indx = 1:size(P{1}, 2)
          set(h.line(indx), 'XData',W{1}, 'YData',P{1}(:,indx));
        end
      else
        h.line = freqplotter(h.axes, W, P);
      end
      
      % Save the handles
      this.Handles = h;
      
      % Put up the ylabel from the subclass
      ylabel(h.axes, getylabel(this));
      
      % [EOF]
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function s = legendstring(hObj)
      %LEGENDSTRING

      s = 'Noise Power Spectrum';
    end
    
  end  %% possibly private or hidden
  
end  % classdef

