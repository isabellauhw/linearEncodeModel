classdef xp2wkspMCOS < sigio.abstractxpdestwvarsMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %sigio.xp2wksp class
  %   sigio.xp2wksp extends sigio.abstractxpdestwvars.
  %
  %    sigio.xp2wksp properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Data - Property is of type 'mxArray'
  %       Toolbox - Property is of type 'string'
  %       DefaultLabels - Property is of type 'mxArray'
  %       VariableLabels - Property is of type 'mxArray'
  %       VariableNames - Property is of type 'mxArray'
  %       Overwrite - Property is of type 'bool'
  %
  %    sigio.xp2wksp methods:
  %       action - Perform the action of exporting to the Workspace.
  %       getfrheight - Get frame height.
  %       thisrender - Render the destination options frame.

%   Copyright 2014-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %OVERWRITE Property is of type 'bool'
    Overwrite = 0;
  end
  
  
  methods  % constructor block
    function this = xp2wkspMCOS(data)
      %XP2WKSP Constructor for the export to workspace class.
      
      narginchk(1,1);
      
      this.Version = 1.0;
      this.Data = data;
      
      abstractxpdestwvars_construct(this);
      
      settag(this);
      
      
    end  % xp2wksp
    
    function set.Overwrite(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'numeric'}, {'scalar'},'','Overwrite')
      obj.Overwrite = value;
    end
    
    function success = action(this)
      %ACTION Perform the action of exporting to the Workspace.
      
      tnames  = this.VariableNames;
      if ~iscell(tnames), tnames = {tnames}; end
      
      
      % Check if VariableNames are unique
      chkVarName(tnames);
      
      overwriteVars = get(this,'Overwrite');
      % Check if the variables exist in the workspace.
      chkIfVarExistInWksp(tnames,overwriteVars);
      
      % variables & tnames are cell arrays of the same length.
      variables = formatexportdata(this);
      
      % Make sure that when we only have a single variable to be exported to
      % the workspace, that the information we export is everything in the
      % 'variables' variable. g307525
      if length(tnames) == 1 && length(variables) ~= 1
        variables = {variables};
      end
      
      for i = 1:length(tnames)
        
        % Check for valid names
        if isvarname(tnames{i})
          assign2wkspace('base',tnames{i},variables{i});
        else
          error(message('signal:sigio:xp2wksp:action:InvalidVarName', tnames{ i }))
        end
      end
      
      % Message to be displayed in the command window.
      sendstatus(this, getString(message('signal:sigtools:sigio:VariablesHaveBeen')));
      success = true;
      
    end
    
    function hght = getfrheight(h)
      %GETFRHEIGHT Get frame height.
      
      varsHght = abstract_getfrheight(h);
      sz = gui_sizes(h);
      
      % Adding addition height due to the overwrite checkbox
      hght = varsHght + sz.uh + sz.uuvs;
      
    end
    
    function thisrender(this, varargin)
      %THISRENDER Render the destination options frame.
      
      pos  = parserenderinputs(this, varargin{:});
      sz   = xp_gui_sizes(this);
      h    = get(this,'Handles');
      hFig = get(this,'FigureHandle');
      cbs  = callbacks(this);
      
      if isprop(this, 'ExportAs') && isdynpropenab(this,'ExportAs')
        % Render the "Export As" frame above the destination options frame
        render_exportas(this,pos);
      elseif ishandlefield(this, 'xpaspopup')
        delete([h.xpaspopup h.xpasfr]);
      end
      
      % Call super class thisrender method.
      if isempty(pos)
        pos = sz.VarNamesPos;
      elseif isprop(this, 'ExportAs') && isdynpropenab(this,'ExportAs')
        % Position was specific, adjust for the "Export As" frame
        pos = [pos(1) pos(2) pos(3) pos(4)-(sz.XpAsFrpos(4)+sz.vffs)];
      end
      abstractxdwvars_thisrender(this,pos);
      h    = get(this,'Handles');
      
      sz.checkbox = [pos(1)+sz.hfus pos(2)+sz.vfus pos(3)-sz.hfus*2 sz.uh];
      
      if ishandlefield(this, 'overwrite')
        setpixelpos(this, h.overwrite, sz.checkbox);
      else
        h.overwrite = uicontrol(hFig, ...
          'Position', sz.checkbox, ...
          'Style', 'Check', ...
          'Tag', 'export_checkbox', ...
          'Visible', 'Off', ...
          'Callback', {cbs.checkbox, this}, ...
          'String',getString(message('signal:sigtools:sigio:OverwriteVariables')));
        set(this,'Handles',h);
      end
      
      hlnv = getcomponent(this, 'siggui.labelsandvaluesMCOS');
      if ~isrendered(hlnv)
        
        hFig = get(this,'FigureHandle');
        sz   = xp_gui_sizes(this);
        
        % Define the position for the labelsandvalues object (taking into account
        % the "Overwrite Variables" checkbox
        ypos = pos(2)+(2*sz.vfus)+sz.uh;
        info = exportinfo(this.Data);
        if isfield(info, 'exportas')
          width = largestuiwidth([get(hlnv, 'Labels')'; info.variablelabel(:); info.exportas.objectvariablelabel(:)]);
        else
          width = largestuiwidth([get(hlnv, 'Labels'); info.variablelabel(:);]);
        end
        render(hlnv,hFig, ...
          [pos(1)+sz.lfs ypos pos(3)-(2*sz.hfus) pos(4)-(4*sz.vfus+sz.uh)], ...
          width);
        set(hlnv, 'Visible', get(this, 'Visible'));
      end
      
      l = event.proplistener(this, this.findprop('OverWrite'), 'PostSet', @(s,e)prop_listener(this,varargin));
      set(this, 'WhenRenderedListeners', union(l, this.WhenRenderedListeners));
      
      % Update popup menu to add or remove the 'System object' option depending
      % on whether the current filter is supported by filter System objects or
      % not.
      update_popup(this);
      
    end
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    
    function [width, height] = destinationSize(this)
      %DESTINATIONSIZE
      
      sz = xp_gui_sizes(this);
      optFrHght = getfrheight(this);
      
      height = optFrHght;
      if isprop(this, 'ExportAs') && isdynpropenab(this,'ExportAs')
        height = optFrHght+sz.vffs+sz.XpAsFrpos(4);
      end
      
      % Width is the width of the labels + 100 pixels for the edit boxes, plus 40
      % pixels for the spacing.
      width = largestuiwidth([this.DefaultLabels(:)' this.VariableLabels(:)']) + ...
        100*sz.pixf +40*sz.pixf;
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef



%-------------------------------------------------------------------
function assign2wkspace(wkspace, name, variable)

assignin(wkspace, name, variable);

end

%-------------------------------------------------------------------
function chkIfVarExistInWksp(vnames, overwriteVars)
% CHKIFVAREXISTINWKSP Check if the variables exist in the workspace.
%
% Input:
%   vnames - Filter Structure specific coefficient strings stored
%               in FDATool's UserData.
%   overwriteVars - Overwrite vars flag

% Get the base workspace variable names
vars = evalin('base', 'whos');
vars = {vars.name};

% Check if there are any common names between the base workspace and the
% variable names we are going to use for export.
common = intersect(vars, vnames);

if ~isempty(common)
  if ~overwriteVars
    error(message('signal:sigio:xp2wksp:action:VarAlreadyExist', common{ 1 }))
  end
end

end

%-------------------------------------------------------------------
function chkVarName(tnames)
% CHKVARNAME Check if the variables names are unique

[~,~,J] =  unique(tnames);
for n = 1:length(J)
  idx = find(J == J(n));
  
  if length(idx) > 1
    % Variable Name is repeated
    error(message('signal:sigio:xp2wksp:action:VarNotUnique'))
  end
end

end

%--------------------------------------------------------------------------
function update_popup(this)

updateexportaspopup(this)

expHdl = get(this,'Handles');
if isfield(expHdl,'exportas') && ...
    any(strcmpi({'Objects','System objects'},this.ExportAs))
  % React to setting the export as dialog to an object. Set the rest of the
  % dialog accordingly.
  parse4obj(this);
end

end

