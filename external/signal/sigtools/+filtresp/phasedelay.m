classdef phasedelay < filtresp.abstractphase
  %filtresp.phasedelay class
  %   filtresp.phasedelay extends filtresp.abstractphase.
  %
  %    filtresp.phasedelay properties:
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
  %       FrequencyVector - Property is of type 'double_vector user-defined'
  %       DisplayMask - Property is of type 'on/off'
  %       PhaseUnits - Property is of type 'string'
  %
  %    filtresp.phasedelay methods:
  %       getphasedata - Returns the phase data
  %       getylabel - Returns the string to be used on the Y Label
  %       phasedelay_construct - PHASERESP_CONSTRUCT Construct a phaseresp object

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  
  methods  % constructor block
    function h = phasedelay(varargin)
      %PHASEDELAY Construct a phasedelay object

      h.phasedelay_construct(varargin{:});
            
    end  % phasedelay
    
  end  % constructor block
  
  methods  %% public methods
    function [Phi, W] = getphasedata(this)
      %GETPHASEDATA Returns the phase data

      Hd   = this.Filters;
      
      if isempty(Hd)
        Phi = {};
        W   = {};
      else
        opts = getoptions(this);
        
        optsstruct.showref  = showref(this.FilterUtils);
        optsstruct.showpoly = showpoly(this.FilterUtils);
        optsstruct.sosview  = this.SOSViewOpts;
        optsstruct.normalizedfreq = this.NormalizedFrequency;
        
        if strcmp(this.NormalizedFrequency,'on')
            optsstruct.NormalizedFrequency = true;
        else
            optsstruct.NormalizedFrequency = false;
        end
        
        [Phi,W] = phasedelay(Hd, opts{:}, optsstruct);
        
      end
      
    end
    
    
    function str = getylabel(this)
      %GETYLABEL Returns the string to be used on the Y Label
 
      units = lower(this.PhaseUnits);
      
      if strcmpi(this.NormalizedFrequency, 'On')
        if strcmpi(units, 'degrees')
          units = getString(message('signal:sigtools:filtresp:degreesRadiansPerSample'));
          %         units = '{\times\pi}/180 samples';
        else % must be radians
          units = getString(message('signal:sigtools:filtresp:Samples'));
        end
      else
        units = sprintf('%s/Hz', units);
      end
      
      str = getString(message('signal:sigtools:filtresp:PhaseDelay', units));
      
    end
    
    function allPrm = phasedelay_construct(hObj, varargin)
      %PHASERESP_CONSTRUCT Construct a phaseresp object

      allPrm = hObj.abstractphase_construct(varargin{:});
      
      hObj.Name = getString(message('signal:sigtools:filtresp:PhaseDelay1'));
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function s = legendstring(hObj)
      %LEGENDSTRING

      s = getString(message('signal:sigtools:filtresp:PhaseDelay1'));
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

