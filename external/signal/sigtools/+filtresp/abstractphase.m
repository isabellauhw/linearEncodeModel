classdef abstractphase < filtresp.frequencyresp & hgsetget
  %filtresp.abstractphase class
  %   filtresp.abstractphase extends filtresp.frequencyresp.
  %
  %    filtresp.abstractphase properties:
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
  %    filtresp.abstractphase methods:
  %       getyparams -   Return the param tags that set off a y unzoom.
  %       objspecificdraw - Draw the response

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %PHASEUNITS Property is of type 'string'
    PhaseUnits = '';
  end
  
  
  methods
    function value = get.PhaseUnits(obj)
      value = getphaseunits(obj,obj.PhaseUnits);
    end
    function set.PhaseUnits(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','PhaseUnits')
      obj.PhaseUnits = setphaseunits(obj,value);
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function yparams = getyparams(this)
      %GETYPARAMS   Return the param tags that set off a y unzoom.
      yparams = {'phaseunits', 'freqmode'};      
    end
    
    function [m, xunits] = objspecificdraw(this)
      %OBJSPECIFICDRAW Draw the response

      h = get(this, 'Handles');
      h.axes = h.axes(end);
      
      % Get the data
      [Phi, W] = getphasedata(this);
      if isempty(Phi)
        m = 1;
        xunits = '';
        h.line = [];
      else
        [W, m, xunits] = normalize_w(this, W);
        
        % Convert the data to degrees if necessary.
        if strcmpi(get(this, 'PhaseUnits'), 'degrees')
          for indx = 1:length(Phi)
            Phi{indx} = Phi{indx}*180/pi;
          end
        end
        
        if ishandlefield(this,'line') && length(h.line) == size(Phi{1}, 2)
          for indx = 1:size(Phi{1}, 2)
            set(h.line(indx), 'XData',W{1}, 'YData',Phi{1}(:,indx));
          end
        else
          h.line = freqplotter(h.axes, W, Phi);
        end
        change = true;
        t      = [];
        thresh = eps^(1/4);
        for indx = 1:length(Phi)
          PhiTest = Phi{indx}(:);
          PhiTest(isnan(PhiTest)) = [];
          PhiTest(isinf(PhiTest)) = [];
          if isempty(PhiTest) || ...
              length(Phi{indx}) > 1 && max(std(PhiTest)) > thresh || ...
              ~isempty(t) && Phi{indx}(1)-t > thresh
            change = false;
            break;
          end
          t = Phi{indx}(1);
        end
        
        if change
          G1 = Phi{1};
          G1(isnan(G1)) = [];
          G1(isinf(G1)) = [];
          set(h.axes, 'YLim', [-1 1]+G1(1,1));
        end
        
      end
      
      hylbl = ylabel(h.axes, getylabel(this));
      
      if ~ishandlefield(this, 'phaseunitscsmenu')
        h.phaseunitscsmenu = contextmenu(getparameter(this, 'phaseunits'), hylbl);
      end
      
      set(this, 'Handles', h);
      phasespecificdraw(this);
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function allPrm = abstractphase_construct(hObj, varargin)
      %ABSTRACTPHASE_CONSTRUCT
      
      allPrm = hObj.frequencyresp_construct(varargin{:});
      
      createparameter(hObj, allPrm, 'Phase Units', 'phaseunits', {'Radians','Degrees'});
      
    end
        
    function phasespecificdraw(hObj)
      %PHASESPECIFICDRAW
      % NO OP
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function out = setphaseunits(hObj, out)

hPrm = getparameter(hObj, 'phaseunits');
if ~isempty(hPrm), setvalue(hPrm, out); end
end  % setphaseunits


% ---------------------------------------------------------------
function out = getphaseunits(hObj, out)

hPrm = getparameter(hObj, 'phaseunits');
if ~isempty(hPrm)
  out = get(hPrm, 'Value');
else
  out = '';
end
end  % getphaseunits


% [EOF]
