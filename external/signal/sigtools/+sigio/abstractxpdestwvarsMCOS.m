classdef (Abstract) abstractxpdestwvarsMCOS < sigio.abstractxpdestinationMCOS & dynamicprops & sigio.dyproputil & matlab.mixin.SetGet & matlab.mixin.Copyable
  %sigio.abstractxpdestwvars class
  %   sigio.abstractxpdestwvars extends sigio.abstractxpdestination.
  %
  %    sigio.abstractxpdestwvars properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Data - Property is of type 'mxArray'
  %       Toolbox - Property is of type 'string'
  %       DefaultLabels - Property is of type 'mxArray'
  %       VariableLabels - Property is of type 'mxArray'
  %       VariableNames - Property is of type 'mxArray'
  %
  %    sigio.abstractxpdestwvars methods:
  %       abstract_getfrheight - Get frame height.
  %       abstractxdwvars_thisrender - Render the destination options frame.
  %       abstractxpdestwvars_construct -   Perform the common construct.
  %       addexportasprop - Add an 'ExportAs' dynamic property.
  %       formatexportdata - Utility used to call exportdata methods.
  %       formatnames -   Format the names using the database.
  %       getdefaultlabels -   Get the DefaultLabels from privDefaultLabels
  %       getfrheight - Get frame height.
  %       getnamedatabase -   Returns the variable names database
  %       getvariablelabels - GetFunction for the VariableLabels property.
  %       getvariablenames - GetFunction for the VariableNames property.
  %       newdata - Update object based on new data to be exported.
  %       parse4obj - Utility used when exporting objects.
  %       parse4vec - Utility used when exporting vectors.
  %       render_exportas - Render a frame with an "Export As" popup.
  %       savenames -   Save the names in the database.
  %       setvariablelabels - SetFunction for the VariableLabels property.
  %       setvariablenames - SetFunction for the VariableNames property.
  %       thisrender - Render the destination options frame.
  %       updateexportaspopup - Remove export as 'objects' or 'System objects' if not
  %       xp_gui_sizes - SIGIO.ABSTRACTDESWVARS GUI Sizes.

