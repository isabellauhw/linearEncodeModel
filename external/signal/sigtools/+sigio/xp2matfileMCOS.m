classdef xp2matfileMCOS < sigio.abstractxp2fileMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %sigio.xp2matfile class
  %   sigio.xp2matfile extends sigio.abstractxp2file.
  %
  %    sigio.xp2matfile properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Data - Property is of type 'mxArray'
  %       Toolbox - Property is of type 'string'
  %       DefaultLabels - Property is of type 'mxArray'
  %       VariableLabels - Property is of type 'mxArray'
  %       VariableNames - Property is of type 'mxArray'
  %       FileName - Property is of type 'string'
  %       FileExtension - Property is of type 'string'
  %       DialogTitle - Property is of type 'string'
  %
  %    sigio.xp2matfile methods:
  %       action - Perform the action of exporting to a MAT-file.
  %       thisrender - Render the destination options frame.

%   Copyright 2014-2017 The MathWorks, Inc.
  
  
  
  methods  % constructor block
    function this = xp2matfileMCOS(data)
      %XP2MATFILE Constructor for the eport to MAT-file class.
            
      narginchk(1,1);
      
      % this = sigio.xp2matfile;
      
      this.Version = 1.0;
      this.Data = data;
      
      abstractxpdestwvars_construct(this);
      
      % Set save file dialog box properties
      this.FileName = 'untitled.mat';
      this.FileExtension = 'mat';
      this.DialogTitle = 'Export to a MAT-file';
      
      settag(this);
      
      
    end  % xp2matfile
    
    
    function success = action(hCD)
      %ACTION Perform the action of exporting to a MAT-file.
      
      [file, path] = uiputfile('*.mat', hCD.DialogTitle, hCD.FileName);
      
      if any(file == 0)
        success = false;
      else
        file = fullfile(path, file);
        save2matfile(hCD,file);
        success = true;
      end
      
      
    end
    
    
    function thisrender(this, varargin)
      %THISRENDER Render the destination options frame.
            
      pos = parserenderinputs(this, varargin{:});
      
      sz = xp_gui_sizes(this);
      
      if isprop(this,'ExportAs')
        % Render the "Export As" frame above the destination options frame
        render_exportas(this,pos);
      end
      
      updateexportaspopup(this);
      
      % Call super class thisrender method.
      if isempty(pos)
        pos = sz.VarNamesPos;
      elseif isprop(this,'ExportAs')
        % Position was specific, adjust for the "Export As" frame
        pos = [pos(1) pos(2) pos(3) pos(4)-(sz.XpAsFrpos(4)+sz.vffs)];
      end
      
      abstractxdwvars_thisrender(this,pos);
      
      hlnv = getcomponent(this, 'siggui.labelsandvaluesMCOS');
      
      if ~isrendered(hlnv)
        
        hFig = get(this,'FigureHandle'); %#ok<NASGU>
        sz   = xp_gui_sizes(this);
        
        % Define the position for the labelsandvalues object (taking into account
        % the "Overwrite Variables" checkbox
        ypos = pos(2)+sz.vfus*1.9;
        render(hlnv,this.FigureHandle, ...
          [pos(1)+sz.lfs ypos pos(3)-(2*sz.hfus) pos(4)-(4*sz.vfus)], ...
          largestuiwidth(get(hlnv,'Labels')));
        set(hlnv, 'Visible', get(this, 'Visible'));
      end
      
      % % Add contextsensitive help
      % cshelpcontextmenu(this, 'fdatool_Export2SPToolOpts');
      
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


%------------------------------------------------------------------------
function save2matfile(hCD,f_i_l_e)
%SAVE2MATFILE Save filter coefficients to a MAT-file
%
% Inputs:
%   hXP - Handle to the destination object
%   f_i_l_e - String containing the MAT-file name.

% variables & tnames are cell arrays of the same length.
variables = formatexportdata(hCD);

tnames  = get(hCD,'VariableNames');
if ~iscell(tnames), tnames = {tnames}; end

for i = 1:length(tnames)
  if isvarname(tnames{i})
    assign2wkspace('caller',tnames{i},variables{i});
  else
    error(message('signal:sigio:xp2matfile:action:InvalidVarName', tnames{ i }))
  end
end

% Create the MAT-file
save(f_i_l_e,tnames{:},'-mat');

end

%-------------------------------------------------------------------
function assign2wkspace(wkspace, name, variable)

assignin(wkspace, name, variable);

end
