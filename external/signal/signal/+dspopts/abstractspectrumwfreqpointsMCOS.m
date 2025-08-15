classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) abstractspectrumwfreqpointsMCOS < dspopts.abstractspectrumMCOS & sigio.dyproputil & hgsetget
  %dspopts.abstractspectrumwfreqpoints class
  %   dspopts.abstractspectrumwfreqpoints extends dspopts.abstractspectrum.
  %
  %    dspopts.abstractspectrumwfreqpoints properties:
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray'
  %       CenterDC - Property is of type 'mxArray'
  %       FreqPoints - Property is of type 'psdFreqPointsType enumeration: {'All','User Defined'}'
  %
  %    dspopts.abstractspectrumwfreqpoints methods:
  %       calcnfft -   Get the numeric value of NFFT even when it's set to a string.
  %       copyTheObj -     Copy this object
  %       loadobj -  Load this object.
  %       saveobj -  Save this object.
  %       set_freqpoints -   PreSet function for the 'freqpoints' property.
  %       set_frequencyvector -   PreSet function for the 'FrequencyVector' property.
  %       set_nfft -   PreSet function for the 'nfft' property.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (SetObservable, GetObservable)
    %FREQPOINTS Property is of type 'psdFreqPointsType enumeration: {'All','User Defined'}'
    FreqPoints = 'All';
  end
  
  
  methods
    function set.FreqPoints(obj,value)
      % Enumerated DataType = 'psdFreqPointsType enumeration: {'All','User Defined'}'
      value = validatestring(value,{'All','User Defined'},'','FreqPoints');
      obj.FreqPoints = set_freqpoints(obj,value);
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function nfft = calcnfft(hopts,segLen)
      %CALCNFFT   Get the numeric value of NFFT even when it's set to a string.
 
      freqpoints = hopts.FreqPoints;
      switch lower(freqpoints)
        case 'all'
          nfft = hopts.NFFT;
          if ischar(nfft)
            switch lower(nfft)
              case 'nextpow2'
                nfft = max(256,2^nextpow2(segLen)); % segLen=input length for all but welch.
              case 'auto'
                nfft = max(256,segLen);
            end
          end
        case 'user defined'
          nfft = hopts.frequencyvector;
          if ischar(nfft)
            switch lower(nfft)
              case 'auto'
                nfft = max(256,segLen);
            end
            Fs = hopts.Fs;
            if ischar(Fs)
              if strcmp(Fs, 'Normalized')
                Fs = 2*pi;
              end
            end
            
            range = 'whole';
            if ishalfnyqinterval(hopts)
              range = 'half';
            end
            nfft = psdfreqvec('npts',nfft, 'Fs',Fs, 'Range',range);
          end
      end
      % [EOF]
      
    end
    
    function Hcopy = copyTheObj(this)
      %COPY     Copy this object
      %   OUT = COPY(ARGS) <long description>

      Hcopy = loadobj(this);
      
      % [EOF]
      
    end
    
    
    function s = saveobj(this)
      %SAVEOBJ  Save this object.
      %   OUT = SAVEOBJ(ARGS) <long description>

      s.class   = class(this);
      
      % Save all of the public properties.
      s = setstructfields(s, get(this));
      
      % [EOF]
      
    end
    
    
    function freqpoints = set_freqpoints(this, freqpoints)
      %SET_freqpoints   PreSet function for the 'freqpoints' property.

      % FreqPoints takes an enum type of {'All', 'User Defined'}
      % A choice of 'All' dynamicall creates 'nfft' field
      % A choice of 'User Defined' sets up 'FrequencyVector' field
      
      validStrs = {'All','User Defined'};
      
      if isnumeric(freqpoints)
        error(message('signal:dspopts:abstractspectrumwfreqpoints:set_freqpoints:invalidFreqPointsValue', 'FreqPoints', 'FreqPoints', validStrs{ 1 }, validStrs{ 2 }));
      else
        idx = [];
        for k=1:length(validStrs)
          if regexp(lower(validStrs{k}),['^',lower(freqpoints)],'once')
            idx=k;
          end
        end
        if isempty(idx)
          error(message('signal:dspopts:abstractspectrumwfreqpoints:set_freqpoints:invalidFreqPointsValue', 'FreqPoints', 'FreqPoints', validStrs{ 1 }, validStrs{ 2 }));
        else
          % Use full string with correct capitalization.
          if (idx==1)
            p = this.findprop('FrequencyVector');
            if ~isempty(p)
              % Remove the property.
              delete(p);
            end
            if ~isprop(this,'NFFT')
              h = this.addprop('NFFT');
              h.SetObservable = true;
              h.GetObservable = true;
              addlistener(this,'NFFT','PostSet',@(s,e)set_nfft(this));
            end
            this.NFFT = 'Nextpow2';
          elseif (idx==2)
            p = this.findprop('NFFT');
            if ~isempty(p)
              % Remove the property.
              delete(p);
            end
            if ~isprop(this,'FrequencyVector')
              h = this.addprop('FrequencyVector');
              h.SetObservable = true;
              h.GetObservable = true;
              addlistener(this,'FrequencyVector','PostSet',@(s,e)set_frequencyvector(this));
            end
            this.FrequencyVector = 'Auto';
          else
            error(message('signal:dspopts:abstractspectrumwfreqpoints:set_freqpoints:invalidFreqPointsValue', 'FreqPoints', 'FreqPoints', validStrs{ 1 }, validStrs{ 2 }));
          end
        end
      end
      
    end
    
    
    function FrequencyVector = set_frequencyvector(this, FrequencyVector) %#ok
      %SET_FREQUENCYVECTOR   PreSet function for the 'FrequencyVector' property.

      % Welch uses segment length instead of input length.
      % auto = max(256,inputlength)
      
      validStrs = {'Auto'};
      FrequencyVector = this.FrequencyVector;
      
      if ~isnumeric(FrequencyVector)
        
        idx = [];
        for k=1:length(validStrs)
          if regexp(lower(validStrs{k}),['^',lower(FrequencyVector)],'once')
            idx=k;
          end
        end
        
        if isempty(idx)
          error(message('signal:dspopts:abstractspectrumwfreqpoints:set_frequencyvector:invalidFrequencyVectorValue', 'FrequencyVector', 'FrequencyVector', validStrs{ 1 }));
        end
      end
      
      % [EOF]
      
    end
    
    
    function nfft = set_nfft(this, nfft) %#ok
      %SET_NFFT   PreSet function for the 'nfft' property.

      % Welch uses segment length instead of input length.
      % nextpow2 = max(256,nextpow2(inputlength))
      % auto = max(256,inputlength)
      
      validStrs = {'Auto','Nextpow2'};
      nfft = this.NFFT;
      
      if isnumeric(nfft)
        if ~isscalar(nfft) || nfft<=0 || rem(nfft,1)
          error(message('signal:dspopts:abstractspectrumwfreqpoints:set_nfft:invalidNFFTValue', 'NFFT', 'NFFT', validStrs{ 1 }, validStrs{ 2 }));
        end
        
      else
        idx = [];
        for k=1:length(validStrs)
          if regexp(lower(validStrs{k}),['^',lower(nfft)],'once')
            idx=k;
          end
        end
        if isempty(idx)
          error(message('signal:dspopts:abstractspectrumwfreqpoints:set_nfft:invalidNFFTValue', 'NFFT', 'NFFT', validStrs{ 1 }, validStrs{ 2 }));
        end
      end
      
      % [EOF]
      
    end
    
    function varargout = set(obj,varargin)      
      [varargout{1:nargout}] = signal.internal.signalset(obj,varargin{:});           
    end
    
    function values = getAllowedStringValues(~,prop)
      % This function gives the the valid string values for object properties.
      
      switch prop
        case 'FreqPoints'
          values = {...
            'All'
            'User Defined'};
          
        otherwise
          values = {};
      end
      
    end   
        
  end  %% public methods
  
  
  methods (Static) %% static methods
    function this = loadobj(s)
      %LOADOBJ  Load this object.
      %   OUT = LOADOBJ(ARGS) <long description>

      this = feval(s.class);
      
      % Set FreqPoints first
      set(this, 'FreqPoints', s.FreqPoints);
      
      f = fieldnames(get(this));
      indx = strmatch('FreqPoints',f);
      f(indx) = [];
      
      for indx = 1:length(f)
        set(this, f{indx}, s.(f{indx}));
      end
 
    end
    
  end  %% static methods
  
end  % classdef

