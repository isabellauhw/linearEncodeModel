classdef xp2txtfileMCOS < sigio.abstractxp2fileMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %sigio.xp2txtfile class
  %   sigio.xp2txtfile extends sigio.abstractxp2file.
  %
  %    sigio.xp2txtfile properties:
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
  %    sigio.xp2txtfile methods:
  %       action - Perform the action of exporting to a text-file.
  %       thisrender - RENDER Render the destination options frame.
  
  
  %   Copyright 1988-2017 The MathWorks, Inc.

  methods  % constructor block
    function h = xp2txtfileMCOS(data)
      %XP2TXTFILE Constructor for the export to text-file class..
      
      narginchk(1,1);
      
      % h = sigio.xp2txtfile;
      
      h.Version = 1.0;
      h.Data = data;
      
      % Set variable labels and names
      parse4vec(h);
      
      % Set save file dialog box properties
      h.FileName = 'untitled.txt';
      h.FileExtension = 'txt';
      h.DialogTitle = 'Export to a Text-file';
      
      settag(h);
            
    end  % xp2txtfile
        
    function success = action(hCD)
      %ACTION Perform the action of exporting to a text-file.
      
      [file, path] = uiputfile('*.txt', hCD.DialogTitle, hCD.FileName);
      
      if any(file == 0)
        success = false;
      else
        file = fullfile(path, file);
        save2textfile(hCD,file);
        success = true;
      end
      
    end
    
    function thisrender(h, hFig, pos)
      %RENDER Render the destination options frame.
            
      if nargin < 3 , pos =[]; end
      if nargin < 2 , hFig = gcf; end
      
      abstract_thisrender(h,hFig,pos);
      
    end
    
  end  %% public methods
  
end  % classdef


%------------------------------------------------------------------------
function save2textfile(this, file)
%SAVE2TEXTFILE Save filter coefficients to a Text-file
%
% Inputs:
%   file  - String containing the Text-file name.
%   this - Handle to the Export dialog object

fid = fopen(file, 'w');

tbx = this.Toolbox;
if isempty(tbx)
  tbx = 'signal';
end

% Display header information
fprintf(fid,'%s\n',sptfileheader('', tbx));

savevars2textfile(this, fid);

fclose(fid);

% Launch the MATLAB editor (to display the coefficients)
edit(file);

end

%------------------------------------------------------------------------
function savevars2textfile(this, fid)

labels = get(this, 'VariableLabels');

if isempty(labels), labels = get(this, 'DefaultLabels'); end

% variables & labels are cell arrays of the same length.
variables = formatexportdata(this);

print2file(this, fid, labels, variables);

end

%-------------------------------------------------------------------
function print2file(this, fid, labels, variables)

for i = 1:length(labels)
  fprintf(fid, '%s:\n', labels{i});
  
  % Only perform this action on a vector.
  if any(size(variables{i}) == 1)
    variables{i} = variables{i}(:);
  end
  
  sz = size(variables{i});
  for j = 1:sz(1) % Rows
    fprintf(fid, '%s\n', num2str(variables{i}(j,:),10));
  end
  fprintf(fid, '\n');
end


end
