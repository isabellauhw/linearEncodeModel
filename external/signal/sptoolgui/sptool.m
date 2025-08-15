function varargout = sptool(varargin)
%SPTOOL  Signal Processing Tool - Graphical User Interface.
%
%   WARNING: SPTOOL is not recommended and may be removed in a future
%   release. 
%
%   For signal and spectral analysis, use the Signal Analyzer app.
%   Open the app by typing signalAnalyzer in the MATLAB command window.
%
%   For filter design, use the Filter Designer app. Open the app by typing
%   filterDesigner in the MATLAB command window.
%
%   You can find both apps on the Apps tab, under Signal Processing and
%   Communications.

%   Copyright 1988-2018 The MathWorks, Inc.

[varargin{:}] = convertStringsToChars(varargin{:});

if nargin == 0
    action = 'init';
    shh = get(0,'ShowHiddenHandles');
    set(0,'ShowHiddenHandles','on')
    sptoolfig = findobj(0,'Tag','sptool');
    set(0,'ShowHiddenHandles',shh);
    if ~isempty(sptoolfig)
        figure(sptoolfig)
        return
    end
else
    %     convert2FDA flag is used to force FDATool format conversion without
    %     dialog. Only used for internal test
    if isequal(varargin{1}, 'convert2FDA')
        action = 'init';
        shh = get(0,'ShowHiddenHandles');
        set(0,'ShowHiddenHandles','on')
        sptoolfig = findobj(0,'Tag','sptool');
        set(0,'ShowHiddenHandles',shh);
        if ~isempty(sptoolfig)
            figure(sptoolfig)
            return
        end
    else
        action = varargin{1};
    end
end

