function datacursormenus(hCDC,varargin)
%DATACURSORMENUS Add UIContextMenu items to datacursor
%
%  Author(s): Nan Li
%  Copyright 2008-2014 The MathWorks, Inc.


if nargin > 1
    for i= 2:nargin
        switch lower(varargin{i-1})
            case 'fontsize'
                %---FontSize
                CM1 = uimenu(hCDC.UIContextMenu,'Label',getString(message('signal:sigtools:private:FontSize')),'Tag','FontSize');
                uimenu(CM1,'Label','6', 'Tag','FontSize6', 'Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',hCDC,'FontSize',6));
                uimenu(CM1,'Label','8', 'Tag','FontSize8', 'Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',hCDC,'FontSize',8));
                uimenu(CM1,'Label','10','Tag','FontSize10','Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',hCDC,'FontSize',10));
                uimenu(CM1,'Label','12','Tag','FontSize12','Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',hCDC,'FontSize',12));
                uimenu(CM1,'Label','14','Tag','FontSize14','Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',hCDC,'FontSize',14));
                uimenu(CM1,'Label','16','Tag','FontSize16','Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',hCDC,'FontSize',16));
                CH = get(CM1,'Children');
                set(findobj(CH,'flat','Tag',strcat('FontSize', num2str(get(hCDC, 'FontSize')))),'Checked','on');
                
            case 'alignment'
                %---Alignment
                CM1 = uimenu(hCDC.UIContextMenu,'Label',getString(message('signal:sigtools:private:Alignment')),'Tag','Alignment');
                uimenu(CM1,'Label',getString(message('signal:sigtools:private:Auto')),...
                    'Tag', 'AlignmentAuto','Callback',{@LocalSelectMenu,'alignment'}, ...
                    'UserData',struct('DataTip',hCDC,'OrientationMode','Auto'));                
                uimenu(CM1,'Label',getString(message('signal:sigtools:private:TopRight')), 'Tag','AlignmentTR', 'Separator','on' ,...
                    'Callback',{@LocalSelectMenu,'alignment'},...
                    'UserData',struct('DataTip',hCDC,'H','left','V','bottom'));
                uimenu(CM1,'Label',getString(message('signal:sigtools:private:TopLeft')),...
                    'Tag', 'AlignmentTL', 'Callback',{@LocalSelectMenu,'alignment'},...
                    'UserData',struct('DataTip',hCDC,'H','right','V','bottom'));
                uimenu(CM1,'Label',getString(message('signal:sigtools:private:BottomRight')),...
                    'Tag', 'AlignmentBR','Callback',{@LocalSelectMenu,'alignment'},'Separator','on',...
                    'UserData',struct('DataTip',hCDC,'H','left','V','top'));
                uimenu(CM1,'Label',getString(message('signal:sigtools:private:BottomLeft')),...
                    'Tag', 'AlignmentBL','Callback',{@LocalSelectMenu,'alignment'},...
                    'UserData',struct('DataTip',hCDC,'H','right','V','top'));                

                CH = get(CM1,'Children');              
                if strcmpi(hCDC.OrientationMode,'Auto') 
                   set(findobj(CH,'flat','Position',1),'Checked','on'); 
                else
                    switch hCDC.Orientation
                    case {'top-right','topright'}
                        set(findobj(CH,'flat','Position',2),'Checked','on');
                    case {'top-left','topleft'}
                        set(findobj(CH,'flat','Position',3),'Checked','on');
                    case {'bottom-right','bottomright'}
                        set(findobj(CH,'flat','Position',4),'Checked','on');
                    case {'bottom-left','bottomleft'}
                        set(findobj(CH,'flat','Position',5),'Checked','on');
                    end
                end                
                            
                l = event.proplistener(hCDC,hCDC.findprop('Orientation'), 'PostSet',@(hv, ev)LocalUpdateAlignment(hCDC,ev,hCDC));
                setappdata(hCDC, 'OrientationListener', l);                  
              
            case 'movable'
                %---Movable
                CM1 = uimenu(hCDC.UIContextMenu,'Label',getString(message('signal:sigtools:private:Movable')),...
                    'Tag', 'Movable', ...
                    'Callback',{@LocalSelectMenu,'movable'},...
                    'UserData',struct('DataTip',hCDC));
                if strcmpi(hCDC.Draggable,'on')
                    set(CM1,'Checked','on');
                else
                    set(CM1,'Checked','off');
                end
                
            case 'delete'
                %---Delete Menu
                CM1 = uimenu(hCDC.UIContextMenu,'Label',getString(message('signal:sigtools:private:Delete')),...
                    'Tag', 'Delete',...
                    'Callback',{@LocalSelectMenu,'delete'},...
                    'UserData',struct('DataTip',hCDC)); 
                
            case 'deleteall'
                %---Delete All Menu
                CM1 = uimenu(hCDC.UIContextMenu,'Label',getString(message('signal:sigtools:private:DeleteAll')),...
                    'Tag', 'Deleteall',...
                    'Callback',{@LocalSelectMenu,'deleteall'},...
                    'UserData',struct('DataTip',hCDC));
                
            case 'export'
                %---Export data cursor positiont to workspace
                CM1 = uimenu(hCDC.UIContextMenu,'Label',...
                    getString(message('signal:sigtools:private:ExportCursorDataToWorkspace')),...
                    'Tag', 'Export',...
                    'Callback',{@LocalSelectMenu,'export'},...
                    'UserData',struct('DataTip',hCDC));
                
            case 'interpolation'
                %---Interpolation
                CM1 = uimenu(hCDC.UIContextMenu,'Label',getString(message('signal:sigtools:private:Interpolation')),...
                    'Tag','Interpolation');
                CM2 = uimenu(CM1,'Label',getString(message('signal:sigtools:private:Nearest')),...
                    'Tag', 'InterpolationOff',...
                    'Callback',{@LocalSelectMenu,'interpolation'},...
                    'UserData',struct('DataTip',hCDC,'Interpolate','off'));
                CM2 = uimenu(CM1,'Label',getString(message('signal:sigtools:private:Linear')),...
                    'Tag', 'InterpolationOn',...
                    'Callback',{@LocalSelectMenu,'interpolation'},...
                    'UserData',struct('DataTip',hCDC,'Interpolate','on'));
                CH = get(CM1,'Children');
                
                if strcmpi(hCDC.Interpolate,'on')
                    set(findobj(CH,'flat','Position',2),'Checked','on');
                else
                    set(findobj(CH,'flat','Position',1),'Checked','on');
                end
                
            otherwise
                disp([varargin{i-1},' ',getString(message('signal:sigtools:private:IsNotAValidMenuSelection'))])
        end
    end
