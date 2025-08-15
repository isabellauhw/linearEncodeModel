function hSB = fdatool_sidebar(hFDA)
%SIDEBAR Build the sidebar on FDATool

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

hFig = get(hFDA,'FigureHandle');

% Instantiate the object
hSB = siggui.sidebar;

render(hSB, hFig);

% Register the sidebar as a component of FDATool
addcomponent(hFDA,hSB);

% Add the Design Panel
install_design_panel(hSB);

% Add the Import Panel
install_import_panel(hSB);

install_pzeditor_panel(hSB);

% Add plugins for the sidebar
addplugins(hSB);

status(hFDA, getString(message('signal:sigtools:private:InitializingFilterDesign')));

set(hSB,'CurrentPanel',1);

% ----------------------------------------------------------------
%   Install Panel functions
% ----------------------------------------------------------------

% ----------------------------------------------------------------
function install_design_panel(hSB)

icons        = load('panel_icons');

% Remove the following line once geck # 110439 is addressed. 
opts.icon    = color2background(icons.design); 
% opts.icon    = icons.design; % See G122899
opts.tooltip = getString(message('signal:sigtools:private:DesignFilter'));
opts.csh_tag = 'fdatool_designfilter_tab';

% Register the Design Panel
registerpanel(hSB, @fdatool_design, 'design', opts);
% registerpanel(hSB,design_fcns,'design',opts);

% ----------------------------------------------------------------
function install_import_panel(hSB)

% Create the Import Panel and Register it
icons        = load('panel_icons');
opts.icon    = color2background(icons.import); 
% opts.icon    = icons.import; % See G122899
opts.tooltip = getString(message('signal:sigtools:private:ImportFilterFromWorkspace'));
opts.csh_tag = 'fdatool_importfilter_tab';

% Register the Import Panel
registerpanel(hSB,@fdatool_import,'import',opts);

addimportmenu(hSB);

% ----------------------------------------------------------------
function install_pzeditor_panel(hSB)

% Create the Import Panel and Register it
icons        = load('panel_icons');
opts.icon    = color2background(icons.pzeditor);
opts.tooltip = getString(message('signal:sigtools:private:PoleZeroEditor'));

% Register the Import Panel
registerpanel(hSB,@fdatool_pzeditor,'pzeditor',opts);

hEdit = findall(hSB.figurehandle, 'type', 'uimenu', 'tag', 'edit');

uimenu(hEdit, 'Label', getString(message('signal:sigtools:private:PoleZeroEditor')), 'Tag', 'pzeditor_tools_menu', ...
    'Callback', {@setpanel_cb, hSB, 'pzeditor'});

% ----------------------------------------------------------------
%   Utility functions
% ----------------------------------------------------------------

% ----------------------------------------------------------------
function addimportmenu(hSB)

hFig = get(hSB, 'FigureHandle');

hFM = findobj(hFig, 'type','uimenu','tag','file');
hEM = findobj(hFM, 'tag', 'export');

uimenu(hFM, 'Position', get(hEM, 'Position'), ...
    'Label', getString(message('signal:sigtools:private:ImportFilterFromWorkspace')), ...
    'Separator', 'On', ...
    'Tag', 'import', ...
    'Accelerator', 'i', ...
    'Callback', {@setpanel_cb, hSB, 'import'});
set(hEM, 'Separator', 'Off');

% ----------------------------------------------------------------
function setpanel_cb(hcbo, eventStruct, hSB, newpanel)

if nargin == 3, newpanel = get(hcbo, 'Tag'); end
if ischar(newpanel), newpanel = string2index(hSB, newpanel); end

set(hSB, 'CurrentPanel', newpanel);

% [EOF]