switch action
    
    case 'init'                % initialization
        warning(message('signal:sptool:DeprecationWarning'));
        % Initialize SPTool userdata (ud)
        ud = init_sptool_data_settings;
        
        % create sptool manager gui
        [fig,ud] = create_sptool_gui(ud);
        
        set(fig,'UserData',ud,'ResizeFcn','sptool(''resize'')')
        
        allPanels = {ud.prefs.panelName};
        defsesInd = findcstr(allPanels,'defsession');
        fileExist = ~isempty(which('startup.spt'));
        if ud.prefs(defsesInd).currentValue{1}(1) & fileExist
            % Load default SPTool session file
            if ~isempty(varargin) && isequal(varargin{1}, 'convert2FDA')
                sptool('open','startup.spt', 1);
            else
                sptool('open','startup.spt');
            end
        end
        ud = get(fig,'UserData');
        if ud.fdwarnflag == 1
                % Show the conversion dialog, since Filter Builder is no longer
                % supported (g1388310)
                udnew = promptForFDA(ud, [], []);
                if isempty(udnew)
                    % If the user selects cancel, clear all filters.
                    sptool('clear' ,'clear all');
                    ud.session{2} = [];
                else
                    ud = udnew;
                end
                ud.fdwarnflag = 0;
                 set(fig,'UserData',ud);
                %Update the preferences to switch from filtDes to fdatool.
                p = sptool('getprefs','filtdes');
                p.fdatoolFlag = 1;
                p.filterDesignerFlag = 0;
                sptool('setprefs','filtdes',p)
        end
        
        sptool('resize')
        selectionChanged(fig,'new')
        set(fig,'HandleVisibility','callback','Visible','on')
        
        cacheclasses;
        
        %------------------------------------------------------------------------
        % structArray = sptool('callall',fname,structArray)
        % searches for all fname.m on path
        % and calls all found with structArray = feval(fname,structArray)
    case 'callall'
        fname = varargin{2};
        structArray = varargin{3};
        
        w = which('-all',fname);
        % make sure each entry is unique
        for i=length(w):-1:1
            ind = findcstr(w(1:i-1),w{i});
            if ~isempty(ind)
                w(i) = [];
            end
        end
        if ~isempty(w)
            origPath=pwd;
        end
        for i=1:length(w)
            thispath=char(w(i));
            pathsp=find(thispath==filesep);
            pathname=thispath(1:pathsp(end));
            cd(pathname)
            structArray = feval(fname,structArray);
        end
        if ~isempty(w)
            cd(origPath)
        end
        varargout{1} = structArray;
        
        %------------------------------------------------------------------------
        % p = sptool('getprefs',panelName)
        % p = sptool('getprefs',panelName,fig)
        %   Return preference structure for panel with panelName
        %   Inputs:
        %     panelName - string
        %     fig (optional) - figure of SPTool; uses findobj if not given
        %   Outputs:
        %     p - value structure for this panel
        %     p_defaults - default values structure (from sigprefs.mat) for this panel
    case 'getprefs'
        % set showhiddenhandles since this might be called from the command line:
        shh = get(0,'ShowHiddenHandles');
        set(0,'ShowHiddenHandles','on');
        panelName = varargin{2};
        if nargin > 2
            fig = varargin{3};
        else
            fig = findobj(0,'Tag','sptool');
        end
        ud = get(fig,'UserData');
        allPanels = {ud.prefs.panelName};
        i = findcstr(allPanels,panelName);
        if isempty(i)
            error(message('signal:sptool:GUIErrPanel', panelName, sprintf( '\n   ''%s'' ', allPanels{ : } )));
        end
        %p = prefstruct(ud.prefs(i));
        p = cell2struct(ud.prefs(i).currentValue,ud.prefs(i).controls(:,1));
        varargout{1} = p;
        if nargout > 1
            % Provide the default value to compare against a possible new preference
            fileName='sigprefs.mat';
            if ~isempty(which(fileName))
                % Load MAT-file containing saved preferences to compare
                % against current preferences.
                load(fileName);
                
                % Return a structure with containing the preference names and values.
                varargout{2} = eval(['SIGPREFS.',ud.prefs(i).panelName]);
            else
                % Compare against default (factory) settings stored in the figure's userdata.
                varargout{2} = cell2struct(ud.prefs(i).controls(:,7),...
                    ud.prefs(i).controls(:,1));
            end
            
        end
        set(0,'ShowHiddenHandles',shh);
        
        
        %------------------------------------------------------------------------
        % sptool('setprefs',panelName,p)
        % sptool('setprefs',panelName,p,fig)
        %   Set preference structure for panel with panelName
        %   Inputs:
        %     panelName - string
        %     p - value structure for this panel
        %     fig (optional) - figure of SPTool; uses findobj if not given
    case 'setprefs'
        panelName = varargin{2};
        p = varargin{3};
        if nargin > 3
            fig = varargin{4};
        else
            fig = findobj(0,'Tag','sptool');
        end
        ud = get(fig,'UserData');
        allPanels = {ud.prefs.panelName};
        i = findcstr(allPanels,panelName);
        if isempty(i)
            error(message('signal:sptool:GUIErrPanel', panelName, sprintf( '\n   ''%s'' ', allPanels{ : } )));
        end
        ud.prefs(i).currentValue = struct2cell(p);
        setsigpref(ud.prefs(i).panelName,p);
        set(fig,'UserData',ud)
        
    case 'resize'
        sptoolfig = findall(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        numComponents = length(ud.components);
        fp = get(sptoolfig,'Position');
        upperlefty = fp(2)+fp(4);
        
        % NOTE: Only set the figure position when the figure gets too small.
        % Changing the figure's position using SET clears the 'Maximized' state
        % of the figure, hence, disabling the 'Minimize' button on the figure.
        if fp(3) < 208 && fp(4) < 193
            fp(2) = upperlefty - 193;
            fp(3) = 208;
            fp(4) = 193;
            set(sptoolfig,'Position',fp);
            % warndlg('Restoring SPTool figure to its minimum height and width.','Too Small');
        elseif fp(3) < 208
            fp(3) = 208;
            set(sptoolfig,'Position',fp);
            % warndlg('Restoring SPTool figure to its minimum width.','Too Thin');
        elseif fp(4) < 193.
            fp(2) = upperlefty - 193;
            fp(4) = 193;
            set(sptoolfig,'Position',fp);
            % warndlg('Restoring SPTool figure to its minimum height.','Too Short');
        end
        
        d1 = 3;
        d2 = 3;
        uw = (fp(3)-(numComponents+1)*d1)/numComponents;
        uh = 20;  % height of buttons and labels
        lb = d2+(d2+uh)*(ud.maxVerbs);  % list bottom
        for i=1:numComponents
            set(ud.list(i),'Position',[d1+(d1+uw)*(i-1) lb uw fp(4)-lb-2*d2-uh])
            set(ud.label(i),'Position',[d1+(d1+uw)*(i-1) fp(4)-d2-uh uw uh])
            for j=1:length(ud.components(i).verbs)
                set(ud.buttonHandles(i).h(j),'Position',...
                    [d1+(d1+uw)*(i-1) lb-j*(d2+uh) uw uh]);
            end
        end
        
    case 'open'
        %  sptool('open')   <-- uses uigetfile to get filename and path
        %  sptool('open',f) <-- uses file with filename f on the MATLAB path
        %  sptool('open',f,p) <-- uses file with filename f and path p
        sptoolfig = findall(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        % Store UserData in case user cancels session (g1729863)
        udBack = get(sptoolfig,'UserData');
        if ud.unchangedFlag == 0
            if ~saveChangesPrompt(ud.sessionName,'opening')
                return
            end
        end
        forceFDAformat = 0;
        
        switch nargin
            case 1
                matlab_wd = pwd;
                cd(ud.wd)
                [f,ud.sessionPath]=uigetfile('*.spt',getString(message('signal:sptoolgui:OpenSession')));
                cd(matlab_wd)
                
                if ~isequal(f,0)
                    loadName = fullfile(ud.sessionPath,f);
                    ud.wd = ud.sessionPath;
                    set(sptoolfig,'UserData',ud)
                else
                    return
                end
                
            case 2
                f = varargin{2};
                loadName = which(f);
                if isempty(loadName)
                    error(message('signal:sptool:GUIErrFileNotFound', f))
                end
                ud.sessionPath = '';
            case 3
                f = varargin{2};
                if isequal(varargin{3}, 1)
                    loadName = which(f);
                    if isempty(loadName)
                        error(message('signal:sptool:GUIErrFileNotFound', f))
                    end
                    ud.sessionPath = '';
                    forceFDAformat = 1;
                else
                    ud.sessionPath = varargin{3};
                    loadName = fullfile(ud.sessionPath,f);
                    if exist(loadName, 'file')~=2
                        error(message('signal:sptool:GUIErrFileNotFound', loadName))
                    end
                end
        end
        
        if ~isequal(f,0)
            load(loadName,'-mat')
            if ~exist('session','var')  % variable
                waitfor(msgbox(getString(message('signal:sptoolgui:ThisFileIsNotAValidSPTFile')),...
                    getString(message('signal:sptoolgui:MissingSessionInfo')),'error','modal'))
                return
            end
            
            ud = get(sptoolfig,'UserData');
            ud.sessionName = f;
            %-------------------------------------------------------------------------
            % Code added for FDATool - check for pref setting to determine what to use
            % for filter design
            %-------------------------------------------------------------------------
            filtdesPrefs = sptool('getprefs','filtdes',sptoolfig);
            ud.session = struct2cell(session); %#ok 'session' is loaded from mat-file
            set(sptoolfig,'UserData', ud);
            filters = ud.session{2};
            checkFilterWindow(ud);
            if ~isempty(filters) %has filter
                if isequal(filtdesPrefs.fdatoolFlag, 1) && hasSPTfilter(ud.session) && ~isfield(filters(1), 'FDAspecs')
                    %           prompt the user for fdatool use and perform the spec translation if needed.
                    udnew = promptForFDA(ud, filtdesPrefs, forceFDAformat);
                    % If udnew is empty, the user canceled the conversion (g1729863).
                    % Set the user data to the previous state and return.
                    if isempty(udnew)
                        set(sptoolfig,'UserData', udBack);
                        return;
                    end
                elseif isequal(filtdesPrefs.fdatoolFlag, 0) &&  isfield(filters(1), 'FDAspecs')
                    %promptForRemoveFilters(filtdesPrefs);
                    %promptForRemoveFilters has been removed (g1388310)  
                    % avoid showing the warning dialog
                    ud=get(sptoolfig,'UserData');
                    ud.fdwarnflag = 0;
                    set(sptoolfig,'UserData', ud);
                end
            end
            filtdesPrefs = sptool('getprefs','filtdes',sptoolfig);
            ud = get(sptoolfig,'UserData');
            msgstr = '';
            if isequal(filtdesPrefs.fdatoolFlag, 0)
                [ud.session,msgstr] = sptvalid(ud.session,ud.components);
            end
            %-----
            % end
            %-----
            figname = sprintf('%s: %s%s',getString(message('signal:sptoolgui:SPTool')),ud.sessionPath,ud.sessionName);
            set(sptoolfig,'Name',figname)
            set(sptoolfig,'UserData',ud)
            for k = 1:length(ud.session)
                if ~isempty(ud.session{k})
                    set(ud.list(k),'Value',1);
                end
            end
            
            updateLists;
            selectionChanged(sptoolfig,'new');
            for idx = [4 6]
                set(ud.filemenu_handles(idx),'Enable','on');
            end
            set(ud.filemenu_handles(5),'Enable','off');
            ud = get(sptoolfig,'UserData');
            %-----------------------
            % Code added for FDATool
            %-----------------------
            %        check for the flags and see if conversion has caused them
            %        to set
            if isequal(ud.savedFlag, 1) && isequal(ud.unchangedFlag, 1)
                if isempty(msgstr)
                    ud.savedFlag = 1;
                    ud.unchangedFlag = 1;
                else
                    ud.savedFlag = 0;
                    ud.unchangedFlag = 0;
                end
            end
            %-----
            % end
            %-----
            ud.changedStruc = [];
        end
        set(sptoolfig,'UserData',ud);
        
        %----------------------------------------------------------------------
        %err = sptool('save')
        %    save session, using known file name
        %    If the session has never been saved, calls sptool('saveas')
        %  CAUTION: saves userdata on exit (to save ud.unchangedFlag)
        %  Outputs:
        %    err - ==1 if cancelled, 0 if save was successful.
    case 'save'
        sptoolfig = findall(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        if ~ud.savedFlag
            err = sptool('saveas');
            ud = get(sptoolfig,'UserData');
        else
            session = cell2struct(ud.session,{ud.components.name}); %#ok session is saved in mat-file
            save(fullfile(ud.sessionPath,ud.sessionName),'session')
            err = 0;
        end
        ud.unchangedFlag = ~err;
        if ud.unchangedFlag
            set(ud.filemenu_handles(5),'Enable','off')
        end
        set(sptoolfig,'UserData',ud)
        varargout{1} = err;
        %----------------------------------------------------------------------
        %err = sptool('saveas')
        %    save session, prompting for file name.
        %  CAUTION: saves userdata on exit (to save ud.unchangedFlag)
        %  Outputs:
        %    err - ==1 if cancelled, 0 if save was successful.
    case 'saveas'
        sptoolfig = findall(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        matlab_wd = pwd;
        cd(ud.wd)
        [f,p] = sptuiputfile(ud.sessionName,'Save Session');
        
        cd(matlab_wd)
        if ~isequal(f,0)
            if (length(f)<4) || ~isequal(f(end-3:end),'.spt')
                f = [f '.spt'];
            end
            session = cell2struct(ud.session,{ud.components.name}); %#ok session is saved in mat-file
            ud.sessionName = f;
            ud.sessionPath = p;
            save(fullfile(p,f),'session', '-v6')
            
            ud.sessionName = f;
            set(sptoolfig,'UserData',ud)
            
            figname = sprintf('%s: %s',getString(message('signal:sptoolgui:SPTool')),ud.sessionName);
            set(sptoolfig,'Name',figname)
            ud.unchangedFlag = 1;
            ud.wd = p;
        else
            % ud.unchangedFlag = ud.unchangedFlag;  % value doesn't change
        end
        if ud.unchangedFlag
            set(ud.filemenu_handles(5),'Enable','off')
        end
        ud.savedFlag = ud.savedFlag | ud.unchangedFlag;
        set(sptoolfig,'UserData',ud)
        varargout{1} = ~ud.unchangedFlag;
        
    case 'pref'
        sptoolfig = findall(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        org_prefs = cell2struct(ud.prefs(5).currentValue, ud.prefs(5).controls(:,1));
        %     if FDATool window is open, disable the filter designer controls
        filtdesFig = findobj(0,'Tag','filtdes');
        if (isfield(ud, 'hFDA') && ishandle(ud.hFDA)) || ~isempty(filtdesFig)
            [ud.prefs, ud.panelInd] = sptprefs(ud.prefs,ud.panelInd, 0);
        else
            [ud.prefs, ud.panelInd] = sptprefs(ud.prefs,ud.panelInd, 1);
        end
        %-----------------------------------------------------------------
        % Code added to obsolete legacy signal browser
        %-----------------------------------------------------------------
        sigbrowsePrefs = sptool('getprefs','sigbrowse',sptoolfig);
        if sigbrowsePrefs.legacyBrowserEnable
          newOwner = 'sigbrowse';
        else
          newOwner = 'sigbrowser.sigbrowseAdapter';
        end
        ud.prefs(3).clientList = {newOwner};
        componentNames = {ud.components.name};
        i = findcstr(componentNames,'Signals');
        ud.components(i).verbs.owningClient = newOwner;                          
        %-----------------------------------------------------------------
        % Code added for FDATool - pref changed, prompt the user if needed
        %-----------------------------------------------------------------
        set(sptoolfig,'UserData',ud);
        filtdesPrefs = sptool('getprefs','filtdes',sptoolfig);
        cur_prefs = cell2struct(ud.prefs(5).currentValue, ud.prefs(5).controls(:,1));
        filters = ud.session{2};
        if ~isempty(filters)
            if isequal(cur_prefs.fdatoolFlag, 1) && ~isequal(org_prefs.fdatoolFlag, cur_prefs.fdatoolFlag) && ~isfield(filters(1), 'FDAspecs')
                %         switch from FDesigner to FDATool
                promptForFDA(ud, filtdesPrefs, 0);
            elseif isequal(cur_prefs.fdatoolFlag, 0) && ~isequal(org_prefs.fdatoolFlag, cur_prefs.fdatoolFlag)
                %         switch from FDATool to FDesigner
                % Switching to FDesigner has been removed (g1388310)
                %promptForRemoveFilters(filtdesPrefs);
            end
        end
        
    case 'close'
        sptoolfig = findall(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        
        p = cell(1, length(ud.prefs));
        p_default = p;
        % Don't check the Filter Builder pane (index 5). It is no longer
        % used. Only update sigpref.mat if another preference is updated.
        for i = [1:4 6:length(ud.prefs)]
            [p{i},p_default{i}] = sptool('getprefs',...
                ud.prefs(i).panelName,sptoolfig);
        end
        if ~isequal(p,p_default)
            setsigpref({ud.prefs.panelName},p,1);
        end
        
        if ud.unchangedFlag == 0
            if ~saveChangesPrompt(ud.sessionName,'closing')
                return
            end
        end
        
        for i=1:length(ud.components)
            for j=1:length(ud.components(i).verbs)
                feval(ud.components(i).verbs(j).owningClient,'SPTclose',...
                    ud.components(i).verbs(j).action);
            end
        end
        if ~isempty(ud.importSettings)
            if ishandle(ud.importSettings.fig)
                delete(ud.importSettings.fig)
            end
        end
        delete(sptoolfig)
        clear global SIGPREFS;
        
    case 'create'
        % Create Signal, Filter or Spectrum structure from the command line:
        % sptool('create',...)
        %
        
        narginchk(2,9)
        shh = get(0,'ShowHiddenHandles');
        set(0,'ShowHiddenHandles','on')
        sptoolfig = findobj(0,'Tag','sptool');
        set(0,'ShowHiddenHandles',shh);
        
        if isempty(sptoolfig)  % SPTool is not open - only get required info
            ud.components = [];
            ud.components = sptcompp(ud.components); % calls one in signal/private
            ud.prefs = sptprefp;
            allPanels = {ud.prefs.panelName};
            plugInd = findcstr(allPanels,'plugins');
            plugPrefs = cell2struct(ud.prefs(plugInd).currentValue,...
                ud.prefs(plugInd).controls(:,1));
            if plugPrefs.plugFlag
                % now call each one found on path:
                ud.components = sptool('callall','sptcomp',ud.components);
            end
        else                   % SPTool is open; get the info from SPTool
            ud = get(sptoolfig,'UserData');
        end
        compNames = {ud.components.structName};
        
        if ~ischar(varargin{2}) && ~isnumeric(varargin{2})
            set(0,'ShowHiddenHandles',shh)
            error(message('signal:sptool:InvalidParamSecondArgMustBeString'))
        end
        
        compIndx = [];
        if isnumeric(varargin{2})
            % No component name specified; use default component (1st one)
            compIndx = 1;
            varargin{end+1} = varargin{end}; % Make room to insert comp name
            mvIndx = 2:nargin;
            varargin(mvIndx+1) = varargin(mvIndx);
            varargin{2} = compNames{compIndx}; % Insert component name
        else
            % Since the 2nd arg is not data for the default (1st) component
            % then it must be a string containing the component name; check it!
            for i = 1:length(compNames)
                if strcmpi(varargin{2}, compNames{i})
                    % Index into compNames which matches compnt name entered
                    compIndx = i;
                    break
                end
            end
            if isempty(compIndx)
                % Component name was specified incorrectly
                set(0,'ShowHiddenHandles',shh)
                error(message('signal:sptool:GUIErrComponent', varargin{ 2 }, sprintf( '      ''%s''\n', compNames{ : } )));
            end
        end
        
        [~,fields,FsFlag,defaultLabel] = ...
            feval(ud.components(compIndx).importFcn,'fields');
        
        [formIndx, formTags] = formIndex(fields,varargin{3});
        if isempty(formIndx)
            set(0,'ShowHiddenHandles',shh)
            error(message('signal:sptool:GUIErrForm', formTags))
        elseif length(fields) ~= 1  % A valid 'form' was specified
            varargin(3) = [];       % Remove 'form' from input argument list
        end
        
        if ischar(varargin{end})
            compCell = varargin(3:end-1); % Cell array containing the component
        else
            compCell = varargin(3:end);
        end
        numCompFields = length(fields(formIndx).fields);
        
        if length(compCell) < numCompFields
            % Padd with []s in case some default arguments were left out
            compCell{numCompFields} = [];
        elseif length(compCell) > numCompFields+1
            errObj = message('signal:sptool:TooManyInputArgs',compNames{compIndx});
              
            if ~ischar(varargin{end})
                errstr = getString(errObj);
                errObj = message('signal:sptool:LastArgMustBeString', errstr);
            end
            set(0,'ShowHiddenHandles',shh)
            error(errObj)
        end
        
        % If Fs required and no Fs was entered; use default Fs=1
        if FsFlag & (length(compCell) < numCompFields+1)
            Fs = 1;
            compCell = {compCell{:} Fs};
        end
        
        % Complete cell array to be passed to the import function
        paramsCell = {formIndx compCell{:}};
        [err,errstr,struc] = feval(ud.components(compIndx).importFcn,...
            'make',paramsCell);
        if err
            set(0,'ShowHiddenHandles',shh)
            error(message('signal:sptool:GUIErr', errstr))
        end
        
        if ischar(varargin{end})
            if ~isvalidvar(varargin{end})
                set(0,'ShowHiddenHandles',shh)
                error(message('signal:sptool:InvalidParam'))
            else
                % Component label
                struc.label = varargin{end};
            end
        else
            struc.label = defaultLabel;
        end
        
        if nargout == 1
            varargout{1} = struc;
        end
        
    case 'load'
        % Importing Signals, Filters or Spectra from the command line:
        % sptool('load',struc) checks for validity of struc and imports it
        %   if it is valid.
        % The following syntax creates new structure using 'make' facility of
        % importFcn, and imports it into SPTool.
        
        narginchk(2,9)
        shh = get(0,'ShowHiddenHandles');
        set(0,'ShowHiddenHandles','on')
        sptoolfig = findobj(0,'Tag','sptool');
        if isempty(sptoolfig)           % SPTool is closed - open it!
            sptool('init')
            sptoolfig = findobj(0,'Tag','sptool');
        end
        
        ud = get(sptoolfig,'UserData');
        compNames = {ud.components.structName};
        
        if isstruct(varargin{2})  % Second input is a structure
            struc = varargin{2};
            if nargin > 2
                set(0,'ShowHiddenHandles',shh)
                error(message('signal:sptool:Nargchk'))
            end
            
            errObj = isvalidstruc(struc,ud.components,compNames);
            if ~isempty(errObj)
                set(0,'ShowHiddenHandles',shh)
                error(errObj)
            end
        else                      % Second input is not a structure
            if ~ischar(varargin{2}) && ~isnumeric(varargin{2})
                set(0,'ShowHiddenHandles',shh)                
                error(message('signal:sptool:InvalidParamSecondArgMustBeStruct'))
            end
            % Create and load at the same time? - 'create' will parse the input
            struc =  sptool('create',varargin{2:end});
        end
        
        if nargout > 0
            varargout{1} = struc;
        end
        index = sptool('import',struc,1,sptoolfig);
        set(0,'ShowHiddenHandles',shh)
        
        if nargout>1
            % Return load-index into list of objects for component
            varargout{2} = index;
        end
        
    case 'import'
        % sptool('import')  import structure using dialog box from sptimport
        % sptool('import',struc)  import given structure
        % sptool('import',struc,selectFlag)  import given structure and change
        %   selection in appropriate column to the imported struc if
        %     selectFlag == 1 (selectFlag defaults to 0)
        % sptool('import',struc,selectFlag,sptoolfig)
        %    uses sptoolfig as figure handle of sptool; if omitted, uses findobj
        % sptool('import',struc,selectFlag,sptoolfig,updateChangedStruc)
        %   if updateChangedStruc == 1, changedStruc is updated in the case of
        %    a replacement of struc (changedStruc is ALWAYS cleared when struc
        %    is new).
        %   if updateChangedStruc == 0, changedStruc is untouched (default)
        
        if nargin < 4
            sptoolfig = findobj(0,'Tag','sptool');
        else
            sptoolfig = varargin{4};
        end
        ud = get(sptoolfig,'UserData');
        
        if nargin < 5
            updateChangedStruc = 0;
        else
            updateChangedStruc = varargin{5};
        end
        
        if nargin < 3
            selectFlag = 0;
        else
            selectFlag = varargin{3};
        end
        
        if isempty(sptoolfig)
            error(message('signal:sptool:GUIErrSptoolNotOpen', 'SPTool'))
        end
        labelList = sptool('labelList',sptoolfig);
        if nargin == 1
            [componentNum,struc,ud.importSettings,ud.importwd] = ...
                sptimport(ud.components,labelList,ud.importSettings,ud.importwd);
            figure(sptoolfig)
            
            if componentNum<1  % user cancelled - so save userdata and bail
                set(sptoolfig,'UserData',ud)
                return
            end
        else
            struc = varargin{2};
        end
        
        componentNum = findcstr({ud.components.structName},...
            struc.SPTIdentifier.type);
        %---------------------------------------
        % Code added for FDATool - import filter
        %---------------------------------------
        %     some fields need to be added in order to use the fdatool
        filtdesPrefs = sptool('getprefs','filtdes',sptoolfig);
        if isequal(struc.SPTIdentifier.type, 'Filter') && isequal(filtdesPrefs.fdatoolFlag, 1)
            if ~isfield(struc ,'FDAspecs')
                struc.FDAspecs = [];
                if ~isfield(struc.specs ,'currentModule')
                    struc.specs.currentModule = 'fdpzedit';
                end
                % When import a filter designer format object,
                % the field struc.FDAspecs.sidebar.design cannot be empty.
                struc.FDAspecs.sidebar.design = getfdaformat(struc);
            end
        end
        if ~isempty(findcstr(labelList,struc.label))
            % replace old structure with this label -----------------------------
            
            % first find column number of old structure:
            for i=1:length(ud.components)
                ind = findStructWithLabel(ud.session{i},struc.label);
                if ~isempty(ind)
                    oldComponentNum = i;
                    break
                end
            end
            
            if (nargin==1) || updateChangedStruc
                ud.changedStruc = ud.session{oldComponentNum}(ind);
            end
            if componentNum == oldComponentNum  % replace in same column
                oldComponent = ud.session{oldComponentNum}(ind);
                if (nargin==1) % | strcmp(oldComponent.label,struc.label)
                    
                    % The following doesn't work because filtdes.m calls
                    % sptool('import') when the filter is already imported
                    %if strcmp(oldComponent.label,struc.label)
                    %    s1 = sprintf('Warning: Component structure %s ',struc.label);
                    %    s2 = sprintf('already exists in SPTool; replacing %s.',struc.label);
                    %    disp([s1 s2])
                    %end
                    
                    % obtained by import dialog so retain lineinfo field
                    ud.session{oldComponentNum}(ind) = ...
                        feval(ud.components(oldComponentNum).importFcn,'merge',...
                        oldComponent,struc);
                    
                else
                    ud.session{oldComponentNum}(ind) = struc;
                end
            else  % overwrite object of different type (column)
                ud.session{oldComponentNum}(ind) = [];
                if isempty(ud.session{componentNum})
                    ud.session{componentNum} = struc;
                else
                    ud.session{componentNum}(end+1) = struc;
                end
            end
            
            set(sptoolfig,'UserData',ud)
            updateLists(sptoolfig,componentNum)
            if componentNum ~= oldComponentNum
                updateLists(sptoolfig,oldComponentNum)
                set(ud.list(componentNum),'Value',length(ud.session{componentNum}))
            end
            if selectFlag || (nargin==1) || updateChangedStruc
                selectionChanged(sptoolfig,'new')
            end
        else
            % append structure to appropriate structure array -------------------
            ud.changedStruc = [];
            if isempty(ud.session{componentNum})
                ud.session{componentNum} = struc;
                ind=1;
            else
                ud.session{componentNum}(end+1) = struc;
                ind=length(ud.session{componentNum});
            end
            set(sptoolfig,'UserData',ud)
            updateLists(sptoolfig)
            set(ud.list(componentNum),'Value',length(ud.session{componentNum}))
            selectionChanged(sptoolfig,'new')
        end
        for idx = 4:6
            set(ud.filemenu_handles(idx),'Enable','on');
        end
        ud = get(sptoolfig,'UserData');  % need to get this again since
        % selectionChanged call might have
        % changed userdata
        ud.unchangedFlag = 0;
        set(ud.filemenu_handles(5),'Enable','on')
        set(sptoolfig,'UserData',ud);
        
        if nargout>0
            % Return object-index to newly added object in the component
            % (ex, it was the 4th signal in the Signals list)
            varargout{1} = ind;
        end
        
        
        % sptool('export')
        %   Export objects from SPTool.
    case 'export'
        sptoolfig = findobj(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        [newprefs,componentSelect,fname,pathname] = ...
            sptexport(ud.prefs,ud.components,ud.session,get(ud.list,'Value'),ud.exportwd);
        
        if ~isequal(ud.prefs,newprefs)
            ud.prefs = newprefs;
        end
        
        if ~isequal(pathname,ud.exportwd)
            ud.exportwd = pathname;
            set(sptoolfig,'UserData',ud)
        end
        
        %------------------------------------------------------------------------
        % labelList = sptool('labelList',SPTfig)
        %   returns a cell array of strings containing all of the
        %   object labels currently in the SPTool.
    case 'labelList'
        fig = varargin{2};
        labelList = {};
        ud = get(fig,'UserData');
        for i=1:length(ud.components)
            if ~isempty(ud.session{i})
                labelList = {labelList{:} ud.session{i}.label};
            end
        end
        varargout{1} = labelList;
        
        %------------------------------------------------------------------------
        % sptool('edit')
        % callback of Edit menu
    case 'edit'
        sptoolfig = findobj(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        mh2 = ud.editmenu_handles(2);
        mh3 = ud.editmenu_handles(3);
        mh4 = ud.editmenu_handles(4);
        mh5 = ud.editmenu_handles(5);
        str = cell(0);
        for idx = 1:length(ud.components)
            tmp = get(ud.list(idx),'Value');
            if tmp == 1 & isempty(get(ud.list(idx),'String')) %#ok<AND2>
                tmp = [];
            end
            if idx == 1
                selobj = tmp(:);
                compidx = ones(length(tmp),1);
            else
                selobj = [selobj; tmp(:)]; %#ok<AGROW>
                compidx = [compidx; idx*ones(length(tmp),1)]; %#ok<AGROW>
            end
            
            ud.compidx = [compidx selobj];
            tmpstr = get(ud.list(idx),'String');
            if ~isempty(tmpstr)
                tmpstr = tmpstr(tmp);
                if isempty(str)
                    str = tmpstr;
                else
                    str = cat(1,str,tmpstr);
                end
            end
        end
        
        if ~isempty(selobj)
            % first initialize FsFlag array (determines if you can edit the
            % sampling frequency of a component or not)
            for i = 1:length(ud.components)
                [popupString,fields,FsFlag(i),defaultLabel] = ...
                    feval(ud.components(i).importFcn,'fields');
            end
            
            set(mh2,'Enable','on');
            set(mh3,'Enable','on');
            set(mh4,'Enable','on');
            set(mh5,'Enable','on');
            
            % remove extra menu items:
            delete(ud.dupsub(length(selobj)+1:end))
            ud.dupsub(length(selobj)+1:end)=[];
            delete(ud.clearsub(length(selobj)+1:end))
            ud.clearsub(length(selobj)+1:end)=[];
            delete(ud.namesub(length(selobj)+1:end))
            ud.namesub(length(selobj)+1:end)=[];
            ind = length(selobj)+1:length(ud.freqsub);
            delete(ud.freqsub(ind( find(ishandle(ud.freqsub(ind))) )))
            ud.freqsub(length(selobj)+1:end)=[];
            
            for idx1 = 1:length(selobj)
                if idx1 > length(ud.dupsub)
                    % create a new uimenu
                    ud.dupsub(idx1) = uimenu(mh2,'Label',str{idx1},'Tag',['dupmenu' int2str(idx1)],...
                        'Callback',['sptool(''duplicate'',',int2str(idx1),')']);
                    ud.clearsub(idx1) = uimenu(mh3,'Label',str{idx1},'Tag',['clearmenu' int2str(idx1)],...
                        'Callback',['sptool(''clear'',',int2str(idx1),')']);
                    ud.namesub(idx1) = uimenu(mh4,'Label',str{idx1},...
                        'Tag',['newnamemenu' int2str(idx1)],...
                        'Callback',['sptool(''newname'',',int2str(idx1),')']);
                    if FsFlag(compidx(idx1))
                        ud.freqsub(idx1) = uimenu(mh5,'Label',str{idx1},...
                            'Tag',['freqmenu' int2str(idx1)],'Callback',['sptool(''freq'',',int2str(idx1),')']);
                    else
                        % just put place holder here - don't create menu item since
                        % we can't edit the Sampling frequency for this component           
                        ud.freqsub(idx1) = gobjects;                            
                    end
                end
                if idx1 <= length(selobj)
                    % change label and ensure visibility of existing uimenu
                    set(ud.dupsub(idx1),'Visible','on','Label',str{idx1},'Tag',['dupmenu' int2str(idx1)]);
                    set(ud.clearsub(idx1),'Visible','on','Label',str{idx1},'Tag',['clearmenu' int2str(idx1)]);
                    set(ud.namesub(idx1),'Visible','on','Label',str{idx1},'Tag',['newnamemenu' int2str(idx1)]);
                    if FsFlag(compidx(idx1))
                        if ishandle(ud.freqsub(idx1))
                            set(ud.freqsub(idx1),'Visible','on','Label',str{idx1},'Tag',['freqmenu' int2str(idx1)]);
                        else
                            ud.freqsub(idx1) = uimenu(mh5,'Label',str{idx1},...
                                'Tag',['freqmenu' int2str(idx1)], ...
                                'Callback',['sptool(''freq'',',int2str(idx1),')']);
                        end
                    elseif ishandle(ud.freqsub(idx1))
                        set(ud.freqsub(idx1),'Visible','off')
                    end
                end
                
            end
        else
            set(mh2,'Enable','off');
            set(mh3,'Enable','off');
            set(mh4,'Enable','off');
            set(mh5,'Enable','off');
        end
        drawnow;
        set(sptoolfig,'UserData',ud);
        
        %------------------------------------------------------------------------
        % sptool('duplicate')
        % callback of duplicate submenu
    case 'duplicate'
        sptoolfig = findobj(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        lab = get(ud.dupsub(varargin{2}),'Label');
        bracket = findstr(lab,'[');
        lab1 = [lab(1:bracket-2),'copy'];
        lab2 = lab(bracket-1:end);
        idx = ud.compidx(varargin{2},:);
        
        % make sure new label is unique:
        labelList = {ud.session{idx(1)}.label};
        numCopies = 1;
        while ~isempty(findcstr(labelList,lab1))
            lab1 = [lab(1:bracket-2),'copy',num2str(numCopies)];
            numCopies = numCopies + 1;
        end
        
        ud.changedStruc = [];
        ud.session{idx(1)}(end+1)=ud.session{idx(1)}(idx(2));
        ud.session{idx(1)}(end).label = lab1;
        n = length(get(ud.list(idx(1)),'String'));
        set(ud.list(idx(1)),'Value',n+1);
        ud.unchangedFlag = 0;
        set(ud.filemenu_handles(5),'Enable','on')
        set(sptoolfig,'UserData',ud);
        updateLists(sptoolfig)
        selectionChanged(sptoolfig,'dup')
        
        %------------------------------------------------------------------------
        % sptool('clear')
        % callback of clear submenu
    case 'clear'
        sptoolfig = findobj(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        if strcmpi(varargin{2}, 'clear all')
            %----------------------------------------------------------
            % Code added for FDATool - changing back to Filter Designer
            %       remove all filters from sessions and update the UI
            %----------------------------------------------------------
            set(ud.list(2),'Value',[],'String',[]);
            ud.session{2} = [];
            ud.unchangedFlag = 0;
            set(sptoolfig,'UserData',ud);
            selectionChanged(sptoolfig,'clear');
        else
            lab = get(ud.dupsub(varargin{2}),'Label');
            idx = ud.compidx(varargin{2},:);
            
            ud.changedStruc = ud.session{idx(1)}(idx(2));
            ud.session{idx(1)}(idx(2)) = [];
            
            if ud.components(idx(1)).multipleSelection
                % just remove item from selection
                listVal = get(ud.list(idx(1)),'Value');
                listValInd = find(listVal==idx(2));
                listVal(listValInd+1:end) = listVal(listValInd+1:end)-1;
                listVal(listValInd) = [];
            else
                listVal = 1;
            end
            str = get(ud.list(idx(1)),'String');
            str(idx(2)) = [];
            set(ud.list(idx(1)),'Value',listVal,'String',str);
            
            ud.unchangedFlag = 0;
            set(ud.filemenu_handles(5),'Enable','on')
            set(sptoolfig,'UserData',ud)
            selectionChanged(sptoolfig,'clear')
        end
        
        %------------------------------------------------------------------------
        % sptool('newname',idx)
        % callback of Name... submenu; idx is the index into the name
        %  submenu items (an integer >= 1).
        % sptool('newname',lab)
        %  if the second input arg is a string with a particular label,
        %  then the object with that name is changed.
        %  This second syntax provides the sptool clients with a way
        %  to change the names of their selected objects.
        %
        %  - lab syntax added 6/19/99 by TPK
    case 'newname'
        sptoolfig = findobj(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        if ~ischar(varargin{2})
            lab = get(ud.dupsub(varargin{2}),'Label');
            % don't need to set up ud.compidx here since
            % we are assuming this is the callback of the uimenu and
            % hence sptool('edit') has just been called.
            idx = ud.compidx(varargin{2},:);
        else
            lab = varargin{2};
            % search for label within session structure, since
            % we need the 'label [type]' format for lab
            for i=1:length(ud.session)
                labels = {ud.session{i}.label}';
                j = find(strcmp(labels,lab));
                if ~isempty(j)
                    break
                end
            end
            listStr = get(ud.list(i),'String');
            lab = listStr{j};
            idx = [i j];
            sptool('edit')  % <-- need to call this to set up ud.compidx
            ud = get(sptoolfig,'UserData');
        end
        bracket = findstr(lab,'[');
        lab1 = lab(1:bracket-2);
        lab2 = lab(bracket-1:end);
        prompt={getString(message('signal:sptoolgui:VariableName'))};
        def = {lab1};
        title = getString(message('signal:sptoolgui:NameChange'));
        lineNo = 1;
        lab1 =inputdlg(prompt,title,lineNo,def);
        if isempty(lab1)
            return
        end
        err = ~isvalidvar(lab1{:});
        if ~err
            currentlabels = get(ud.list(idx(1)),'String');
            labelList = sptool('labelList',sptoolfig);
            strInd = findcstr(labelList,deblank(lab1{:}));
            if ~isempty(strInd)
                if ~isequal(lab1{1},ud.session{idx(1)}(idx(2)).label)
                    % error prompt if name is already taken by another variable
                    errstr = {getString(message('signal:sptoolgui:ThereIsAlreadyAnObjectInTheSPTool'))};
                    errordlg(errstr,getString(message('signal:sptoolgui:NonuniqueName')),'replace');
                else
                    % no op (user entered the same name)
                end
                return
            end
        else
            errstr = {getString(message('signal:sptoolgui:SorryTheNameYouEnteredIsNotValid'))
                getString(message('signal:sptoolgui:PleaseUseALegalMATLABVariableName'))};
            errordlg(errstr,getString(message('signal:sptoolgui:BadVariableName')),'replace');
            return
        end
        
        if isequal(ud.session{idx(1)}(idx(2)).label,lab1{:})
            % new label is the same as the old one - do nothing!
            return
        end
        ud.changedStruc = ud.session{idx(1)}(idx(2));
        ud.session{idx(1)}(idx(2)).label = lab1{:};
        ud.unchangedFlag = 0;
        set(ud.filemenu_handles(5),'Enable','on')
        set(sptoolfig,'UserData',ud);
        listStr = get(ud.list(idx(1)),'String');
        listStr{idx(2)} = [deblank(lab1{:}) lab2];
        set(ud.list(idx(1)),'String',listStr)
        selectionChanged(sptoolfig,'label')
        
        %------------------------------------------------------------------------
        % sptool('freq')
        % callback of Sampling Frequency... submenu
    case 'freq'
        sptoolfig = findobj(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        lab = get(ud.dupsub(varargin{2}),'Label');
        idx = ud.compidx(varargin{2},:);
        prompt={[getString(message('signal:sptoolgui:SamplingFrequency')) ':']};
        def = {sprintf('%.9g',ud.session{idx(1)}(idx(2)).Fs)};
        title = getString(message('signal:sptoolgui:SpecifySamplingFrequency'));
        lineNo = 1;
        if isfield(ud.session{idx(1)}, 'FDAspecs')
            str = sprintf('%s %s', prompt{1}, def{1});
            msgbox(str, prompt{1});
            Fs = def;
        else
            Fs=inputdlg(prompt,title,lineNo,def);
            if isempty(Fs)
                return
            end
        end
        [Fs,err] = validarg(Fs{:},[0 Inf],[1 1],getString(message('signal:sptoolgui:SamplingFrequencyExpression')));
        if err ~= 0
            return
        end
        if ud.session{idx(1)}(idx(2)).Fs == Fs
            % new Fs is the same as the old one - do nothing!
            return
        end
        
        ud.changedStruc = ud.session{idx(1)}(idx(2));
        ud.session{idx(1)}(idx(2)) = feval(ud.components(idx(1)).importFcn,'changeFs',...
            ud.session{idx(1)}(idx(2)),Fs);
        ud.unchangedFlag = 0;
        set(ud.filemenu_handles(5),'Enable','on')
        set(sptoolfig,'UserData',ud);
        selectionChanged(sptoolfig,'Fs')
        
        %------------------------------------------------------------------------
        % sptool('changeFs',struc)
        % external interface to allow clients to change ONLY THE SAMPLING
        % FREQUENCY of the passed in object.
        %  Added 5/31/99, TPK
        % sptool('changeFs',lab,Fs)
        %  if the second input arg is a string with a particular label,
        %  then the object with that name is changed to given Fs.
        %  This second syntax provides the sptool clients with a way
        %  to change the sampling frequencies of selected objects.
        %
        %  - lab syntax added 6/26/99 by TPK
    case 'changeFs'
        sptoolfig = findobj(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        
        if ~ischar(varargin{2})
            struc = varargin{2};
            Fs = struc.Fs;
        else
            lab = varargin{2};
            % search for label within session structure
            for i=1:length(ud.session)
                labels = {ud.session{i}.label}';
                j = find(strcmp(labels,lab));
                if ~isempty(j)
                    break
                end
            end
            struc = ud.session{i}(j);
            Fs = varargin{3};
        end
        
        inType = struc.SPTIdentifier.type;
        idx(1) = find(strcmp(inType,{ud.components.structName}));
        idx(2) = find(strcmp(struc.label,{ud.session{idx(1)}.label}));
        
        ud.changedStruc = ud.session{idx(1)}(idx(2));
        ud.session{idx(1)}(idx(2)) = feval(ud.components(idx(1)).importFcn,'changeFs',...
            ud.session{idx(1)}(idx(2)),Fs);
        ud.unchangedFlag = 0;
        set(ud.filemenu_handles(5),'Enable','on')
        set(sptoolfig,'UserData',ud);
        selectionChanged(sptoolfig,'Fs')
        
        %------------------------------------------------------------------------
        % sptool('help','overview')    <-- Help Tool (SPTool)
        % sptool('help','helptoolbox') <-- Help Toolbox
        % sptool('help','helpdemos')   <-- Demos
        % sptool('help','helpabout')   <-- About Signal Toolbox
        % sptool('help') <-- context sensitive help
    case 'help'
        sptoolfig = findobj(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        whichHelp = varargin{2};
        titleStr = 'SPTOOL Help';
        helpFcn = 'spthelpstr';
        
        switch whichHelp
            case 'overview'
                helpview(fullfile(docroot,'toolbox','signal', 'signal.map'),'sptool');
                % 		spthelp('tag',sptoolfig,titleStr,helpFcn,'overview');
                
            case 'helptoolbox' % Used by all SPTool clients
                doc signal/
                
            case 'helpdemos'   % Used by all SPTool clients
                demo toolbox signal
                
            case 'helpabout'   % Used by all SPTool clients
                aboutsignaltbx;
                
            otherwise
                % Context Sensitive Help.
                saveEnableControls = [];
                if ud.pointer ~= 2   % if not in help mode
                    numComponents = length(ud.components);
                    % enter help mode
                    controlNumber = 0;
                    for idx1 = 1:numComponents
                        controlNumber = controlNumber + 1;
                        saveEnableControls(controlNumber) = ud.list(idx1);
                        for idx2 = 1:length(ud.components(idx1).verbs)
                            controlNumber = controlNumber + 1;
                            saveEnableControls(controlNumber) = ud.buttonHandles(idx1).h(idx2);
                        end
                    end
                    spthelp('enter',sptoolfig,saveEnableControls,[],titleStr,helpFcn)
                else
                    spthelp('exit')
                end
        end
        
        %------------------------------------------------------------------------
        %  sptool('verb',i,j)  - i component #, j verb #
    case 'verb'
        sptoolfig = findobj(0,'Tag','sptool');
        setptr(sptoolfig,'watch')
        drawnow
        ud = get(sptoolfig,'UserData');
        i = varargin{2};
        j = varargin{3};
        feval(ud.components(i).verbs(j).owningClient,'action',...
            ud.components(i).verbs(j).action);
        if ishghandle(sptoolfig)
            setptr(sptoolfig,'arrow')
        end
        
        %------------------------------------------------------------------------
        %  sptool('list',i)  - i component #     LISTBOX CALLBACK
    case 'list'
        sptoolfig = findobj(0,'Tag','sptool');
        ud = get(sptoolfig,'UserData');
        idx = varargin{2};
        if 0  % short cut (double click) is disabled for now
            % if strcmp(get(sptoolfig,'SelectionType'),'open')
            dc = ud.components(idx).defaultClient;
            whichClient = 0;
            k = 0;
            while ~whichClient
                k = k + 1;
                if strcmp(dc,ud.components(idx).verbs(k).owningClient)
                    whichClient = k;
                end
            end
            sptool('verb',idx,whichClient);
        else
            selectionChanged(sptoolfig,'value')
        end
        
        %----------------------------------------------------------------------------
        % struct = sptool('changedStruc',sptoolfig) - return recently
        %  changed structure (removed, imported, name or Fs changed)
        %  sptoolfig - optional, found with findobj if not present
    case 'changedStruc'
        if nargin < 2
            shh = get(0,'ShowHiddenHandles');
            set(0,'ShowHiddenHandles','on')
            sptoolfig = findobj(0,'Tag','sptool');
            set(0,'ShowHiddenHandles',shh);
        else
            sptoolfig = varargin{2};
        end
        ud = get(sptoolfig,'UserData');
        varargout{1} = ud.changedStruc;
        
        %----------------------------------------------------------------------------
        % Fs  = sptool('commonFs)
    case 'commonFs'
        % For sampling frequency, if there are filters in the SPTool,
        % use their common sampling frequency (or the last one if
        % they don't have one).  If there no filters, do the same
        % for Signals.  If no signals either, use Fs = 1.
        ftemp = sptool('Filters');
        if ~isempty(ftemp)
            Fs = ftemp(end).Fs;
            if isempty(Fs)
                Fs = 1;
            end
        else
            stemp = sptool('Signals');
            if ~isempty(stemp)
                Fs = stemp(end).Fs;
            else
                Fs = 1;
            end
        end
        varargout{1} = Fs;
        
        %----------------------------------------------------------------------------
        %  Client API
        %  can ask for the currently selected objects
        % [s,ind] = sptool(componentName,allFlag)
        % [s,ind] = sptool(componentName,allFlag,fig)
        % Returns a structure array of the current data items in the SPTool
        %   Inputs:
        %      componentName - string; name of component e.g. 'Filters' or 'Signals'
        %      allFlag - 1 ==> return all objects of the requested type in s
        %                0 ==> return only the currently selected objects in s
        %                allFlag is optional; it defaults to 1
        %      fig - figure handle of SPTool; optional - if omitted, will be found with findobj
        %   Outputs:
        %       s - structure array
        %       ind - optional output; indices of s which are currently selected
        %             in SPTool
    otherwise
        if nargin < 3
            shh = get(0,'ShowHiddenHandles');
            set(0,'ShowHiddenHandles','on')
            sptoolfig = findobj(0,'Tag','sptool');
            set(0,'ShowHiddenHandles',shh);
        else
            if isempty(varargin{3}) || ishandle(varargin{3})
                sptoolfig = varargin{3};
            else
                error(message('signal:sptool:GUIErrInvalidInput', '''help sptool'''))
            end
        end
        
        if isempty(sptoolfig)
            error(message('signal:sptool:GUIErrSptoolNotOpen', 'SPTool'))
        end
        
        ud = get(sptoolfig,'UserData');
        l = {ud.components.name};
        whichComponent = findcstr(l,action);
        if isempty(whichComponent)
            error(message('signal:sptool:GUIErrNoComponentAvailable', action, sprintf( '''%s'' ', l{ : } )));
        end
        if nargin > 1
            allFlag = varargin{2};
        else
            allFlag = 1;
        end
        
        varargout{1} = ud.session{whichComponent};
        ind = get(ud.list(whichComponent),'Value');
        if allFlag
            varargout{2} = ind;
        else
            if isempty(varargout{1})
                varargout = { [] [] };
            else
                varargout = {varargout{1}(ind) 1:length(ind)};
            end
        end
        
end


%-------------------------------------------------------------------------
function ud = init_sptool_data_settings
% INIT_SPTOOL_DATA_SETTINGS Build the preference structure to create
%                           uicontrols for the preference dialog window.
%                           Also create the "factory default" settings in
%                           the .controls field.

ud.prefs = sptprefp;

% Loop through each panel of preferences
ud.fdwarnflag = 0;
for i=1:length(ud.prefs)
    p = getsigpref(ud.prefs(i).panelName);
    if ~isempty(p)
        ud.prefs(i).currentValue = struct2cell(p);
        % check to make sure currentValue has the correct number of
        % elements.  If it doesn't then the preferences must be out
        % of date, so set the current value to the factory setting.
        if length(ud.prefs(i).currentValue) ~= length(ud.prefs(i).controls(:,1))
            ud.prefs(i).currentValue = ud.prefs(i).controls(:,7);
            warning(message('signal:sptool:InvalidPreferences', ud.prefs( i ).panelDescription));
        end
        if isfield(p,'filterDesignerFlag')
            if p.filterDesignerFlag==1
                ud.fdwarnflag = 1;
            end
        end
    end
end
allPanels = {ud.prefs.panelName};
plugInd = findcstr(allPanels,'plugins');
plugPrefs = cell2struct(ud.prefs(plugInd).currentValue,ud.prefs(plugInd).controls(:,1));
if plugPrefs.plugFlag
    % add any additional preferences
    ud.prefs = sptool('callall','sptpref',ud.prefs);
end

ud.panelInd = 1;
ud.components = [];
ud.components = sptcompp(ud.components); % calls one in signal/private
if plugPrefs.plugFlag
    % now call each one found on path:
    ud.components = sptool('callall','sptcomp',ud.components);
end

ud.sessionName = 'untitled.spt';
ud.wd = pwd;                 % working directory for Opening, Saving, etc.
ud.importwd = pwd;           % working directory for importing file data
ud.exportwd = pwd;           % working directory for exporting data to disk
ud.savedFlag = 0;            % flag indicating if session has ever been saved
ud.unchangedFlag = 1;        % indicates if sess. is unchanged since last save

% the 'changeStruc' field will contain the structure which has been
% altered by the most recent operation, as it was before the operation.
% operations include: clear, name change, import over (such as
% applying a filter), sampling frequency change
ud.changedStruc = [];
ud.importSettings = [];
ud.sessionPath = '';
ud.pointer = 1;


%-------------------------------------------------------------------------
function [fig,ud] = create_sptool_gui(ud)
% CREATE_SPTOOL_GUI Creates the GUI for SPTool - the data manager

numComponents = length(ud.components);
maxVerbs = 1;
for i=1:numComponents
    maxVerbs = max(maxVerbs,length(ud.components(i).verbs));
end
ud.maxVerbs = maxVerbs;

% Determine figure position
figHeight   = ud.maxVerbs*20+240;
screenRect  = get(0,'ScreenSize');
fp = [18 screenRect(4)-figHeight-50 140*numComponents figHeight];

figname = sprintf('%s: %s',getString(message('signal:sptoolgui:SPTool')),ud.sessionName);

uibgcolor = get(0,'DefaultUicontrolBackgroundColor');

% CREATE FIGURE
fig = figure('CreateFcn','',...
    'CloseRequestFcn','sptool(''close'')',...
    'WindowStyle','normal',...
    'Tag','sptool',...
    'NumberTitle','off',...
    'IntegerHandle','off',...
    'Units','pixels',...
    'Position',fp,...
    'MenuBar','none',...
    'Color',uibgcolor,...
    'InvertHardcopy','off',...
    'PaperPositionMode','auto',...
    'Visible','off',...
    'Name',figname);

for i=1:numComponents
    maxVerbs = max(maxVerbs,length(ud.components(i).verbs));
    ud.list(i) = uicontrol('Style','listbox','BackgroundColor','w',...
        'Units','pixels',...
        'Interruptible','off',...
        'Callback',['sptool(''list'',' num2str(i) ')'],...
        'Value',[],'Tag',['list' num2str(i)]);
    if ud.components(i).multipleSelection
        set(ud.list(i),'Max',2)
    end
    ud.label(i) = uicontrol('Style','text','String', ...
        getTranslatedString('signal:sptoolgui',ud.components(i).name),...
        'Tag',['list' num2str(i) '_txt'],...
        'Units','pixels',...
        'FontWeight','bold');
    for j=1:length(ud.components(i).verbs)
        ud.buttonHandles(i).h(j) = uicontrol('String',...
            ud.components(i).verbs(j).buttonLabel,...
            'Units','pixels',...
            'Interruptible', 'off',...
            'BusyAction', 'cancel',...
            'Callback',['sptool(''verb'',' num2str(i) ',' num2str(j) ')'],...
            'Tag',[ud.components(i).verbs(j).owningClient ':' ...
            ud.components(i).verbs(j).action]);
    end
end

% ====================================================================
% MENUs
%  create cell array with {menu label, callback, tag}

%  MENU LABEL                     CALLBACK                      TAG
fm={
    getString(message('signal:sptoolgui:File'))                              ' '                        'filemenu'
    ['>' getString(message('signal:sptoolgui:OpenSession')) '...' '^o']               'sptool(''open'')'         'loadmenu'
    '>------'                           ' '                        ' '
    ['>' getString(message('signal:sptoolgui:Import')) '...' '^i']                     'sptool(''import'')'       'importmenu'
    ['>' getString(message('signal:sptoolgui:Export')) '...' '^e']                     'sptool(''export'')'       'exportmenu'
    '>------'                           ' '                        ' '
    ['>' getString(message('signal:sptoolgui:SaveSessions')) '^s']                  'sptool(''save'');'        'savemenu'
    ['>' getString(message('signal:sptoolgui:SaveSessionAs')) '...']               'sptool(''saveas'');'       'saveasmenu'
    '>------'                           ' '                        ' '
    ['>' getString(message('signal:sptoolgui:Preferences')) '...']                   'sptool(''pref'') '        'prefmenu'
    ['>' getString(message('signal:sptoolgui:CloseMenu')) '^w']                         'sptool(''close'')'        'closemenu'};

ud.filemenu_handles = makemenu(fig, char(fm(:,1)),char(fm(:,2)), char(fm(:,3)));
for idx = 4:6
    set(ud.filemenu_handles(idx),'Enable','off');
end


%  MENU LABEL                     CALLBACK                      TAG
em={
    getString(message('signal:sptoolgui:Edit'))                             'sptool(''edit'')'           'editmenu'
    ['>' getString(message('signal:sptoolgui:Duplicate'))]                       'sptool(''edit'')'           'dupmenu'
    ['>' getString(message('signal:sptoolgui:Clear'))]                           'sptool(''edit'')'           'clearmenu'
    '>------'                          ' '                          ' '
    ['>' getString(message('signal:sptoolgui:Name')) '...']                         'sptool(''edit'')'           'newnamemenu'
    ['>' getString(message('signal:sptoolgui:SamplingFrequency')) '...']           'sptool(''edit'')'           'freqmenu'};

ud.editmenu_handles = makemenu(fig, char(em(:,1)),char(em(:,2)), char(em(:,3)));
ud.dupsub(1) = uimenu(ud.editmenu_handles(2),'Label',' ',...
    'Tag','dupmenu','Callback',['sptool(''duplicate'',',int2str(1),')']);
ud.clearsub(1) = uimenu(ud.editmenu_handles(3),'Label',' ',...
    'Tag','clearmenu','Callback',['sptool(''clear'',',int2str(1),')']);
ud.namesub(1) = uimenu(ud.editmenu_handles(4),'Label',' ',...
    'Tag','newnamemenu','Callback',['sptool(''newname'',',int2str(1),')']);
ud.freqsub(1) = uimenu(ud.editmenu_handles(5),'Label',' ',...
    'Tag','freqmenu','Callback',['sptool(''freq'',',int2str(1),')']);
for idx = 2:5
    set(ud.editmenu_handles(idx),'Enable','off');
end

matlab.ui.internal.createWinMenu(fig);

% Build the cell array string for the Help menu
hm=sptooldatamanager_help;

ud.helpmenu_handles = makemenu(fig, char(hm(:,1)),char(hm(:,2)), char(hm(:,3)));

ud.session = cell(numComponents,1);
for i=1:numComponents
    ud.session{i} = [];
end

%-------------------------------------------------------------------------
function mh = sptooldatamanager_help
% Set up a string cell array that can be passed to makemenu to create the Help
% menu for SPTool's data manager.

% Define specifics for the Help menu in SPTool's data manager.
toolname      = getString(message('signal:sptoolgui:SPTool'));
toolhelp_cb   = 'sptool(''help'',''overview'')';
toolhelp_tag  = 'helpoverview';
whatsthis_cb  = 'sptool(''help'',''mouse'')';
whatsthis_tag = 'helpmouse';

% Add other Help menu choices that are common to all SPTool clients.
mh=sptool_helpmenu(toolname,toolhelp_cb,toolhelp_tag,whatsthis_cb,whatsthis_tag);

%-------------------------------------------------------------------------
function updateLists(fig,componentNum)
%updateLists  - creates listbox strings for all components
%   based on ud.session

if nargin<1
    fig = findobj(0,'Tag','sptool');
end
ud = get(fig,'UserData');
if nargin<2
    componentNum = 1:length(ud.components);
end

for i=componentNum
    listStr = cell(1,length(ud.session{i}));
    for j=1:length(ud.session{i})
        listStr{j} = ...
            [ud.session{i}(j).label ' [' getTranslatedString('signal:sptoolgui',ud.session{i}(j).type) ']'];
    end
    if isempty(listStr)
        set(ud.list(i),'Value',[])
    elseif length(listStr)<max(get(ud.list(i),'Value'))
        set(ud.list(i),'Value',1)
    end
    set(ud.list(i),'String',listStr)
end


%-------------------------------------------------------------------------
function ind = findStructWithLabel(structArray,label)
% ind = findStructWithLabel(structArray,label)
% returns the index of the (unique) structure element in structArray with
% field .label equal to the string argument label.

if isempty(structArray)
    ind = [];
else
    l = {structArray.label};
    ind = findcstr(l,label);
end


%-------------------------------------------------------------------------
function selectionChanged(fig,msg)
%selectionChanged
%   enables / disables all verb buttons based on listbox values;
%   in the process the client tools have a chance to update themselves
%   based on the selection
%   msg - string; will be passed to the clients as well
%     possibilities: 'new' - new entries to list, or change in current entries - default
%                    'value' - new listbox value, no other change
%                    'Fs' - sampling freq of object in current selection changed
%                    'label' - label of an object in the current selection changed
%                    'dup' - an object has been duplicated
%                    'clear' - an object has been deleted

if nargin<1
    fig = findobj(0,'Tag','sptool');
end
if nargin<2
    msg = 'new';
end
ud = get(fig,'UserData');
for i=1:length(ud.components)
    for j=1:length(ud.components(i).verbs)
        enable = feval(ud.components(i).verbs(j).owningClient,'selection',...
            ud.components(i).verbs(j).action,msg,fig);
        set(ud.buttonHandles(i).h(j),'Enable',enable)
    end
end


%-------------------------------------------------------------------------
function continuevar = saveChangesPrompt(sessionName,operation)
% continuevar = saveChangesPrompt(sessionName,operation)
%    Informs user via a dialog box that the SPTool session
%    with name sessionName has been changed.
%    The user then has the choice of
%      1) saving the session
%      2) not saving the session
%      3) cancelling the operation
%    continuevar will be true (1) if the session was saved successfully
%    or the Don't save button was pressed (option 2 above).
% operation should be a string indicating the operation being
% performed.  It should be either 'closing' or 'opening'.  This
% string will actually appear in the dialog box.
%
%    Note: userdata will be changed if session is saved.

continuevar = 1;
% Compose the string with the operation variable with [ ] instead of
% sprintf to make it easier to translate. g424968
switch operation
    case 'opening'
        str = getString(message('signal:sptoolgui:SaveChangesToSPToolSessionOpening',sessionName));
    case 'closing'
        str = getString(message('signal:sptoolgui:SaveChangesToSPToolSessionClosing',sessionName));
end

ButtonName = questdlg(str,...
    getString(message('signal:sptoolgui:UnsavedSession')), ...
    getString(message('signal:sptoolgui:Save')), ...
    getString(message('signal:sptoolgui:DontSave')), ...
    getString(message('signal:sptoolgui:Cancel')), ...
    getString(message('signal:sptoolgui:Save')));
switch ButtonName
    case getString(message('signal:sptoolgui:Save'))
        if sptool('save')
            continuevar = 0;
        end
    case getString(message('signal:sptoolgui:Cancel'))
        continuevar = 0;
end


%-------------------------------------------------------------------------
function errObj = isvalidstruc(struc,ImportFcns,compNames)
% ISVALIDSTRUC returns an empty string if all the fields in the given
% structure are valid, otherwise it returns a string containing an error
% message.
% Inputs:
%   struc - component structure
%   ImportFcs - structure containing the import functions
%   compNames - component names
% Outputs:
%   errstr - error message if structure is invalid

errObj = [];
if ~isfield(struc,'label') || ~isstr(struc.label) || isempty(struc.label)
    errObj = message('signal:sptool:EmptyLabel');
    
elseif ~isvalidvar(struc.label)
    errObj = message('signal:sptool:InvalidVarName');
    
elseif isfield(struc,'SPTIdentifier') && (length(struc) == 1) && ...
        isfield(struc.SPTIdentifier,'type')
    i = find(strcmp(struc.SPTIdentifier.type,compNames));
    if ~isempty(i)
        [valid,struc] = feval(ImportFcns(i).importFcn,'valid',struc);
        if ~valid
            errObj = message('signal:sptool:InvalidStruct');
        end
    else
      compName = struc.SPTIdentifier.type;
      errObj = message('signal:sptool:InvalidComponent',compName,sprintf('      ''%s''\n',compNames{:}));
    end
end


%-------------------------------------------------------------------------
function [session_out,msgstr] = sptvalid(session_in,components)
% [session,msgstr] = sptvalid(session,components)
%   "Validates" a session by updating all structs, and removing any
%   that are invalid.
%   This function will ensure that the elements in the input session
%   cell array match the components in the input components array, if
%   necessary by reordering, removing, or adding empty elements to
%   the session struct.
% Inputs:
%   session - cell array, each element is a vector of SPTool structs
%   components - structure array, one element for each element in
%      session, specifies the component of the corresponding element in session
% Outputs:
%   session - updated session cell array
%   msgstr - empty if session has not been changed, otherwise contains a
%            message saying that the input session file was not up-to-date
%            and will need to be saved.
%            If not empty, this message will be displayed in a dialog box

invalidList = {};
updatedList = {};

session_out = session_in;

for i=length(session_out):-1:1
    % removed bad structure arrays:
    if ~isempty(session_out{i}) && ~isfield(session_out{i},'SPTIdentifier')
        session_out(i) = [];
    elseif ~isempty(session_out{i}) && ...
            ~isfield(session_out{i}(1).SPTIdentifier,'type')
        session_out(i) = [];
    end
end

sessionTypes = cell(1, length(session_out));
for i=1:length(session_out)
    if ~isempty(session_out{i})
        sessionTypes{i} = session_out{i}(1).SPTIdentifier.type;
    else
        sessionTypes{i} = '';
    end
end
componentTypes = {components.structName};

% find and remove sessions not in components:
[C,i] = setdiff(sessionTypes,componentTypes);
if ~isempty(i)
    for ii=sort(-i)
        invalidList = addinvalid(invalidList,session_out{-ii});
    end
end

session_out(i) = [];
sessionTypes(i) = [];

% find components not in sessions, and add empty lists for those components
session_temp = session_out;
session_out = cell(length(components),1);
[C,ia,ib] = intersect(char(sessionTypes),char(componentTypes),'rows');
session_out(ib) = session_temp(ia);

% now use importfcn of each component to validate / update each
% structure
for i=1:length(session_out)
    objArray = [];
    for j=1:length(session_out{i})
        [valid,s] = feval(components(i).importFcn,'valid',session_out{i}(j));
        if valid
            if isempty(objArray)
                objArray = s;
            else
                objArray(end+1) = s;
            end
            if ~isequal(s,session_out{i}(j))
                updatedList = addinvalid(updatedList,session_out{i}(j));
            end
        else
            invalidList = addinvalid(invalidList,session_out{i}(j));
        end
        % disp(session_out{i}(j).label)
    end
    session_out{i} = objArray;
end

% for each cell
for i=1:length(session_out)
    
    % if the cell is not empty, then compare individual cells of session_in & session_out
    if ~isempty(session_out{i}) && ~isequal(session_in{i},session_out{i})
        if isempty(invalidList)
            invalidList = {'<none>'};
        end
        if isempty(updatedList)
            updatedList = {'<none>'};
        end
        msgstr = getString(message('signal:sptoolgui:ThisSessionFileWasOutofdateOrContainedInvalid'));
        
        waitfor(msgbox(msgstr,...
            getString(message('signal:sptoolgui:SessionChanges')),'error','modal'))
    else
        msgstr = '';
    end
    
end

%-------------------------------------------------------------------------
function invalidList = addinvalid(invalidList,struc)
if ~isempty(struc)
    invalidList{end+1} = [struc.label '(' struc.SPTIdentifier.type ')'];
else
    invalidList{end+1} = '';
end


%-------------------------------------------------------------------------
function [formIndx, formTags] = formIndex(fields,form)
% FORMINDEX determine what the 'form' is for a given component.  Some
% components have different forms. For example filters can be entered as a
% transfer function (tf), state space (ss), second-order sections (sos), or
% zero-pole gain (zpk).
% Inputs:
%   fields - the component structure fields
%   form - the third input argument to sptool which, depending on the
%          component, could be the 'form' which describes how the component
%          was entered eg. for filters it's: 'tf','ss','sos', or 'zpk'
% Outputs:
%   formIndx - a scalar indicating which form was used when entering the
%              component
%   formTags - a list of strings which are possible forms

formTags = [];
if length(fields) == 1       % Component only has one form
    formIndx = 1;
else                         % Component has multiple forms
    for i=1:length(fields)
        formTag = fields(i).formTag;
        formTags = [formTags '''' formTag '''' ' '];
    end
    
    formIndx = [];
    if ~isempty(form)  % Form was specified
        if ischar(form)
            formIndx = find(strcmp(form,{fields.formTag}));
        elseif length(form) == 1 && find(form==[1:length(fields)])
            % Using numbers to specify form
            formIndx = form;
        end
    end
end


%-------------------------------------------------------------------------
function [f,p] = sptuiputfile(sessionName,dlgboxTitle)
% SPTUIPUTFILE The following is a workaround for uiputfile which works
%              differently on the PC, UNIX and MAC.
% PCWIN: uiputfile adds the extension as specified in 'Save as Type'
%        and checks if the file exists.
% UNIX:  uiputfile DOES NOT add the extension as specified in the
%        'Filter', however it DOES check if the file, with the
%        extension specified in the 'Filter', exists.
% MAC:   uiputfile checks if the file name, as entered, exists
%
% Inputs:
%   sessionName - string containing the default session name
%   dlgboxTitle - string containing the title of the dialog box
% Outputs:
%   f - string containing the file name with extension .spt
%   p - string containing the path to file

[f,p] = uiputfile(sessionName,dlgboxTitle);

if ~isequal(f,0) && ~strcmp(computer,'PCWIN') && ...
        ~isequal(f(end-3:end),'.spt')
    
    % UNIX and MAC's uiputfile DOES NOT automatically add
    % extensions to file names
    if isempty(findstr(f,'.'))
        % no '.' extension, so add '.spt' to file name
        f = [f '.spt'];
    end
    
    % On the MAC only... after adding the extension to the file name we
    % must check again if the file exists since the MAC's uiputfile
    % only checks the file name as entered (eg without the extension)
    tYes = getString(message('signal:sptoolgui:Yes')); % Translating string 'Yes'
    tNo = getString(message('signal:sptoolgui:No')); % Translating string 'No'
    ButtonName = tNo;
    while ~isequal(f,0) && strcmp(computer,'MAC2') && strcmp(ButtonName,tNo)
        if exist(f,'file') == 2
            question=[p,f,getString(message('signal:sptoolgui:ThisFileAlreadyExistsReplaceExistingFile'))];
            ButtonName = questdlg(question,...
                getString(message('signal:sptoolgui:SaveSessions')),...
                tYes,tNo,tNo);  % Default is 'No'
        else
            ButtonName = tYes;
        end
        if strcmp(ButtonName,tNo)
            [f,p]=uiputfile(f,dlgboxTitle);
            if ~isequal(f,0) && isempty(findstr(f,'.'))
                % no '.' extension, so add '.spt' to file name
                f = [f '.spt'];
            else
                %file name with extension has been entered; exit while-loop
                ButtonName = tYes;
            end
        end
    end   % while-loop
end   % if not PCWIN and no extension specified


% %-------------------------------------------------------------------------
function cacheclasses
% Cache some of the classes required to launch FVTool into memory. This
% will reduce the launch for FVTool (while increasing it for SPTool).

stpk = findpackage('sigtools');
findclass(stpk,'fvtool');

sgpk = findpackage('siggui');
findclass(sgpk,'fvtool');



%-------------------------------------------------------------------
% Added for FDATool - prompt to switch to FDATool and convert format
%-------------------------------------------------------------------
function udnew = promptForFDA(ud, filtdesPrefs, forceFDAformat)

str = { getString(message('signal:sptoolgui:FiltersInThisSessionNoLongerSupported'))
    ''
    getString(message('signal:sptoolgui:ClickConvertToOpenSession'))
    ''};

sptoolfig = findobj(0,'Tag','sptool');
tConvert = getString(message('signal:sptoolgui:Convert'));
tCancel = getString(message('signal:sptoolgui:Cancel'));

if isequal(forceFDAformat, 1)
    answer = tConvert;
else
    answer = questdlg(str,getString(message('signal:sptoolgui:ConvertFiltersToUseFDATool')),tConvert,tCancel,tConvert);
end

switch answer
    case tConvert
        %       OK, convert filters to FDA format
        filters = ud.session{2};
        for idx = 1:length(filters)
            if ~isfield(filters(idx),'FDAspecs') || isempty(filters(idx).FDAspecs)
                filters(idx).FDAspecs.sidebar.design = getfdaformat(filters(idx));
                currentModule = filters(idx).specs.currentModule;
                %remove the spec area with only currentModule remained.
                filters(idx).specs = [];
                filters(idx).specs.currentModule = currentModule;
            end
        end
        ud.session{2} = filters;
        ud.unchangedFlag = 0;
        ud.savedFlag = 0;
        set(sptoolfig,'UserData', ud);
        udnew = ud;
    case tCancel
        % User cancels import - return empty udnew (g1729863)
        udnew = [];
  otherwise
        %         force to make selection if user clicks x to try to quit.
        udnew = promptForFDA(ud, filtdesPrefs, 0);
end


%-------------------------------------------------------------------
% Added for FDATool - prompt to switch to Filter Designer and remove
% filters. This function has been removed. (g1388310) 

%----------------------------------------------
% FDATool - find if session contains old filter
%----------------------------------------------
function out = hasSPTfilter(session)
filters = session{2};
out = 0;
for idx = 1:length(filters)
    if ~isfield(filters(idx),'FDAspecs')
        out = 1;
        return
    end
end

%--------------------------------------------------------------
% FDATool - Check if FDATool or Filter Designer is open. If so,
% close before loading session. <g292547>
%--------------------------------------------------------------
function checkFilterWindow(ud)
if (isfield(ud, 'hFDA') && ishandle(ud.hFDA))
    %     str = 'FDATool is now open and needs to be closed to load a session.';
    %     waitfor(msgbox(str, 'SPTool'));
    close(ud.hFDA, 'force');
    return;
end

filtdesFig = findobj(0,'Tag','filtdes');
if ~isempty(filtdesFig)
    %     str = 'The Filter Designer is now open and needs to be closed to load a session.';
    %     waitfor(msgbox(str, 'SPTool'));
    delete(filtdesFig);
    return;
end

% [EOF] sptool.m

