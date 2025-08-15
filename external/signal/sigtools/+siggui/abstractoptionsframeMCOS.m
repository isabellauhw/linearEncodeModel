classdef (Abstract) abstractoptionsframeMCOS < siggui.sigcontainerMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %siggui.abstractoptionsframe class
  %   siggui.abstractoptionsframe extends siggui.sigcontainer.
  %
  %    siggui.abstractoptionsframe properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Name - Property is of type 'string'
  %
  %    siggui.abstractoptionsframe methods:
  %       editadditionalparameters - Allows access to the additional parameters
  %       getcshstring -  Returns the string for context sensitive help
  %       getstate - Get the state of the object
  %       renderabstractframe -  Render the abstract frame
  %       thisrender -  Renders the abstract frame with the default values.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %NAME Property is of type 'string'
    Name = 'Options';
  end
  
  
  methods
    function set.Name(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Name')
      obj.Name = value;
    end
    
    %----------------------------------------------------------------------
    function editadditionalparameters(h)
      %EDITADDITIONALPARAMETERS Allows access to the additional parameters
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      % Find all properties with a description
      [props, descs] = getbuttonprops(h);
      
      % Get default answers
      answers = get(h, props);
      if ~isa(answers, 'cell')
        answers = {answers};
      end
      
      % Build an input dialog out of the additional parameters
      newvals = inputdlg(getTranslatedStringcell('signal:sigtools:siggui', descs) ,...
        getString(message('signal:sigtools:siggui:SetAdditionalParameters')), ...
        1, answers);
      
      % If newvals is empty, the user pressed cancel, don't change value
      if ~isempty(newvals)
        
        if ~iscell(props)
          props = {props};
        end
        
        c = {props{:}; newvals{:}};
        set(h, c{:});
        
        % Send a modified event
        notify(h, 'UserModifiedSpecs');
      end
    end
    
    %----------------------------------------------------------------------
    function csh_str = getcshstring(hObj)
      %GETCSHSTRING  Returns the string for context sensitive help
      
      %   Author(s): Z. Mecklai
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      SigguiClass = class(hObj);
      
      BeginIndx = strfind(SigguiClass, '.');
      EndIndx = strfind(SigguiClass, 'opt');
      
      ObjClass = SigguiClass(BeginIndx + 1 : EndIndx - 1);
      
      csh_str = ['fdatool_',ObjClass,'_options_frame'];
      
    end
    
    %----------------------------------------------------------------------
    function s = getstate(h)
      %GETSTATE Get the state of the object
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      s = siggui_getstate(h);
      s = rmfield(s, 'Name');
    end
    
    %----------------------------------------------------------------------
    function renderabstractframe(this, varargin)
      %RENDERABSTRACTFRAME  Render the abstract frame
      
      %   Author(s): Z. Mecklai
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      pos  = parserenderinputs(this, varargin{:});
      
      % Set/get defaults
      if isempty(pos)
        sz = gui_sizes(this);
        pos = sz.pixf.*[217 55 178 133-(sz.vffs/sz.pixf)];
      end
      
      framewlabel(this, pos, getTranslatedString('signal:sigtools:siggui',this.Name));
      
      % Check for existence of additional parameters
      if ~isempty(getbuttonprops(this))
        renderactionbtn(this, pos, getString(message('signal:sigtools:siggui:Moreoptions')), ...
          'editadditionalparameters');
      end
    end
    
    %----------------------------------------------------------------------
    function thisrender(this, varargin)
      %THISRENDER  Renders the abstract frame with the default values.
      %   Since the abstractOptionsFrame is a superclass, it's render method
      %   must be callable from subclasses hence all the code necessary to
      %   actually render the frame is moved to another method
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      pos = parserenderinputs(this, varargin{:});
      
      hFig = get(this, 'FigureHandle');
      
      % Render the frame in the specified position.
      renderabstractframe(this, hFig, pos);
      
      pos = getpixelpos(this, 'framewlabel', 1);
      
      % Get the properties and labels to render from the subclasses.
      [props, lbls] = getrenderprops(this);
      
      sz     = gui_sizes(this);
      nprops = length(props);
      h      = sz.uh*nprops+sz.uuvs*(nprops+1);
      pos    = [pos(1) pos(2)+pos(4)-h pos(3) h];
      
      rendercontrols(this, pos, props, lbls)
      
      cshelpcontextmenu(this, getcshstring(this));
      
      objspecific_render(this);
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    
    function [props, descs] = abstract_getbuttonprops(h)
      %ABSTRACT_GETBUTTONPROPS
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      mobj = metaclass(h);
      
      p = findobj(mobj.PropertyList, '-not', 'Description', '');
      
      if isempty(p)
        props = {};
        descs = {};
      else
        props = get(p, 'Name');
        descs = get(p, 'Description');
      end
      
    end
    
    %----------------------------------------------------------------------
    function [props, descs] = getbuttonprops(h)
      %GETBUTTONPROPS
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      [props, descs] = abstract_getbuttonprops(h);
      
    end
    
    %----------------------------------------------------------------------
    function objspecific_render(hObj)
      %OBJSPECIFIC_RENDER
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % NO OP
    end
    
    
  end  %% possibly private or hidden
  
end  % classdef

