classdef phasez < filtresp.abstractphase
  %filtresp.phasez class
  %   filtresp.phasez extends filtresp.abstractphase.
  %
  %    filtresp.phasez properties:
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
  %       PhaseDisplay - Property is of type 'string'
  %
  %    filtresp.phasez methods:
  %       getname - Get the name of the magnitude response
  %       getphasedata - Returns the phase data
  %       getylabel - Returns the string to be used on the Y Label
  %       getyparams -   Return the param tags that set off a y unzoom.
  %       phasez_construct - PHASEP_CONSTRUCT Construct a phaseresp object

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %PHASEDISPLAY Property is of type 'string'
    PhaseDisplay = '';
  end
  
  
  methods  % constructor block
    function h = phasez(varargin)
      %PHASEZ Construct a phaseresp object

      h.phasez_construct(varargin{:});
            
    end  % phasez
    
  end  % constructor block
  
  methods
    function value = get.PhaseDisplay(obj)
      value = getphase(obj,obj.PhaseDisplay);
    end
    function set.PhaseDisplay(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','PhaseDisplay')
      obj.PhaseDisplay = setphase(obj,value);
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function out = getname(hObj, out)
      %GETNAME Get the name of the magnitude response

      %ADDCATALOG Not sure if safe to translate
      phase = hObj.PhaseDisplay;
      
      out = [phase ' Response'];
      out = getTranslatedString('signal:sigtools:filtresp',out);
    end
    
    
    function [Phi, W] = getphasedata(this)
      %GETPHASEDATA Returns the phase data

      Hd   = this.Filters;
      opts = getoptions(this);
      
      if isempty(Hd)
        Phi = {};
        W   = {};
      else
        
        optsstruct.showref  = showref(this.FilterUtils);
        optsstruct.showpoly = showpoly(this.FilterUtils);
        optsstruct.sosview  = this.SOSViewOpts;
        
        if strcmp(this.NormalizedFrequency,'on')
            optsstruct.NormalizedFrequency = true;
        else
            optsstruct.NormalizedFrequency = false;
        end

        if strcmpi(this.PhaseDisplay, 'Phase')
          [Phi,W] = phasez(Hd, opts{:}, optsstruct);
        else
          [H,W,Phi] = zerophase(Hd, opts{:}, optsstruct);
        end
      end
      
    end
    
    
    function str = getylabel(this)
      %GETYLABEL Returns the string to be used on the Y Label

      str = sprintf('%s (%s)', ...
        getTranslatedString('signal:sigtools:filtresp',this.PhaseDisplay), ...
        getTranslatedString('signal:sigtools:filtresp',lower(this.PhaseUnits)));
      
      
    end
    
    function yparams = getyparams(this)
      %GETYPARAMS   Return the param tags that set off a y unzoom.

      yparams = {'phaseunits', 'phase'};
            
    end    
    
    function allPrm = phasez_construct(hObj, varargin)
      %PHASEP_CONSTRUCT Construct a phaseresp object

      hObj.Name = 'Phase Response';
      
      allPrm = hObj.abstractphase_construct(varargin{:});
      
      createparameter(hObj, allPrm, 'Phase Display', 'phase', {'Phase', 'Continuous Phase'});
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function s = legendstring(hObj)
      %LEGENDSTRING

      s = getString(message('signal:sigtools:filtresp:Phase'));
      
    end
    
    function phasespecificdraw(hObj)
      %PHASESPECIFICDRAW

      h = hObj.Handles;
      
      hylbl = get(h.axes, 'YLabel');
      
      if ~ishandlefield(hObj, 'phasecsmenu')
        h.phasecsmenu = contextmenu(getparameter(hObj, 'phase'), hylbl);
      end
      
      hObj.Handles = h;
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function out = setphase(hObj, out)

hPrm = getparameter(hObj, 'phase');
if ~isempty(hPrm), setvalue(hPrm, out); end
end  % setphase


% ---------------------------------------------------------------
function out = getphase(hObj, out)

hPrm = getparameter(hObj, 'phase');
if ~isempty(hPrm)
  out = get(hPrm, 'Value');
else
  out = '';
end
end  % getphase


% [EOF]
