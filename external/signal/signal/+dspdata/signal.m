classdef signal < dspdata.abstractdatawfsMCOS
  %dspdata.signal class
  %   dspdata.signal extends dspdata.abstractdatawfs.
  %
  %    dspdata.signal properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %
  %    dspdata.signal methods:
  %       disp -   Display this object.
  %       plot -   Plot the signal.
  %       plotfcn -   Plot engine for all of the signal's methods.
  %       stem -   Create a stem plot of the signal.
  
  
  
  methods  % constructor block
    function this = signal(data, fs)
      %SIGNAL   Construct a SIGNAL object.

      set(this, 'Name', 'Signal');
      
      if nargin
        set(this, 'Data', data);
        if nargin > 1
          normalizefreq(this, false, fs);
        end
      end
      
      
    end  % signal
    
  end  % constructor block
  
  methods  %% public methods
    function disp(this)
      %DISP   Display this object.

      props = {'Name', 'Data', 'NormalizedFrequency'};
      
      if ~this.NormalizedFrequency
        props{end+1} = 'Fs';
      end
      
      siguddutils('dispstr', this, props);
      
    end
    
    
    function varargout = plot(this, varargin)
      %PLOT   Plot the signal.

      h = plotfcn(this, 'line');
      
      if nargout
        varargout = {h};
      end
      
    end
    
    
    function h = plotfcn(this, fcn, varargin)
      %PLOTFCN   Plot engine for all of the signal's methods.

      % Search through VARARGIN for 'Parent'.
      hax = [];
      if nargin > 2
        indx = find(strcmpi('parent', varargin));
        if ~isempty(indx)
          indx = max(indx);
          hax = varargin{indx+1};
          varargin(indx:indx+1) = [];
        end
      end
      
      % If we did not find an axes to use.
      if isempty(hax)
        hax = newplot;
      end
      
      d  = get(this, 'Data');
      
      if this.NormalizedFrequency
        t = [0:length(d)-1];
        xlbl = getString(message('signal:dspdata:dspdata:Samples'));
      else
        fs = get(this, 'Fs');
        
        t = [0:1/fs:length(d)/fs-1/fs];
        [t, m, xlbl] = engunits(t, 'latex', 'time');
      end
      
      h = feval(fcn, t, d, 'Parent', hax, varargin{:});
      
      ylabel(hax, getString(message('signal:dspdata:dspdata:Amplitude')));
      xlabel(hax, getString(message('signal:dspdata:dspdata:Time', xlbl)));
      
    end
    
    
    function varargout = stem(this, varargin)
      %STEM   Create a stem plot of the signal.

      h = plotfcn(this, 'stem', varargin{:});
      
      if nargout
        varargout = {h};
      end
      
    end
    
    
  end  %% public methods
  
end  % classdef

