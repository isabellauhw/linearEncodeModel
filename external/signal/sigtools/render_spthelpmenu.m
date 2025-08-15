function [hhelpmenu, hhelpmenuitems] = render_spthelpmenu(hfig, position)
%RENDER_HELP_MENU Render a Signal Processing Toolbox specific "Help" menu.
% 
%   Inputs:
%     hfig     - Handle to the figure
%     position - Position of new menu.
%
%   Output:
%     hhelpmenu      - Handle to the "Help" menu on the menubar. 
%     hhelpmenuitems - Vector containing handles to all the help menu items.

%    Author(s): P. Costa
%    Copyright 1988-2002 The MathWorks, Inc.

% List menu item strings
strs = {getString(message('signal:sigtools:render_spthelpmenu:Help')),...
        getString(message('signal:sigtools:render_spthelpmenu:SignalProcessingToolboxHelp')),...
        getString(message('signal:sigtools:render_spthelpmenu:SignalProcessingDemos')),...
        getString(message('signal:sigtools:render_spthelpmenu:AboutSignalProcessingToolbox'))};

tags = {'help',...
        'producthelp',...
        'demos',...
        'about'};

% Separators
sep = {'Off','Off','On','On'};

% CallBacks
cbs = {'',...
        @producthelp_cb,...
        @demos_cb,...
        @about_cb};

% Render the Help menu 
hhelpmenus     = addmenu(hfig,position,strs,cbs,tags,sep);
hhelpmenu      = hhelpmenus(1);
hhelpmenuitems = hhelpmenus(2:end);


% --------------------------------------------------------------
function producthelp_cb(hco,eventStruct)
% producthelp_cb Opens the Help window with the online doc Roadmap
%                page (a.k.a. "product page") displayed.

doc signal/


% --------------------------------------------------------------
function demos_cb(hco,eventStruct)
% demos_cb Starts Demo window, with the appropriate product's
%                demo highlighted in the Demo window contents pane.

demo toolbox signal


%--------------------------------------------------------------
function about_cb(hco,eventStruct)
% about_cb Displays version number of product, and copyright.

aboutsignaltbx;


% [EOF]
