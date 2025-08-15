classdef (CaseInsensitiveProperties=true, TruncatedProperties=true,Abstract) abstractdatawfsMCOS < dspdata.abstractdataMCOS
  %dspdata.abstractdatawfs class
  %   dspdata.abstractdatawfs extends dspdata.abstractdata.
  %
  %    dspdata.abstractdatawfs properties:
  %       Name - Property is of type 'String' (read only)
  %       Data - Property is of type 'mxArray' (read only)
  %       NormalizedFrequency - Property is of type 'bool'
  %       Fs - Property is of type 'mxArray' (read only)
  %
  %    dspdata.abstractdatawfs methods:
  %       getfs -   Return the Sampling Frequency, Fs.
  %       getnormalizedfrequency -   PreGet function for the 'normalizedfrequency' property.
  %       normalizefreq -   Normalize/un-normalize the frequency of the data object.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %PRIVNORMALIZEDFREQUENCY Property is of type 'bool'
    privNormalizedFrequency = true;
    %PRIVFS Property is of type 'posdouble user-defined'
    privFs = 1;
  end
  
  properties (SetAccess=protected, Transient, AbortSet, SetObservable, GetObservable)
    %FS Property is of type 'mxArray' (read only)
    Fs = [];
  end
  
  properties (Transient, SetObservable, GetObservable)
    %NORMALIZEDFREQUENCY Property is of type 'bool'
    NormalizedFrequency
  end
  
  
  methods
    function value = get.NormalizedFrequency(obj)
      value = getnormalizedfrequency(obj,obj.NormalizedFrequency);
    end
    function set.NormalizedFrequency(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'logical'}, {'scalar'},'','NormalizedFrequency')
      obj.NormalizedFrequency = setnormalizedfrequency(obj,value);
    end
    
    function set.privNormalizedFrequency(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'logical'}, {'scalar'},'','privNormalizedFrequency')
      obj.privNormalizedFrequency = value;
    end
    
    function value = get.Fs(obj)
      value = get_fs(obj,obj.Fs);
    end
    function set.Fs(obj,value)
      obj.Fs = set_fs(obj,value);
    end
    
    function set.privFs(obj,value)
      % User-defined DataType = 'posdouble user-defined'
      obj.privFs = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function Fs = getfs(this)
      %GETFS   Return the Sampling Frequency, Fs.

      Fs = this.privFs;
      
    end
    
    
    function normfreq = getnormalizedfrequency(this, normfreq)
      %GETNORMALIZEDFREQUENCY   PreGet function for the 'normalizedfrequency' property.

      normfreq = this.privNormalizedFrequency;
      
    end
    
    
    function normalizefreq(this,normFlag, Fs)
      %NORMALIZEFREQ   Normalize/un-normalize the frequency of the data object.

      % This method doesn't do anything too interesting, but its overloaded by
      % its subclasses.
      if nargin > 1
        this.privNormalizedFrequency = normFlag;
        if nargin > 2
          this.Fs = Fs;
        end
      end
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function privfs = getprivfs(this, privfs)
      %GETPRIVFS   Gets the value of the private property privFs.
 
      privfs = this.privFs;      
    end
        
    function setprivfs(this, privfs)
      %SETPRIVFS   Sets the private property setprivFs.

      this.privFs = privfs;
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function normfreq = setnormalizedfrequency(this,normfreq)
%SETNORMALIZEDFREQUENCY   Set function for the NormalizedFrequency property.

error(message('signal:dspdata:abstractdatawfs:schema:settingRangePropertyNotAllowed', 'NormalizedFrequency', 'normalizefreq', 'help dspdata/normalizefreq'));
end  % setnormalizedfrequency


%--------------------------------------------------------------------------
function Fs = set_fs(this,Fs)
%SET_FS Set function for the Fs property.

if this.NormalizedFrequency
  error(message('signal:dspdata:abstractdatawfs:schema:settingFreqPropertyNotAllowed', 'Fs', 'NormalizedFrequency', 'normalizefreq(h,false,Fs)'));
end

if ~isempty(Fs) & (~isnumeric(Fs) | ~isscalar(Fs) | Fs == 0)
  error(message('signal:dspdata:abstractdatawfs:schema:invalidSamplingFrequency', 'Fs'));
end

setprivfs(this,Fs);

% Make Fs empty to not duplicate storage
Fs = [];
end  % set_fs


%--------------------------------------------------------------------------
function Fs = get_fs(this,Fs)
%GET_FS   Return the value of the Fs property.

if this.NormalizedFrequency
  Fs = 'Normalized';
else
  Fs = getprivfs(this);
end
end  % get_fs


% [EOF]
