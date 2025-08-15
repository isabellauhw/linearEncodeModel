classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, Abstract) abstractfreqrespMCOS < dspdata.abstractdatawfsMCOS
  %dspdata.abstractfreqresp class
  %   dspdata.abstractfreqresp extends dspdata.abstractdatawfs.
  %
  %    dspdata.abstractfreqresp properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %       Frequencies - Property is of type 'double_vector user-defined' (read only)
  %
  %    dspdata.abstractfreqresp methods:
  %       centerdc -   Shift the zero-frequency component to center of spectrum.
  %       computeresp4freqrange -   Calculate the frequency response for the range
  %       convert2db -   Convert input response to db values.
  %       copy -   Copy the object.
  %       createoptsobj -   Creates a default options object for this class.
  %       disp -   Display method.
  %       getcenterdc -   Get the centerdc.
  %       getdata -   Get the complex data and frequency from the object.
  %       getfreqrange -   Return range of object and the index to range options.
  %       getname -   Get the name to be used in the plot title.
  %       getrangepropname -   Returns the property name for the range option.
  %       gettitle -   Get the title.
  %       getylabel -   Get the ylabel.
  %       info -   Returns information about the ps or psd object.
  %       initialize -   Initialize power spectrum data objects.
  %       isdensity -   Return true if object contains a PSD.
  %       isevenwholenfft -   True if the length of the "whole" frequency response is even.
  %       ishalfnyqinterval -   True if the frequency response was calculated for only
  %       ispectrumshift -   Inverse of SPECTRUMSHIFT.
  %       loadobj -   Load this object.
  %       normalizefreq -   Normalize/un-normalize the frequency of the data object.
  %       plot -   Plot the response.
  %       plotindb -   Returns true if the object plots in dB.
  %       psdfreqvec -  Returns the frequency vector with appropriate frequency range.
  %       reorderprops -   List of properties to reorder.
  %       responseobj -   Response object.
  %       saveobj -   Save this object.
  %       set_data -   PreSet function for the 'data' property.
  %       spectrumshift -   Shift zero-frequency component to center of spectrum.
  %       svtool -   Spectral visualization tool for the dspdata objects.
  %       thiscenterdc -   Shift the zero-frequency component to center of spectrum.
  %       thisloadobj -   Load this object.
  %       thisnormalizefreq -   Normalize/un-normalize the frequency of the data object.
  %       thissaveobj -   Save this object.
  %       validatedata -   Validate the data.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable, Hidden)
    %METADATA Property is of type 'dspdata.powermetadata' (hidden)
    Metadata = [];
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %CENTERDC Property is of type 'bool'
    CenterDC = false;
  end
  
  properties (SetAccess=protected, AbortSet, SetObservable, GetObservable)
    %FREQUENCIES Property is of type 'double_vector user-defined' (read only)
    Frequencies = [  ];
  end
  
  
  methods
    function set.Frequencies(obj,value)
      % User-defined DataType = 'double_vector user-defined'
      obj.Frequencies = setfrequencies(obj,value);
    end
    
    function set.CenterDC(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'logical'}, {'scalar'},'','CenterDC')
      obj.CenterDC = value;
    end
    
    function set.Metadata(obj,value)
      % DataType = 'dspdata.powermetadata'
      validateattributes(value,{'dspdata.powermetadataMCOS'}, {'scalar'},'','Metadata')
      obj.Metadata = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function centerdc(this,state)
      %CENTERDC   Shift the zero-frequency component to center of spectrum.

      if nargin < 2
        state = true;
      end
      
      if ~xor(this.CenterDC, state)
        return;  % State specified = object's state, therefore no-op.
      end
      this.CenterDC = state;
      
      % Call subclasses' method.
      thiscenterdc(this);
      
    end
    
    
    function [H,W] = computeresp4freqrange(this,userreq_halfrange,ispsd,isnormalized,centerdc) %#ok<INUSD,INUSL>
      %COMPUTERESP4FREQRANGE   Calculate the frequency response for the range
      %                        requested.

      % Define a boolean flag representing the state of SpectrumRange property.
      obj_hashalfrange = ishalfnyqinterval(this);
      
      % Make sure that Fs, frequency, and NormalizedFrequency property are all
      % consistent.
      normalizefreq(this,logical(isnormalized));
      
      if ~userreq_halfrange && obj_hashalfrange     % User requested 'whole' but obj has 'half'.
        wholerange(this);
        
      elseif userreq_halfrange && ~obj_hashalfrange % User requested 'half' but obj has 'whole'.
        halfrange(this);
      end
      H = this.Data;
      W = this.Frequencies;
      
    end
    
    
    function HdB = convert2db(this,H)
      %CONVERT2DB   Convert input response to db values.

      ws = warning; % Cache warning state
      warning off   % Avoid "Log of zero" warnings
      HdB = db(H,'voltage');  % Call the Convert to decibels engine
      warning(ws);  % Reset warning state
      
    end
    
    
    function h = copyTheObj(this)
      %COPY   Copy the object.

      % Need to set all these properties at once since they're related.
      propname = getrangepropname(this);
      proplist = {...
        this.Data, ...
        this.Frequencies,...
        propname,get(this,propname),...
        'CenterDC',this.CenterDC};
      
      if this.NormalizedFrequency
        h = feval(this.class,proplist{:});
        h.privFs  = getfs(this); % Store Fs in case it's not the default value.
      else
        h = feval(this.class,proplist{:},'Fs',getfs(this));
      end
      
      h.Metadata                 = copy(this.Metadata);
      h.privNormalizedFrequency  = this.NormalizedFrequency;
      
    end
    
    
    function hopts = createoptsobj(this)
      %CREATEOPTSOBJ   Creates a default options object for this class.

      hopts = dspopts.pseudospectrum;
      
    end
    
    
    function disp(this)
      %DISP   Display method.

      proplist = reorderprops(this);
      snew = reorderstructure(get(this),proplist{:});
      
      val = 'false';
      if this.NormalizedFrequency
        val = 'true';
      end
      snew.NormalizedFrequency = val;
      snew = changedisplay(snew,'NormalizedFrequency',val);
      disp(snew);
      
    end
    
    
    function centerdc = getcenterdc(this)
      %GETCENTERDC   Get the centerdc.
      %
      % Private method.

      centerdc = this.CenterDC;
      
    end
    
    
    function [H,W] = getdata(this,varargin)
      %GETDATA   Get the complex data and frequency from the object.
      %  [H,W] = GETDATA(H,ISPSD,ISDB,ISNORMALIZED,FREQRANGE,CENTERDC) returns
      %  the data and frequencies from the object H, modified according to the
      %  inputs ISPSD, ISDB, ISNORMALIZED, FREQRANGE, and CENTERDC.
      %
      %  Inputs:
      %    this         - handle to data object.
      %    ispsd        - boolean indicating if data should be returned as a
      %                   power spectral density.
      %    isdb         - boolean indicating if data should be in dB scale
      %                   (default = false).
      %    isnormalized - boolean indicating if frequency should be normalized
      %                   (default = state of NormalizedFrequency).
      %    freqrange    - string indicating if spectrum should be calculated over
      %                   half or the whole Nyquist interval.
      %                   The possible options are:
      %                        'half'  - convert spectrum to half or onesided
      %                        'whole' - convert spectrum to whole or twosided
      %   centerdc      - shift the spectrum so that 0 (the DC value) is in the
      %                   center of the frequency grid.

      narginchk(1,6);
      
      % Set default values and parse inputs.
      [ispsd,isdb,isnormalized,freqrange,centerdc] = parseinputs(this,varargin{:});
      
      % Cache object property values.
      Fs = this.getfs;
      normFlag = this.NormalizedFrequency;
      
      % Define a boolean flag representing the frequency range requested.
      ishalfrange = false;
      if strcmpi(freqrange,'half')
        ishalfrange = true;
      end
      
      % Calculate the response for the frequency range selected by the user.
      [H,W] = computeresp4freqrange(this,ishalfrange,ispsd,isnormalized,centerdc);
      
      if isdb
        H = convert2db(this,H);
      end
      
    end
    
    
    function idx = getfreqrange(this)
      %GETFREQRANGE   Return range of object and the index to range options.

      if ishalfnyqinterval(this)
        idx = 1;     % 0 to pi       or    0 to Fs/2
        
      else
        idx = 2;     % 0 to 2pi      or    0 to Fs
        
        if this.CenterDC
          idx = 3; % -pi to pi     or    -Fs/2 to Fs/2
        end
      end
      
    end
    
    
    function name = getname(this)
      %GETNAME   Get the name to be used in the plot title.

      % Return the name to be used in the title string.
      name = [this.Name,' Estimate'];
      
    end
    
    
    function rangepropname = getrangepropname(this)
      %GETRANGEPROPNAME   Returns the property name for the range option.

      rangepropname = 'SpectrumRange';
      
    end
    
    
    function titlestr = gettitle(this)
      %GETTITLE   Get the title.

      % Set up the title.
      titlestr = getname(this); % Handle PSD, MSS, and Pseudospectrum
      
      infoStruc = info(this);
      if strcmpi(infoStruc.EstimationMethod, 'unknown')
        % Remove "Estimation" from the title, when spectrum objects didn't
        % create the DSPDATA object.
        idx = regexpi(titlestr,' Estimate','once');
        titlestr = titlestr(1:idx-1);
      else
        titlestr = sprintf('%s %s',infoStruc.EstimationMethod, titlestr);
      end
      
    end
    
    
    function ylbl = getylabel(this)
      %GETYLABEL   Get the ylabel.

      error(message('signal:dspdata:abstractfreqresp:getylabel:MustBeOverloaded'));
      
    end
    
    
    function varargout = info(this)
      %INFO   Returns information about the ps or psd object.
 
      if isempty(this.Metadata)
        f = {};
        v = {};
      else
        [f, v] = info(this.Metadata);
      end
      
      f = {'Type',    f{1}, 'Length',                         getrangepropname(this), 'Fs',    f{2:end}};
      v = {this.Name, v{1}, sprintf('%d', length(this.Data)), this.(f{4}),           this.Fs, v{2:end}};
      
      i = cell2struct(v, f, 2);
      
      if nargout
        varargout = {i};
      else
        disp(i);
      end
      
    end
    
    
    function this = initialize(this,varargin)
      %INITIALIZE   Initialize power spectrum data objects.
      %   INITIALIZE(H,DATA,FREQUENCIES) sets the H object with DATA as the data
      %   and FREQUENCIES as the frequency vector.  If FREQUENCIES is not
      %   specified it defaults to [0, pi).
      %
      %   INITIALIZE(...,p1,v1,p2,v2) See help for concrete classes.
      %

      narginchk(1,13);
      if nargin > 1
          [varargin{:}] = convertStringsToChars(varargin{:});
      end
      
      % Set default values.
      data = [];
      dataLen = 0;
      W = [];
      opts = [];
      hopts = createoptsobj(this);
      
      if nargin > 1
        data = varargin{1};
        [data, dataLen] = validate_data(this, data);
        
        % Parse the rest of the inputs if any.
        opts = varargin(2:end);
        [W,opts] = parseinputs2(this,opts,dataLen,hopts,isa(data,'single')); % Updates optiosn object.
      end
      
      % Verify that the cell array of options contains valid pv-pairs for dspdata.
      propName = getrangepropname(this);  % Handle SpectrumRange and SpectrumType
      
      if(strcmp(this.Name,'Power Spectral Density') || strcmp(this.Name,'Mean-Square Spectrum'))
        validProps = lower({propName,'CenterDC','Fs','ConfLevel','ConfInterval'});
        validateopts(this,opts,validProps);
        set(this,'ConfLevel',hopts.COnfLevel,...
          'ConfInterval', hopts.ConfInterval);
      else
        validProps = lower({propName,'CenterDC','Fs'});
        validateopts(this,opts,validProps);
      end
      
      % Set the properties of the object. Use options obj settings for defaults.
      set(this,...
        'Data',data,...
        'Frequencies', W,...
        'CenterDC',hopts.CenterDC,...
        'privNormalizedFrequency',hopts.NormalizedFrequency,...
        'Fs',hopts.Fs);
      
      % Handle read-only property in subclass separately.
      setspectrumtype(this,get(hopts,propName));
      
    end
    
    
    function isden = isdensity(this)
      %ISDENSITY   Return true if object contains a PSD.

      isden = false;
      
    end
    
    function iseven = isevenwholenfft(this,Nfft,w)
      %ISEVENWHOLENFFT   True if the length of the "whole" frequency response is even.

      if nargin < 2
        [Nfft,nchans] = size(this.Data);
        w = this.Frequencies;
      end
      
      % To determine if the "whole" Nfft is EVEN check to see if the frequency
      % vector includes the Nyquist (pi or Fs/2).
      if this.NormalizedFrequency
        fnyq = pi;
      else
        fnyq = this.getfs/2;
      end
      
      lastpt    = w(end);
      freqrange = lastpt-w(1);
      halfDeltaF  = freqrange/(Nfft-1)/2;
      dist2nonnyq = lastpt - (fnyq-halfDeltaF);  % Distance to pt before Nyquist.
      dist2nyq    = lastpt - fnyq;               % Distance to Nyquist.
      
      iseven = false;
      if  abs(dist2nyq) < abs(dist2nonnyq) % Assume EVEN "whole" NFFT
        iseven = true;
      end
      
    end
    
    
    function flag = ishalfnyqinterval(this)
      %ISHALFNYQINTERVAL   True if the frequency response was calculated for only
      %                    half the Nyquist interval.

      flag = false;
      if strcmpi(get(this,getrangepropname(this)),'half')
        flag = true;
      end
      
    end
    
    
    function [H,W] = ispectrumshift(this,H,W)
      %ISPECTRUMSHIFT   Inverse of SPECTRUMSHIFT.

      if nargin == 1
        H = this.Data;
        W = this.Frequencies;
      end
      
      [nfft,nchans] = size(H);
      
      % Determine half the number of FFT points.
      if rem(nfft,2)
        halfNfft = (nfft+1)/2;  % ODD
        negEndPt = halfNfft;
        halfDeltaF = max(abs(diff(W)))/2;  % There's half of delta F on both sides of Nyquist.
      else
        halfNfft = (nfft/2)+1;  % EVEN
        negEndPt = halfNfft-1;
        halfDeltaF = 0;  % Nyquist point is included.
        
        % Move the Nyquist point to the left-hand side (neg freq) as expected
        % by ifftshift.
        H = [H(end,:); H(1:end-1,:)];
      end
      
      % Convert to plot + frequencies only.
      H = ifftshift(H);
      
      if this.NormalizedFrequency,   Fn = pi;
      else                           Fn = getfs(this)/2;
      end
      W = [W(negEndPt:end); -flipud(W(1:negEndPt-1))+Fn-halfDeltaF];
      
      if nargout == 0
        this.Data = H;
        this.Frequencies = W;
      end
      
    end
    
    
    function normalizefreq(this,varargin)
      %NORMALIZEFREQ   Normalize/un-normalize the frequency of the data object.

      [normFlag,Fs] = parseinputs3(this,varargin{:});
      
      freq = this.Frequencies;
      oldFs = getfs(this);  % Cache Fs stored in the object before it gets updated.
      newFsFlag = false;
      
      % If already in the units requested, and Fs hasn't changed return early.
      if ~xor(this.NormalizedFrequency, normFlag)
        % Only proceed if user specified a different Fs.
        if isequal(oldFs,Fs)
          return;
        else
          % Convert to normalized frequency in order to scale by new Fs.
          newFsFlag = true;
          freq = freq/oldFs*(2*pi);
        end
      end
      
      if normFlag,    freq = freq/Fs*(2*pi);   % Convert to normalized frequency.
      else            freq = freq/(2*pi)*Fs;   % Convert to linear frequency.
      end
      
      if normFlag
        this.Fs = Fs; % Set Fs first since you can't do it after it's in normalized mode.
        this.privNormalizedFrequency = normFlag;
      else
        this.privNormalizedFrequency = normFlag;  % Change to linear to allow us to set Fs.
        this.Fs = Fs;
      end
      this.Frequencies = freq;
      
      % Allow concrete classes to do further manipulation of the data if necessary.
      thisnormalizefreq(this,oldFs,newFsFlag);
      
    end
    
    
    function varargout = plot(this)
      %PLOT   Plot the response.

      if length(this) > 1
        error(message('signal:dspdata:abstractfreqresp:plot:InvalidInputs'));
      end
      
      normfreq = get(this, 'NormalizedFrequency');
      
      % Determine the frequency range to plot.
      freqrange = 'whole';
      if ishalfnyqinterval(this)
        freqrange = 'half';
      end
      centerdc = getcenterdc(this);
      
      % Create a new plot or reuse an available one.
      hax = newplot;
      
      % Get the data from this object.
      [H, W] = getdata(this,isdensity(this),plotindb(this),normfreq,freqrange,centerdc);
      
      % Set up the xlabel.
      if normfreq
        W    = W/pi;
        xlbl = getfreqlbl('rad/sample');
      else
        [W, ~, xunits] = engunits(W);
        xlbl = getfreqlbl([xunits 'Hz']);
      end
      
      % Plot the data.
      h = line(W, H, 'Parent', hax);
      
      if((strcmp(this.Name, 'Power Spectral Density') || strcmp(this.Name, 'Mean-Square Spectrum')) && ~isempty(this.ConfInterval))
        CI = this.ConfInterval;
        CL = this.ConfLevel;
        Hc = db(CI,'power');
        
        % Plot the Confidence Intervals.
        for i=1:size(H,2)
          baseColor = get(h(i,1),'Color');
          h(i,2) = line(W, Hc(:,2*i-1),'Color',baseColor,'LineStyle','-.','Parent',hax);
          h(i,3) = line(W, Hc(:,2*i),'Color',baseColor,'LineStyle','-.','Parent', hax);
        end
        
        % convert to row vector for backwards compatibility
        h = h(:)';
        
        % re-order the children so first two legend entries are 'correct'.
        hc = get(hax,'Children');
        if numel(hc)==numel(h)
          set(hax,'Children',reshape(reshape(hc,numel(hc)/3,3)',1,numel(hc)));
        end
        
        % re-save as rows for backwards compatibility.
        h = h';
        
        if strcmp(this.Name, 'Power Spectral Density')
          Estimate = getString(message('signal:dspdata:abstractfreqresp:plot:PowerSpectralDensity'));
        else
          Estimate = getString(message('signal:dspdata:abstractfreqresp:plot:PowerSpectrum'));
        end
        Interval = getString(message('signal:dspdata:abstractfreqresp:plot:ConfidenceIntervalPct',num2str(CL*100)));
        legend(Estimate,Interval,'Location','best');
      end
      
      xlabel(hax, xlbl);
      
      % Set up the ylabel
      ylabel(hax, getylabel(this));
      
      title(hax, getTranslatedString('signal:dspdata:dspdata',gettitle(this)));
      
      set(hax, 'Box', 'On', ...
        'XGrid', 'On', ...
        'YGrid', 'On', ...
        'XLim', [min(W) max(W)]);
      
      % Ensure axes limits are properly cached for zoom/unzoom
      resetplotview(hax,'SaveCurrentView');
      
      if nargout
        varargout = {h};
      end
      
    end
    
    
    function b = plotindb(this)
      %PLOTINDB   Returns true if the object plots in dB.

      b = false;
      
    end
    
    
    function W = psdfreqvec(this,hopts) %#ok<INUSL>
      %PSDFREQVEC  Returns the frequency vector with appropriate frequency range.

      % Determine length of FFT to calculate the spectrum over the whole Nyquist
      % interval.
      lenX = hopts.NFFT;
      wholenfft = lenX;
      range = 'whole';
      
      if ishalfnyqinterval(hopts)
        range = 'half';
        wholenfft = (lenX-1)*2; % Spec: always assume whole was EVEN; required by psdfreqvec.m
      end
      
      % psdfreqvec requires the whole NFFT to calculate 'half' Nyquist range.
      if hopts.NormalizedFrequency
        Fs = []; % Used by psdfreqvec to calculate rad/sample.
      else
        Fs = hopts.Fs;
      end
      
      % Special case the singleton/DC case.
      if wholenfft == 0
        W = 0;
      else
        W = psdfreqvec('npts',wholenfft,'Fs',Fs,'CenterDC',hopts.CenterDC,'Range',range);
      end
      
    end
    
    
    function proplist = reorderprops(this)
      %REORDERPROPS   List of properties to reorder.

      proplist = {'Name','Data',getrangepropname(this)};
      
    end
    
    
    function hresp = responseobj(this)
      %RESPONSEOBJ   Response object.
      %
      % This is a private method.

      siguddutils('abstractmethod',this);
      
    end
    
    
    function s = saveobj(this)
      %SAVEOBJ   Save this object.

      s          = get(this);
      s.Fs       = this.privFs;
      s.class    = class(this);
      s.Metadata = this.Metadata;
      s.CenterDC = this.CenterDC;
      
      s = setstructfields(s, thissaveobj(this));
      
    end
    
    
    function data = set_data(this, data)
      %SET_DATA   PreSet function for the 'data' property.

      % Determine if the input is a matrix; if row make it column.
      [data,nfft,nchans] = checkinputsigdim(data);
      
      % When the data changes we have to assume that the stored spectrum
      % information no longer applies.
      this.Metadata.setsourcespectrum([]);
      
    end
    
    
    function [H,W] = spectrumshift(this,H,W)
      %SPECTRUMSHIFT   Shift zero-frequency component to center of spectrum.

      if nargin == 1
        H = this.Data;
        W = this.Frequencies;
      end
      
      % Convert to plot + and - frequencies.
      H = fftshift(H,1);  % Places the Nyquist freq on the negative side.
      
      nfft = size(H,1);
      
      % Determine half the number of FFT points.
      if rem(nfft,2)
        halfNfft = (nfft+1)/2;  % ODD
        negEndPt = halfNfft;
        
      else
        halfNfft = (nfft/2)+1;  % EVEN
        negEndPt = halfNfft-1;
        
        % Move the Nyquist point to the right-hand side (pos freq) to be
        % consistent with plot when looking at the positive half only.
        H = [H(2:end,:); H(1,:)];
      end
      
      W = [-flipud(W(2:negEndPt)); W(1:halfNfft)]; % -Nyquist:Nyquist
      
      if nargout == 0
        this.Data = H;
        this.Frequencies = W;
      end
      
    end
    
    
    function svtool(H)
      %SVTOOL   Spectral visualization tool for the dspdata objects.

      % First copy the object to de-couple the plot from the command line.
      this = copy(H);
      
      % Create a class-specific response object.
      hresp = responseobj(this);
      rangeopts = getfreqrangeopts(hresp); % rad/sample or Hz
      freqrangeidx = getfreqrange(this);
      
      set(hresp,...
        'FrequencyRange',rangeopts{freqrangeidx},...
        'Name',gettitle(this));
      
      plot(hresp);
      
    end
    
    
    function thiscenterdc(this)
      %THISCENTERDC   Shift the zero-frequency component to center of spectrum.

      % First convert to a spectrum that occupies the whole Nyquist interval.
      if ishalfnyqinterval(this)
        wholerange(this);
      end
      
      if this.CenterDC
        % Center the DC component.
        spectrumshift(this);
      else
        % Move the DC component back to the left edge.
        ispectrumshift(this);
      end
      
      % [EOF]
      
    end
    
    
    function thisloadobj(this, s)
      %THISLOADOBJ   Load this object.

      % NO OP.
      
    end
    
    function thisnormalizefreq(this,varargin)
      %THISNORMALIZEFREQ   Normalize/un-normalize the frequency of the data object.

      % No op.
      
    end
    
    function s = thissaveobj(this)
      %THISSAVEOBJ   Save this object.

      s = [];
      
    end
    
    
    function validatedata(this, data)
      %VALIDATEDATA   Validate the data.

    end
    
  end  %% public methods
  
  
  methods (Static) %% static methods
    function this = loadobj(s)
      %LOADOBJ   Load this object.

      this = feval(s.class);
      
      normalizefreq(this, s.NormalizedFrequency);
      
      set(this, ...
        'privFs',      s.Fs, ...
        'Data',        s.Data, ...
        'Frequencies', s.Frequencies, ...
        'CenterDC',    s.CenterDC, ...
        'Metadata',    s.Metadata);
      
      thisloadobj(this, s);
      
    end
    
  end  %% static methods
  
end  % classdef

function freq = setfrequencies(this, freq)

if ~isempty(freq) && ~isnumeric(freq)
  error(message('signal:dspdata:abstractfreqresp:schema:invalidFrequencyVector'));
end

freq = freq(:);
end  % setfrequencies
% Ensure that frequency is stored as a column.

%--------------------------------------------------------------------------
function [ispsd,isdb,isnormalized,freqrange,centerdc] = parseinputs(this,varargin)
%PARSEINPUTS   Set default values and parse the input argument list.

% Defaults
ispsd        = isdensity(this);
isdb         = false;
isnormalized = this.NormalizedFrequency;
freqrange    = 'whole';
centerdc     = false;

if ishalfnyqinterval(this)
  freqrange = 'half';
end

% Parse inputs
if nargin >= 2
  ispsd = varargin{1};
  if nargin >= 3
    isdb = varargin{2};
    if nargin >= 4
      isnormalized = varargin{3};
      if nargin >= 5
        freqrange = varargin{4};
        if nargin >= 6
          centerdc = varargin{5};
        end
      end
    end
  end
end

validStrs = {'half','whole'};
if ~any(strcmpi(freqrange,validStrs))
  error(message('signal:dspdata:abstractfreqresp:getdata:invalidFrequencyRangeStr', validStrs{ 1 }, validStrs{ 2 }));
end

end

%--------------------------------------------------------------------------
function validateopts(this,opts,validProps) %#ok<INUSL>
% Verify that the cell array of options contain valid pv-pairs.

if isempty(opts); return; end

optsLen = ceil(length(opts)/2);  % account values.

for k = 1:optsLen
  propName = opts{2*k-1}; % pick every odd element which should be the "Property"
  lc_propname = lower(propName);
  if ~ischar(lc_propname) || isempty(strmatch(lc_propname,validProps))
    error(message('signal:dspdata:abstractfreqresp:initialize:invalidStringInParameterValuePair', propName));
  end
end

end

%--------------------------------------------------------------------------
function [data,dataLen] = validate_data(this, data)
% Validate and get the size of the input data.

% Determine if the input is a matrix; and if row make it a column.
[data,dataLen] = checkinputsigdim(data);

validatedata(this, data);

end

%--------------------------------------------------------------------------
function  validate_freq(hopts,W,isDataSingle)
%VALIDATE_FREQ  Return an error if an invalid frequency vector was specified.
% Valid ranges are:
%
%  0 to Fs       or  0 to 2pi
%  0 to Fs/2     or  0 to pi
%  -Fs/2 to Fs/2 or  -pi to pi

sampFreq = hopts.Fs;
centerdc = hopts.CenterDC;
ishalfnyquistinterval = ishalfnyqinterval(hopts);

if isDataSingle
  sampFreq = single(sampFreq);
  thisPi = single(pi);
else
  thisPi = pi;
end

% Setup up end-points and define valid frequency ranges.
if hopts.NormalizedFrequency
  unitStr = ' rad/sample';
  sampFreq = 2*thisPi;
  freqrangestr_start = '[0';
  freqrangestr_end = '2*pi)';
  
  if centerdc
    freqrangestr_start = '(-pi';
    freqrangestr_end = 'pi]';
  elseif ishalfnyquistinterval
    freqrangestr_start = '[0';
    freqrangestr_end = 'pi)';
  end
  halfsampFreq = sampFreq/2;
  
else
  halfsampFreq = sampFreq/2;
  unitStr = ' Hz';
  freqrangestr_start = '[0';
  freqrangestr_end = sprintf('%s)',num2str(sampFreq));
  
  if centerdc
    freqrangestr_start = sprintf('(-%s',num2str(halfsampFreq));
    freqrangestr_end = sprintf('%s]',num2str(halfsampFreq));
  elseif ishalfnyquistinterval
    freqrangestr_start = '[0';
    freqrangestr_end = sprintf('%s)',num2str(halfsampFreq));
  end
end

% Validate the frequency vector.

if centerdc
  % Not distiguishing between odd or even length of data.  This allows
  % non-uniformly sampled data.
  if  W(1) <= -halfsampFreq || W(end) > halfsampFreq
    error(message('signal:dspdata:abstractfreqresp:initialize:invalidFrequencyVector', freqrangestr_start, freqrangestr_end, unitStr));
  end
  
elseif ishalfnyquistinterval
  % Not distiguishing between odd or even length of data.  This allows
  % non-uniformly sampled data.
  if W(end) > halfsampFreq
    error(message('signal:dspdata:abstractfreqresp:initialize:invalidFrequencyVector', freqrangestr_start, freqrangestr_end, unitStr));
  end
  
else
  if W(end) >= sampFreq
    error(message('signal:dspdata:abstractfreqresp:initialize:invalidFrequencyVector', freqrangestr_start, freqrangestr_end, unitStr));
  end
end

end

%--------------------------------------------------------------------------
function [W,opts]= parseinputs2(this,opts,dataLen,hopts,isDataSingle)
% Parse the input.  Use the options object as a means to get default values
% for some of the dspdata object parameters.

% Define default values in case of early return due to an error.
W = [];      % Default frequency vector.

% Parse options.
if ~isempty(opts) && ~ischar(opts{1})
  W = opts{1};     % Assume it's the frequency vector
  opts(1)=[];
  sizechkdatanfreq(this,dataLen,length(W));
end

% Update the options object with dspdata options specified, if any, to pass
% it to the psdfreqvec and validate_freq functions below.
set(hopts,opts{:});
hopts.NFFT = dataLen; % Update NFFT based on the input data length.

if isempty(W)
  W = psdfreqvec(this,hopts);
else
  % No need to verify since we're creating the vector.
  validate_freq(hopts,W,isDataSingle);
end

end


%--------------------------------------------------------------------------
function  sizechkdatanfreq(this,dataLen,lenW) %#ok<INUSL>
%SIZECHKDATANFREQ  Return an error msg if the sizes don't match.

% Verify that the data and frequency vector are the same length!
if dataLen ~= lenW
  error(message('signal:dspdata:abstractfreqresp:initialize:sizemismatchDataFrequency'));
end

end

%--------------------------------------------------------------------------
function [normFlag,Fs] = parseinputs3(this,varargin)
% Parse and validate inputs.

% Setup defaults
normFlag = true;
Fs = getfs(this);

if nargin >= 2
  normFlag = varargin{1};
  if nargin == 3
    Fs = varargin{2};
  end
end

if nargin == 3 && normFlag
  error(message('signal:dspdata:abstractfreqresp:normalizefreq:invalidInputArgumentFs', 'Fs'));
end

if ~islogical(normFlag)
  error(message('signal:dspdata:abstractfreqresp:normalizefreq:invalidLogicalFlag'));
end

end

