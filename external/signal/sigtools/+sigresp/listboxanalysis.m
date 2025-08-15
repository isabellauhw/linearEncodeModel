classdef (Abstract) listboxanalysis < sigresp.abstractanalysis
  %sigresp.listboxanalysis class
  %   sigresp.listboxanalysis extends sigresp.abstractanalysis.
  %
  %    sigresp.listboxanalysis properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %
  %    sigresp.listboxanalysis methods:
  %       print - Print the listbox view.
  %       printpreview - Print preview the listbox view.
  %       thisrender - Draw the analysis
  %       thisunrender - Unrender this object
  
  
  
  methods  %% public methods
    function print(hObj)
      %PRINT Print the listbox view.

      % Set your default file name using the temp directory
      tname = [tempdir filesep 'fdacoeffs.txt'];
      
      fid = fopen(tname,'wt');
      if fid ~= -1                     % Check for bad directory
        coeffStr = getanalysisdata(hObj);
        for indx = 1:length(coeffStr)
          for jndx = 1:size(coeffStr{indx}, 1)
            fprintf(fid,'%s\n',coeffStr{indx}(jndx,:));
          end
        end
        fclose(fid);
        edit(tname);
      else
        msgbox('Cannot open file to write coefficients.','File Error')
      end
      
    end
    
    function printpreview(hObj)
      %PRINTPREVIEW Print preview the listbox view.
 
      print(hObj)
      
    end
    
    function thisrender(this, h, varargin)
      %THISRENDER Draw the analysis

      if nargin < 2
        h = [];
      else
        h = findobj(h, 'type', 'uicontrol', 'style', 'listbox');
      end
      
      if isempty(h)
        
        % If there is no listbox provided make one that has the same size and
        % position as the default axes.
        a = axes('Visible','off');
        
        h = uicontrol('Style', 'Listbox', ...
          'Units', get(a, 'Units'), ...
          'Position', get(a, 'Position'));
        delete(a);
      end
      
      hs.listbox = h(end);
      set(hs.listbox, 'FontName', 'fixedwidth');
      
      set(this, 'Handles', hs);
      set(this, 'FigureHandle', get(hs.listbox, 'Parent'));
      
      lcldraw(this, varargin{:});
      
      attachlisteners(this, @lcldraw);
      lclattachlisteners(this);
      
    end
    
    function thisunrender(hObj)
      %THISUNRENDER Unrender this object

      h = get(hObj, 'Handles');
      
      % Clear out the listbox.
      if ishghandle(h.listbox), set(h.listbox, 'String', {}); end
      
      % Remove the listbox, since we do not want to unrender this.
      h = rmfield(h, 'listbox');
      
      % Convert to a vector for easy deleting.
      h = convert2vector(h);
      
      % Remove any handles that are no longer valid.
      h(~ishghandle(h)) = [];
      
      delete(h);
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function attachlisteners(h, fcn) %#ok<INUSD>
      %ATTACHLISTENERS

      % NO OP
    end
    
  end  %% possibly private or hidden
  
end  % classdef

% --------------------------------------------------------------
function lcldraw(this, varargin)

strs = getanalysisdata(this);

% Only add the separators if there is more than 1 filter
if length(this.Filters) > 1
  coeffstrs = cell(length(strs)*2, 1);
  [coeffstrs{2:2:end}] = deal(strs{:});
  for indx = 1:length(this.Filters)
    name = get(this.Filters(indx), 'Name');
    if isempty(name), name = getString(message('signal:sigtools:sigresp:Filter0numberinteger', indx)); end
    coeffstrs{2*indx-1} = char(' ', '% -------------------------------', ...
      ['% ' name], '% -------------------------------', ' ');
  end
  coeffstrs{1}(1:2,:) = [];
  strs = coeffstrs;
end

h = get(this, 'Handles');

% Get the current value of the selected listbox item
val = get(h.listbox, 'Value');

% Select the first item in the listbox if previous list item had more rows
m = size(strs,1);
if m < val
  val = m;
end

% Display the Coefficients in the listbox
set(h.listbox,'Visible',this.Visible,'Value',val,'String',strs);

notify(this, 'NewPlot');

end

% -------------------------------------------------------------------------
function lclattachlisteners(this)

hPrm = getparameter(this);
if isempty(hPrm)
    return;
end

l = {get(this, 'WhenRenderedListeners')};

newl = handle.listener(hPrm, 'NewValue', @(src, evt) newvalue_listener(this));

if isempty(l)
    l = newl;
else
    l{end+1} = newl;
end

set(this, 'WhenRenderedListeners', l);

end

% -------------------------------------------------------------------------
function newvalue_listener(this)

lcldraw(this);

end