%   Copyright 2014-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %DEFAULTLABELS Property is of type 'mxArray'
    DefaultLabels = {};
    %VARIABLENAMES Property is of type 'mxArray'
    VariableNames = [];
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %PRIVDEFAULTLABELS Property is of type 'mxArray'
    privDefaultLabels = [];
    %VALUESLISTENER Property i s of type 'handle.listener'
    ValuesListener = [];
    %PREVIOUSLABELSANDNAMES Property is of type 'mxArray'
    PreviousLabelsAndNames = [];
  end
  
  properties (SetObservable, GetObservable)
    %VARIABLELABELS Property is of type 'mxArray'
    VariableLabels = [];
  end
  
  
  events
    ForceResize
  end  % events
  
  methods
    function value = get.DefaultLabels(obj)
      value = getdefaultlabels(obj,obj.DefaultLabels);
    end
    function set.DefaultLabels(obj,value)
      obj.DefaultLabels = setdefaultlabels(obj,value);
    end
    
    function set.privDefaultLabels(obj,value)
      obj.privDefaultLabels = value;
    end
    
    function value = get.VariableLabels(obj)
      value = getvariablelabels(obj,obj.VariableLabels);
    end
    function set.VariableLabels(obj,value)
      obj.VariableLabels = setvariablelabels(obj,value);
    end
    
    function value = get.VariableNames(obj)
      value = getvariablenames(obj,obj.VariableNames);
    end
    function set.VariableNames(obj,value)
      obj.VariableNames = setvariablenames(obj,value);
    end
    
    function set.ValuesListener(obj,value)
      % DataType = 'handle.listener'
      validateattributes(value,{'event.listener'}, {'scalar'},'','ValuesListener')
      obj.ValuesListener = value;
    end
    
    function set.PreviousLabelsAndNames(obj,value)
      obj.PreviousLabelsAndNames = value;
    end
    
    function hght = abstract_getfrheight(h)
      %ABSTRACT_GETFRHEIGHT Get frame height.
      
      sz = gui_sizes(h);
      numVars = get(getcomponent(h, '-isa', 'siggui.labelsandvaluesMCOS'), 'Maximum');
      
      % Return a height for the destination options frame (since this frame
      % contains a variable number of uis)
      hght = (sz.uuvs+sz.uh)*numVars + 2*sz.vfus;
      
    end
    
    function abstractxdwvars_thisrender(this, pos)
      %ABSTRACTXDWVARS_THISRENDER Render the destination options frame.
      
      if nargin < 2 , pos =[]; end
      
      bgc  = get(0,'DefaultUicontrolBackgroundColor');
      visstate = get(this, 'Visible');
      
      % Render frame
      hFig = get(this, 'FigureHandle');
      
      if isempty(pos)
        sz = xp_gui_sizes(this);
        pos = sz.VarNamesPos;
      end
      
      h = get(this, 'Handles');
      
      if ishandlefield(this, 'framewlabel')
        framewlabel(h.framewlabel, pos);
      else
        h.framewlabel = framewlabel(hFig, pos, ...
          getString(message('signal:sigtools:sigio:VariableNames')), ...
          'varnames', bgc, visstate);
        
        % Store the HG object handles
        set(this, 'Handles', h)
      end
      
      
    end
    
    function abstractxpdestwvars_construct(this)
      %ABSTRACTXPDESTWVARS_CONSTRUCT   Perform the common construct.
            
      % Create an ExportAs property (if defined in the info struct)
      addexportasprop(this);
      
      % Return the labels and names so that we can create a
      % siggui.labelsandvalues object with the correct number of values.
      [lbls,names] = parse4vec(this);
      
      hlnv = siggui.labelsandvaluesMCOS('Maximum',length(lbls));
      
      l = event.proplistener(hlnv, hlnv.findprop('Values'), 'PostSet', @(s,e)values_listener(this));      
      this.ValuesListener = l;
      
      addcomponent(this, hlnv);
      
      this.VariableLabels = lbls;
      this.VariableNames = names;
      
    end
    
    
    function addexportasprop(h)
      %ADDEXPORTASPROP Add an 'ExportAs' dynamic property.
            
      info = exportinfo(h.Data);
      
      if isfield(info, 'exportas')
        addxpasdynprop(h,info);
        
        if isfield(info,'exportas')
          enab = 'on';
        else
          enab = 'off';
        end
        
        % Turn on/off the 'ExportAs' dynamic property
        % enabdynprop(h, 'ExportAs', getexportasinfo(h));
        enabdynprop(h, 'ExportAs', enab);
      end
      
    end
    
    
    function data2xp= formatexportdata(h)
      %FORMATEXPORTDATA Utility used to call exportdata methods.
            
      % Includes vectors and handle objects
      data2xp = {};
      data = cell(h.Data);
      
      % If Dynamic Property 'ExportAs' exists, can export either objects or arrays
      if isprop(h, 'ExportAs') && isdynpropenab(h,'ExportAs')
        if any(strcmpi({'Objects','System Objects'},get(h,'ExportAs')))
          data2xp = data;
          for indx = 1:length(data2xp)
            data2xp{indx} = copy(data2xp{indx});
            % Convert filters to System objects if it has been requested
            if strcmpi(get(h,'ExportAs'),'System Objects')
              data2xp{indx} = sysobj(data2xp{indx});
            end
          end
        else
          % Call the object specific exporting methods
          for n = 1:length(data)
            newdata  = exportdata(data{n});
            data2xp =  {data2xp{:},newdata{:}}; %#ok<CCAT>
          end
        end
      else
        % For the case of exporting arrays, call the built-in exporting method.
        data2xp = exportdata([data{:}]);
      end
      
      
    end
    
    function varargout = formatnames(this, labels, names)
      %FORMATNAMES   Format the names using the database.
      
      if nargin < 2
        labels = this.VariableLabels;
      end
      if nargin < 3
        names  = this.VariableNames;
      end
      
      if isempty(labels), labels = ''; end
      
      oldlbls = this.PreviousLabelsAndNames;
      
      % Replace spaces with _ and remove non "word" characters.
      labels = strrep(labels, ' ', '_');
      for indx = 1:length(labels)
        jndx = regexp(labels{indx}, '\w');
        labels{indx} = labels{indx}(jndx);
        if isprop(this, 'ExportAs') && isdynpropenab(this, 'ExportAs')
          labels{indx} = [strrep(this.ExportAs, ' ', '') labels{indx}];
        end
      end
      
      if isempty(oldlbls)
        oldlbls = cell2struct(names(:)', labels(:)', 2);
      else
        for indx = 1:length(labels)
          if isfield(oldlbls, labels{indx})
            names{indx} = oldlbls.(labels{indx});
          else
            oldlbls.(labels{indx}) = names{indx};
          end
        end
      end
      
      this.PreviousLabelsAndNames = oldlbls;
      
      if nargout
        varargout = {names};
      else
        this.VariableNames = names;
      end
      
      
    end
    
    
    function deflabels = getdefaultlabels(this, deflabels) %#ok<*INUSD>
      %GETDEFAULTLABELS   Get the DefaultLabels from privDefaultLabels
            
      deflabels = this.privDefaultLabels;
      
      
    end
        
    function hght = getfrheight(h)
      %GETFRHEIGHT Get frame height.
      
      hght = abstract_getfrheight(h);
      
    end
    
    function db = getnamedatabase(this)
      %GETNAMEDATABASE   Returns the variable names database
      
       db = this.PreviousLabelsAndNames;      
      
    end
        
    function P = getvariablelabels(h,P) %#ok<*INUSL>
      %GETVARIABLELABELS GetFunction for the VariableLabels property.
      
      % Just return what is stored.  The labels and values object might contain a
      % translated version of the labels.
      
      P = P(:);
      
      % lvh = getcomponent(h, '-class', 'siggui.labelsandvalues');
      % P = get(lvh,'Labels');
      %
      % for indx = 1:length(P)
      %     P{indx}(end) = [];
      % end
      
    end
    
    function P = getvariablenames(h,dummy)
      %GETVARIABLENAMES GetFunction for the VariableNames property.
      
      lvh = getcomponent(h, '-class', 'siggui.labelsandvaluesMCOS');
      P = get(lvh,'Values');
      
    end
    
    
    function newdata(this)
      %NEWDATA Update object based on new data to be exported.
      
      % If it exists, delete the contained object (this means that we are
      % changing the data after creating the export object)
      hlnv = getcomponent(this, 'siggui.labelsandvaluesMCOS');
      
      if ~isempty(hlnv)
        
        savenames(this);
        
        delete(hlnv);
        
        if isprop(this, 'ExportAs')
          info = exportinfo(this.Data);
          if isfield(info, 'exportas')
            enab = 'on';
          else
            enab = 'off';
          end
          enabdynprop(this, 'ExportAs', enab);
        else
          addexportasprop(this);
        end
        
        % Return the labels and names so that we can create a
        % siggui.labelsandvalues object with the correct number of values.
        
        if isprop(this, 'ExportAs') && isdynpropenab(this,'ExportAs')
          if strcmpi(this.ExportAs,'Objects')
            [lbls, names]   = parse4obj(this);
            olbls = parse4vec(this);
          else
            [lbls, names]  = parse4vec(this);
            olbls = parse4obj(this);
          end
        else
          [lbls, names]  = parse4vec(this);
          olbls = {};
        end
        
        % Create and a component with the updated information.
        newHlnv = siggui.labelsandvaluesMCOS('Maximum',max(length(lbls), length(olbls)));
        addcomponent(this,newHlnv);
        
        this.VariableLabels = lbls;
        this.VariableNames = names;
        
        l = event.proplistener(newHlnv, newHlnv.findprop('Values'),'PostSet', @(s,e)lclvalues_listener(this,e));
        this.ValuesListener = l;
        
        if isrendered(this)
          % Rerender labels and values
          
          pos = getpixelpos(this, 'framewlabel', 1);
          % Keep the x, and y, but replace the width and height.
          [pos(3), pos(4)] = destinationSize(this);
          
          notify(this, 'NewFrameHeight');
          
          thisrender(this, pos);
        end
      end
      
    end
    
    function varargout = parse4obj(this)
      %PARSE4OBJ Utility used when exporting objects.
            
      lbls = {};
      names = {};
      
      if nargin == 1
        % Get variable labels and names
        for n = 1:length(this.Data)
          newinfo = exportinfo(this.Data);
          lbls =  {lbls{:},newinfo.exportas.objectvariablelabel{:}};
          names = {names{:},newinfo.exportas.objectvariablename{:}};
        end
      end
      
      if length(lbls) == length(this.DefaultLabels)
        lbls = this.DefaultLabels;
      end
      
      % Make the variable names and labels unique (if not already)
      lbls = interspace(genvarname(lbls));
      names = genvarname(names);
      
      names = formatnames(this, lbls, names);
      
      % Make the variable names and labels unique (if not already)
      lbls = interspace(genvarname(lbls));
      names = genvarname(names);
      
      if nargout
        varargout = {lbls, names};
      else
        % Set the destination object specific properties
        this.VariableLabels = lbls;
        this.VariableNames = names;
      end
      
    end
    
    
    function varargout = parse4vec(this,varargin)
      %PARSE4VEC Utility used when exporting vectors.
            
      % If labels and variable names are specified explicitly.
      if nargin > 2,  lbls = varargin{1}; end
      if nargin > 3, names = varargin{2}; end
      
      lbls = {};
      names = {};
      isvecobj = false;
      
      if nargin == 1
        
        % Form a cell array of handles to the objects to be exported (to be
        % able to call their respective exportinfo methods).
        if isempty(this.Data), return; end
        data = cell(this.Data);
        
        if isa(data{1},'sigutils.vectorMCOS')
          data = cell(data{1});
          isvecobj = true;
        end
        
        % Get variable labels and names
        for n = 1:length(data)
          
          if isvecobj
            % Call the vector/exportinfo method for each element contained
            % in the sigutils.vector object.
            newinfo = exportinfo(this.Data);
          else
            % Call the class specific exportinfo
            newinfo = exportinfo(data{n});
          end
          
          lbls =  [lbls newinfo.variablelabel];
          names = [names newinfo.variablename];
        end
      end
      
      if length(lbls) == length(this.DefaultLabels)
        lbls = this.DefaultLabels;
      end
      
      % Make the variable names and labels unique (if not already)
      lbls  = interspace(genvarname(lbls));
      names = genvarname(names);
      
      names = formatnames(this, lbls, names);
      
      if nargout
        varargout = {lbls, names};
      else
        % Set the destination object specific properties
        this.VariableLabels = lbls;
        this.VariableNames = names;
      end
      
    end
    
    
    function render_exportas(this,pos)
      %RENDER_EXPORTAS Render a frame with an "Export As" popup.
      
      if nargin < 2 , pos =[]; end
      
      hFig = get(this,'FigureHandle');
      bgc  = get(0,'DefaultUicontrolBackgroundColor');
      cbs  = callbacks(this);
      sz   = xp_gui_sizes(this);
      
      % Render the "Export As" frame
      if isempty(pos)
        % Default Position
        pos = sz.XpAsFrpos;
      else
        % Adjust position (pos is for entire destination options frames)
        ypos = (pos(2)+pos(4))-sz.XpAsFrpos(4);
        pos = [pos(1) ypos pos(3) sz.XpAsFrpos(4)];
      end
      
      h    = get(this,'Handles');
      if ishandlefield(this, 'xpasfr')
        framewlabel(h.xpasfr, pos);
      else
        h.xpasfr = framewlabel(hFig, pos, getString(message('signal:sigtools:sigio:ExportAs')), 'exportas', bgc, this.Visible);
      end
      
      % Render the "Export As" popupmenu
      popupwidth = pos(3)-sz.hfus*2;
      XpAsPoppos = [pos(1)+sz.hfus pos(2)+sz.vfus*2 popupwidth sz.uh];
      
      % Untranslated strings
      strs = {'Coefficients','Objects','System Objects'};
      
      % Exclude 'System objects' option. It will be added later by the FDATool code
      sysObjIdx = strcmpi(strs,'System Objects');
      strs(sysObjIdx) = [];
      % Translated strings
      strsT = getTranslatedStringcell('signal:sigtools:sigtools', strs);
      
      if ishandlefield(this, 'exportas')
        setpixelpos(this, h.exportas, XpAsPoppos);
      else
        h.exportas = uicontrol(hFig, ...
          'Style', 'Popup', ...
          'Position', XpAsPoppos, ...
          'Callback', {cbs.exportas, this}, ...
          'Tag', 'exportas_popup', ...
          'Visible', this.Visible, ...
          'HorizontalAlignment', 'Left', ...
          'String', strsT);
        setenableprop(h.exportas, this.Enable);
      end
      % Save untranslated strings in the app data for use in the callback
      setappdata(h.exportas, 'PopupStrings', strs);
      
      set(this, 'Handles', h);
      
      l = event.proplistener(this, this.findprop('ExportAs'), 'PostSet', @(s,e)prop_listener(this,e));
      this.WhenRenderedListeners = l;
      
      prop_listener(this);
      
    end
    
    
    function savenames(this)
      %SAVENAMES   Save the names in the database.
      
      labels = strrep(this.VariableLabels, ' ', '_');
      for indx = 1:length(labels)
        jndx = regexp(labels{indx}, '\w');
        labels{indx} = labels{indx}(jndx);
        if isprop(this, 'ExportAs') && isdynpropenab(this, 'ExportAs')
          labels{indx} = [strrep(this.ExportAs, ' ', '') labels{indx}];
        end
      end
      
      names  = this.VariableNames;
      
      oldlbls = this.PreviousLabelsAndNames;
      
      for indx = 1:min(length(labels), length(names))
        oldlbls.(labels{indx}) = names{indx};
      end
      
      this.PreviousLabelsAndNames = oldlbls;
      
    end
    
    
    
    
    function P = setvariablelabels(h, P)
      %SETVARIABLELABELS SetFunction for the VariableLabels property.
      
      if ~isempty(P)
        lvh = getcomponent(h, '-class', 'siggui.labelsandvaluesMCOS');
        
        for n = 1:length(P)
          newP{n} = [getTranslatedString('signal:sigtools:sigio',P{n}),':'];
        end
        set(lvh,'Labels',newP);
      end
      
    end
    
    
    function dummy = setvariablenames(h, P)
      %SETVARIABLENAMES SetFunction for the VariableNames property.
      
      if isempty(P)
        dummy = [];
        return;
      else
        lvh = getcomponent(h, '-class', 'siggui.labelsandvaluesMCOS');
        set(lvh,'Values',P);
        
        dummy = [];
      end
      
    end
    
    
    function thisrender(h, hFig, pos)
      %THISRENDER Render the destination options frame.
      
      if nargin < 3 , pos =[]; end
      if nargin < 2 , hFig = gcf; end
      
      abstractxdwvars_thisrender(h,pos);
      
    end
    
    function updateexportaspopup(this)
      %UPDATEEXPORTASPOPUP Remove export as 'objects' or 'System objects' if not
      %supported
      
      sysObjSupported = false;
      objSupported = true;
      
      for idx = 1:length(this.Data)
        if isa(this.Data.elementat(idx),'dfilt.basefilter')
          if isfdtbxinstalled
            currentFilt = this.Data.elementat(idx);
            sysObjSupported = sysobj(currentFilt,true);
            % Disable exporting MFILT objects when System object is supported.
            if sysObjSupported && isa(this.Data.elementat(idx),'mfilt.abstractmultirate')
                objSupported = false;
            end
          end
        elseif isa(this.Data.elementat(idx),'sigwin.window')
          objSupported = false;
        end
      end
      
      expHdl = get(this,'Handles');
      if isfield(expHdl,'exportas')
        expHdl = expHdl.exportas;
        
        strs  = {'Coefficients','Objects','System Objects'};
        
        strsT = getTranslatedStringcell('signal:sigtools:sigtools', strs);
        
        if ~sysObjSupported
          % System objects are not supported for the current filter
          sysObjIdx = strcmpi(strs,'System Objects');
          strs(sysObjIdx)  = [];
          strsT(sysObjIdx) = [];
          if strcmpi('System objects',this.ExportAs)
            % Set the property to a valid option if it was set to 'System objects'
            this.ExportAs = 'Objects';
          end
        end
        
        if ~objSupported
          % objects are not supported
          objIdx = strcmpi(strs,'Objects');
          strs(objIdx)  = [];
          strsT(objIdx) = [];
          if strcmpi('objects',this.ExportAs)
            % Set the property to a valid option if it was set to 'Objects'
            this.ExportAs = 'Coefficients';
          end
        end
        
        % Set the popup 'String' property to the translated strings
        set(expHdl,'String',strsT);
        
        % Save untranslated strings in the app data for use in the callback
        setappdata(expHdl, 'PopupStrings', strs);
        
      end
      
      
    end
    
    function sz = xp_gui_sizes(h)
      %XP_GUI_SIZES SIGIO.ABSTRACTDESWVARS GUI Sizes.
      
      % Get the generic gui sizes
      sz = gui_sizes(h);
      
      % Default frame width and height
      sz.fw = 150*sz.pixf;
      sz.fh = getfrheight(h);
      
      % Variable Names frame position (without Overwrite checkbox)
      sz.VarNamesPos = [sz.ffs sz.ffs sz.fw sz.fh];
      
      % Export As frame position
      sz.XpAsFrpos = [sz.ffs sz.ffs+(sz.vffs)+sz.fh sz.fw 4*sz.vfus+sz.uh];
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function deflabels = setdefaultlabels(this, deflabels)
      %SETDEFAULTLABELS
      
      this.privDefaultLabels = deflabels;
      
      deflabels = [];
      
      if isprop(this, 'ExportAs') & isdynpropenab(this,'ExportAs') & strcmpi(this.ExportAs,'Objects')
        parse4obj(this);
      else
        parse4vec(this);
      end
      
      
    end
    
    function setnamedatabase(this, db)
      %SETNAMEDATABASE
      
      this.PreviousLabelsAndNames = setstructfields(getnamedatabase(this), db);
      formatnames(this);
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef


% ---------------------------------------------------------------------
function values_listener(this, eventData)

notify(this, 'UserModifiedSpecs');
savenames(this);

end


%--------------------------------------------------------------------
function addxpasdynprop(h,info)

h1 = h.addprop('ExportAs');
h1.SetObservable = true;
h.ExportAs = 'Coefficients'; % default Value

h1.SetMethod = @prop_listenerlcl;

end

% -------------------------------------------------------
function prop_listenerlcl(h, nval)

h.ExportAs = nval;

if any(strcmpi({'Objects','System Objects'},nval))
  parse4obj(h);
else
  parse4vec(h);
end

notify(h, 'ForceResize');

end


% ----------------------------------------------------------------
function lclvalues_listener(this, eventData) %#ok<INUSD>

notify(this, 'UserModifiedSpecs');
savenames(this);

end