end

% LocalUpdateAlignment %
function LocalUpdateAlignment(~,~,hCDC)

MenuChildren = get(hCDC.UIContextMenu,'Children');
CH1 = findobj(MenuChildren,'Tag','Alignment');

if ~isempty(CH1)
    CH = get(CH1,'Children');
    set(CH(:),'Checked','off');
    switch hCDC.Orientation
        case {'top-right','topright'}
            set(findobj(CH,'flat','Position',2),'Checked','on');
        case {'top-left','topleft'}
            set(findobj(CH,'flat','Position',3),'Checked','on');
        case {'bottom-right','bottomright'}
            set(findobj(CH,'flat','Position',4),'Checked','on');
        case {'bottom-left','bottomleft'}
            set(findobj(CH,'flat','Position',5),'Checked','on');
    end
end


% LocalSelectMenu %
function LocalSelectMenu(eventSrc,eventData,action) %#ok<INUSL>

Menu = eventSrc;
mud = get(Menu,'UserData');
h  = mud.DataTip;
hDCM = datacursormode(ancestor(Menu, 'figure'));

switch lower(action)
    case 'fontsize'
        set(h,'FontSize',mud.FontSize);
        %---Set current menu selection "checked"
        set(get(get(Menu,'Parent'),'Children'),'Checked','off');
        set(Menu,'Checked','on');
        
    case 'alignment'
        %---Set current menu selection "checked"
        set(get(get(Menu,'Parent'),'Children'),'Checked','off');
        set(Menu,'Checked','on');
        
        if isfield(mud,'OrientationMode') && strcmpi(mud.OrientationMode,'auto')
            h.OrientationMode = 'Auto';
        else
            
            if  strcmpi(mud.V,'top') && strcmpi(mud.H,'right')
                h.Orientation = 'bottomleft';
            elseif strcmpi(mud.V,'top') && strcmpi(mud.H,'left')
                h.Orientation = 'bottomright';
            elseif strcmpi(mud.V,'bottom') && strcmpi(mud.H,'right')
                h.Orientation = 'topleft';
            elseif strcmpi(mud.V,'bottom') && strcmpi(mud.H,'left')
                h.Orientation = 'topright';              
            end
        end
        
    case 'movable'
        if strcmpi(get(Menu,'Checked'),'on')
            h.Draggable = 'off';           
            set(Menu,'Checked','off')
        else
            h.Draggable = 'on';
            set(Menu,'Checked','on')
        end
        
    case 'deleteall'      
        removeAllDataCursors(hDCM);
        return
        
    case 'delete'
        delete(h);
        return
        
    case 'interpolation'
        h.Interpolate = mud.Interpolate;
      
        %---Set current menu selection "checked"
        set(get(get(Menu,'Parent'),'Children'),'Checked','off');
        set(Menu,'Checked','on');
        
    case 'export'
        %Copy/Paste code from
        %matlab\toolbox\matlab\graphics\@graphics\@datacursormanager\create
        %UIContextMenu.m
        hFig = get(hDCM, 'Figure');
        prompt={getString(message('signal:sigtools:private:EnterTheVariableName'))};
        name=getString(message('signal:sigtools:private:ExportCursorDataToWorkspace'));
        numlines=1;
        defaultanswer={get(hDCM,'DefaultExportVarName')};
        %Don't overwrite the default variable name if it already exists:
        userAns = false;
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        exists = 0;
        if ~isempty(answer) && ischar(answer{1})
            exists = evalin('base', ['exist(''' answer{1} ''',''var'')']);
        end
        while exists && ~userAns
            warnMessage = [getString(message('signal:sigtools:private:AVariableNamedAlreadyExists',answer{1})) ...
                                getString(message('signal:sigtools:private:IfYouContinueYouWillOverwrite',answer{1}))];
            %This dialog window has bug in this release. We expect HG team 
            % to provide an external API. Whenever HG team fix this bug or
            % implement the API, we need change this code.
            %userAns = localUIPrefDiag(hFig, warnMessage, sprintf('Export Cursor Data to Workspace'),'DataCursorVariable');
            userAns = 1;
            if ~userAns
                answer=inputdlg(prompt,name,numlines,defaultanswer);
                if ~isempty(answer) && ischar(answer{1})
                    exists = evalin('base', ['exist(''' answer{1} ''',''var'')']);
                else
                    exists = 0;
                end
            end
        end
        if ~isempty(answer) && ischar(answer{1})
            datainfo = getCursorInfo(hDCM);
            try
                assignin('base',answer{1},datainfo);
                set(hDCM,'DefaultExportVarName',answer{1});
            catch ex
                id = ex.identifier;
                if strcmpi(id,'MATLAB:assigninInvalidVariable')
                    errordlg(getString(message('signal:sigtools:private:InvalidVariableName',answer{1})),...
                        getString(message('signal:sigtools:private:CursorDataExportError')));
                else
                    errordlg(getString(message('signal:sigtools:private:AnErrorOccurredWhileSavingTheData')),...
                        getString(message('signal:sigtools:private:CursorDataExportError')));
                end
            end
        end
end
