function htools = render_spttoolsmenu(hFig, pos)
%RENDER_SPTTOOLSMENU Render a Signal Processing Toolbox "Tools" menu. 
%   HTOOLS = RENDER_SPTTOOLSMENU(HFIG, POS) creates a "Tools" menu in POS position
%   on a figure whose handle is HFIG and return the handles to all the menu items.

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.

% Render a "Tools" menu
strs  = {'&Tools'};

% Work around so our zoom and the scribe buttons remain exclusive
cbs   = {'domymenu menubar inittoolsmenu'};

tags  = {'figMenuTools'};

sep   = {'off'};

accel = {''};
htoolsmenu = addmenu(hFig,pos,strs,cbs,tags,sep,accel);

% Add "Zoom " menus
hzoommenus = render_zoommenus(hFig,[pos 1]);
set(hzoommenus(1),'Separator','on');

% strs  = {'Basic Fitting', 'Data Statistics'};
% cbs = {'basicfitdatastat(''bfit'',gcbf,''bf'');', ...
%         'basicfitdatastat(''bfit'',gcbf,''ds'');'};
% tags  = {'basicfitting', 'datastatistics'}; 
% sep   = {'On', 'Off'};
% accel = {'', ''};
% htoolsmenu([3 4]) = addmenu(hFig,[pos 4],strs,cbs,tags,sep,accel);
htools = [htoolsmenu(:);hzoommenus(:)];

% [EOF]
