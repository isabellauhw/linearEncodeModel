classdef (Abstract) abstractanalysis < siggui.sigcontainerMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %sigresp.abstractanalysis class
  %   sigresp.abstractanalysis extends siggui.sigcontainer.
  %
  %    sigresp.abstractanalysis properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %
  %    sigresp.abstractanalysis methods:
  %       abstract_getparameter - Returns an analysis parameter give its tag
  %       addparameter - Add a parameter to the object
  %       attachprmdlglistener - Allow subclasses to attach listeners to the parameterdlg.
  %       createparameter - Creates a parameter in the object if it does not already exist
  %       disableparameter - Disable the parameter, returns true if the parameter is disabled.
  %       enableparameter - Enable the parameter, returns true if the parameter is enabled.
  %       getname - Get the name of the analysis
  %       getparameter - Returns the specified parameter
  %       gettoolname -   Get the toolname.
  %       getunits -   Get the units.
  %       replaceparameter - Allows subclasses to change a parameter object.
  %       setupparameterdlg - Setup the parameter dlg for this filtresp
  %       super_construct - Check the inputs
  
  %   Copyright 2015-2017 The MathWorks, Inc.

  
  properties (AbortSet, SetObservable, GetObservable)
    %FASTUPDATE Property is of type 'on/off'
    FastUpdate = 'off'
    %NAME Property is of type 'string'
    Name = '';
  end
  
  properties (AbortSet, SetObservable, GetObservable, Hidden)
    %STATICPARAMETERS Property is of type 'string vector' (hidden)
    StaticParameters
    %DISABLEDPARAMETERS Property is of type 'string vector' (hidden)
    DisabledParameters = {};
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %PARAMETERS Property is of type 'handle vector'
    Parameters = [];
  end
  
  
  events
    DisabledListChanged
    NewPlot
  end  % events
  
  methods
    function set.FastUpdate(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','FastUpdate');
      obj.FastUpdate = value;
    end
    
    function set.Parameters(obj,value)
      % DataType = 'handle vector'
      validateattributes(value,{'handle'}, {'vector'},'','Parameters');
      obj.Parameters = value;
    end
    
    function set.StaticParameters(obj,value)
      % DataType = 'string vector'
      % no cell string checks yet'
      obj.StaticParameters = value;
    end
    
    function set.DisabledParameters(obj,value)
      % DataType = 'string vector'
      % no cell string checks yet'
      obj.DisabledParameters = value;
    end
    
    function value = get.Name(obj)
      value = getname(obj,obj.Name);
    end
    function set.Name(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Name')
      obj.Name = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function hPrm = abstract_getparameter(hObj, tag)
      %ABSTRACT_GETPARAMETER Returns an analysis parameter give its tag

      narginchk(1,2);
      
      hPrm = hObj.Parameters;
      
      if nargin > 1 && ~isempty(hPrm)
        if ~strcmpi(tag, '-all')
          hPrm = findobj(hPrm, 'Tag', tag);
        end
      end
      
    end
    
    
    function addparameter(hObj, hPrm)
      %ADDPARAMETER Add a parameter to the object
 
      hPrms = hObj.Parameters;
      for k = 1:length(hPrm)
        
        % Make sure that the parameter doesn't already exist.
        if isempty(getparameter(hObj, hPrm(k).Tag))
          if isempty(hPrms)
            hPrms = hPrm(k);
          else
            hPrms = [hPrms; hPrm(k)];
          end
        end
      end
      set(hObj, 'Parameters', hPrms);
      
      
    end
    
    
    function attachprmdlglistener(hObj, hDlg)
      %ATTACHPRMDLGLISTENER Allow subclasses to attach listeners to the parameterdlg.

      % NO OP
      
    end
    
    
    function createparameter(hObj, allPrm, name, tag, varargin)
      %CREATEPARAMETER Creates a parameter in the object if it does not already exist
 
      narginchk(5,6);
      
      % Only create a new parameter if we do not already have it.
      if isempty(getparameter(hObj, tag))
        
        hPrm = [];
        
        % If parameters were passed in, search the vector for the requested
        % parameter.
        if ~isempty(allPrm)
          hPrm = findobj(allPrm, 'tag', tag);
          if length(hPrm) > 1, hPrm = hPrm(1); end
        end
        
        % If we can't find the parameter
        if isempty(hPrm)
          hPrm = sigdatatypes.parameter(name, tag, varargin{:});
        end
        
        addparameter(hObj, hPrm);
      end
      
    end
    
    
    function b = disableparameter(hObj, tag)
      %DISABLEPARAMETER Disable the parameter, returns true if the parameter is disabled.

      b = false;
      
      list = get(hObj, 'DisabledParameters');
      
      if ~any(strcmpi(tag, list))
        
        list = {list{:}, tag};
        set(hObj, 'DisabledParameters', list);
        
        % Build up the custom event data so they listener can be more efficient.
        ed.type = 'Disabled';
        ed.tag  = tag;
        
        notify(hObj, 'DisabledListChanged', ...
          sigdatatypes.sigeventdataMCOS(hObj, 'DisabledListChanged', ed));
        b = true;
      end
      
    end
    
    
    function b = enableparameter(hObj, tag)
      %ENABLEPARAMETER Enable the parameter, returns true if the parameter is enabled.

      b = false;

      list = get(hObj, 'DisabledParameters');
      
      if ~isempty(list)
        indx = find(strcmpi(tag, list));
        
        if ~isempty(indx)
          
          list(indx) = [];
          
          set(hObj, 'DisabledParameters', list);
          ed.type = 'Enabled';
          ed.tag  = tag;
          notify(hObj, 'DisabledListChanged', ...
            sigdatatypes.sigeventdataMCOS(hObj, 'DisabledListChanged', ed));
          b = true;
        end
      end
      
    end
    
    
    function out = getname(hObj, out)
      %GETNAME Get the name of the analysis

    end
    
    function hPrm = getparameter(hObj, varargin)
      %GETPARAMETER Returns the specified parameter

      hPrm = abstract_getparameter(hObj, varargin{:});
      
    end
    
    
    function toolname = gettoolname(this)
      %GETTOOLNAME   Get the toolname.

      toolname = 'fvtool';
      
    end
    
    
    function units = getunits(this)
      %GETUNITS   Get the units.

      units = '';
      
    end
    
    function replaceparameter(hObj, oldtag, varargin)
      %REPLACEPARAMETER Allows subclasses to change a parameter object.

      narginchk(5, 7);
      
      oldPrm = getparameter(hObj, oldtag);
      allPrm = get(hObj, 'Parameters');
      
      set(hObj, 'Parameters', setdiff(allPrm, oldPrm));
      
      createparameter(hObj, varargin{:});
      
      
    end
    
    
    function varargout = setupparameterdlg(this, varargin)
      %SETUPPARAMETERDLG Setup the parameter dlg for this filtresp
 
      narginchk(1,2);
      
      hPrm = getparameter(this);
      hDlg = getcomponent(this, '-class', 'siggui.parameterdlgMCOS');
      
      if nargin > 1
        if isempty(hDlg)
          hDlg = varargin{1};
          addcomponent(this, hDlg);
        else
          hDlg = varargin{1};
        end
        
        set(hDlg, 'Parameters', hPrm);
      elseif isempty(hDlg)
        hDlg = siggui.parameterdlgMCOS(hPrm);
        set(hDlg, 'Tool', gettoolname(this));
        addcomponent(this, hDlg);
      end
      
      % Set the figure title and frame label.
      set(hDlg, 'Name', getString(message('signal:sigtools:siggui:AnalysisParams')));
      set(hDlg, 'Label', get(this, 'Name'));
      
      attachprmdlglistener(this, hDlg);
      
      lclparameter_listener(this, []);
      
      if ~isrendered(hDlg)
        render(hDlg);
        hDlg.centerdlgonfig(this);
        set(hDlg, 'Visible','On');
        figure(hDlg.FigureHandle);
      end
      
      l(1) = event.proplistener(this, this.findprop('DisabledParameters'), 'PostSet', @(s,e)lclparameter_listener(this,e));
      l(2) = event.proplistener(this, this.findprop('StaticParameters'),   'PostSet', @(s,e)lclparameter_listener(this,e));
      
      setappdata(hDlg.FigureHandle, 'filtresp_listener', l);
      
      if nargout
        varargout = {hDlg};
      end
      
    end
    
    
    function hPrm = super_construct(hObj, varargin)
      %SUPER_CONSTRUCT Check the inputs

      % We return the parameters so subclasses can determine which ones they want
      % to keep.  They only keep the ones they use, not all that are passed in.
      hPrm = [];
      
      for i = 1:length(varargin)
        
        % Look for a parameter object in the input
        if isa(varargin{i}, 'sigdatatypes.parameter')
          if isempty(hPrm)
            hPrm = varargin{i};
          else
            hPrm = [hPrm; varargin{i}];
          end
        end
      end
      
      % Make sure there are no copies of the same parameter.
      hPrm = unique(hPrm);
      
    end
    
    
  end  %% public methods
  
  
  methods (Hidden)
    function formataxislimits(this)
      %FORMATAXISLIMITS

      % This is a NO OP at the most abstract lvl so that we can call the method
      % without having to check if it is valid.
      
    end
    
    %----------------------------------------------------------------------
    function filtrespShowUpdate(this,limits)
      
      deletehandle(this, 'Legend');
      
      if nargin < 2
        limits = 'both';
      end
      
      captureanddraw(this, limits);
      
      % Make sure that we put up the legend after so that it is on top of the
      % plotting axes.
      updatelegend(this);

    end
   
    %----------------------------------------------------------------------
    function filtrespFsUpdate(this, ~, ~)
      
      sendstatus(this, getString(message('signal:sigtools:filtresp:ComputingResponse')));
      
      for i = 1:length(this.WhenRenderedListeners)
        this.WhenRenderedListeners(i).Enabled = false;
      end
      
      this.NormalizedFrequency = 'off';
      
      for i = 1:length(this.WhenRenderedListeners)
        this.WhenRenderedListeners(i).Enabled = true;
      end
      
      captureanddraw(this, 'y');
      
      sendstatus(this, getString(message('signal:sigtools:filtresp:ComputingResponseDone')));
      
    end
    
    %----------------------------------------------------------------------
    function filtrespFiltUpdate(this, ~, ~)     
      
      if isprop(this,'Handles')
        attachfilterlisteners(this);
        deletehandle(this, 'Legend');
        captureanddraw(this, 'none');
        updatelegend(this);
      end
      
    end
             
  end 
  
end  % classdef


% ---------------------------------------------------------------------
function lclparameter_listener(this, ~)

hDlg = getcomponent(this, '-class', 'siggui.parameterdlgMCOS');

hDlg.DisabledParameters = this.DisabledParameters;
hDlg.StaticParameters = this.StaticParameters;

end

