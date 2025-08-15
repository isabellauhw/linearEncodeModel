classdef freqresp < dspdata.abstractfiltfreqrespMCOS
  %dspdata.freqresp class
  %   dspdata.freqresp extends dspdata.abstractfiltfreqresp.
  %
  %    dspdata.freqresp properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %       Frequencies - Property is of type 'double_vector user-defined' (read only)
  %       SpectrumRange - Property is of type 'SignalFrequencyRangeList enumeration: {'Half','Whole'}'
  %
  %    dspdata.freqresp methods:
  %       abs -   Convert the frequency response to a magnitude response.
  %       angle -   Convert the frequency response to a phase respose.
  
  
  
  methods  % constructor block
    function this = freqresp(varargin)
      %FREQRESP   Construct a FREQRESP object.

      narginchk(0,8);
      
      % this = dspdata.freqresp;
      
      set(this, 'Name', 'Frequency Response');
      
      % Construct a metadata object.
      set(this,'Metadata',dspdata.powermetadataMCOS);
      set(this.Metadata,...
        'FrequencyUnits','Hz',...
        'DataUnits','volts^2/Hz');
      
      % Initialize Data and Frequencies with defaults or user specified values.
      initialize(this,varargin{:});
            
    end  % freqresp
    
  end  % constructor block
  
  methods  %% public methods
    function h = abs(this)
      %ABS   Convert the frequency response to a magnitude response.

      opts = {'SpectrumRange', this.SpectrumRange};
      if ~this.NormalizedFrequency
        opts = {'Fs', this.Fs, opts{:}};
      end
      
      h = dspdata.magresp(this.Frequencies, abs(this.Data), opts{:});
      
    end
    
    function h = angle(this)
      %ANGLE   Convert the frequency response to a phase respose.
      
      %   Author(s): J. Schickler
      %   Copyright 2004 The MathWorks, Inc.
      
      opts = {'SpectrumRange', this.SpectrumRange};
      if ~this.NormalizedFrequency
        opts = {'Fs', this.Fs, opts{:}};
      end
      
      h = dspdata.phaseresp(this.Frequencies, angle(this.Data), opts{:});
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function varargout = plot(this)
      %PLOT

      % Overloaded to do the "dual plot".
      hax = newplot;
      
      % Create the Magnitude Plot
      hax = gca;
      
      set(hax, 'YAxisLocation', 'Left');
      
      w = get(this, 'Frequencies');
      h = get(this, 'Data');
      
      if this.NormalizedFrequency
        xlbl = getfreqlbl('rad');
        w    = w/pi;
      else
        [w, m, xunits] = engunits(w);
        xlbl = getfreqlbl([xunits 'Hz']);
      end
      
      hl = line(w, 20*log10(abs(h)), 'Parent', hax);
      
      ylabel(hax, getString(message('signal:dspdata:dspdata:MagnitudedB')));
      xlabel(hax, xlbl);
      title(hax, getString(message('signal:dspdata:dspdata:MagnitudeAndPhaseResponse')));
      
      % Add a second axes in the same location as GCA
      hax2 = axes('Units', get(gca, 'Units'), ...
        'Position', get(gca, 'Position'), ...
        'YAxisLocation', 'Right', ...
        'Color', 'none');
      
      addlistener(hl, 'ObjectBeingDestroyed', @(h, ev) lcl_obd_listener(hax2));
      
      set(ancestor(hax2, 'figure'), 'CurrentAxes', hax2);
      
      hl = line(w, angle(h), 'Parent', hax2);
      
      ylabel(hax2, getString(message('signal:dspdata:dspdata:Phaseradians')));
      
      set(ancestor(hax2, 'figure'), 'CurrentAxes', hax);
      
      set(hl, 'Color', getcolorfromindex(hax2, 2));
      
      setcoincidentgrid([hax hax2]);
      
      set([hax hax2], ...
        'XGrid', 'On', ...
        'YGrid', 'On', ...
        'Box',   'On', ...
        'XLim',  [min(w) max(w)]);
      
      if nargout
        varargout = {h};
      end
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

% -------------------------------------------------------------------------
function lcl_obd_listener(hax2)

if ishandle(hax2)
  delete(hax2);
end

end