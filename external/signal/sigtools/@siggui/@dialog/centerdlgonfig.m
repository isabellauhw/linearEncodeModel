function centerdlgonfig(hDlg, h)
% CENTERDLGONFIG Center Dialog on top of figure.
%
% Inputs:
%   hFig - Handle to the Filter Design GUI figure. 
%   hmsg - Handle to the figure to be centered on hFig.

%   Author(s): P. Costa & J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if ~isrendered(hDlg), return; end

if isa(h,'siggui.siggui') || isa(h,'siggui.sigguiMCOS')
    if isrendered(h)
        h = get(h,'FigureHandle');
    else
        movegui(hDlg.FigureHandle, 'center');
        return;
    end
end

hFig = get(hDlg,'FigureHandle');

% If the parent window is docked, we need to get the position of the MDI
% not the figure.
if strcmpi(get(h, 'WindowStyle'), 'docked')
    
    % Suppress the JavaFrame warning.
    [lastWarnMsg, lastWarnId] = lastwarn;
    oldstate = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    
    MDIName = getGroupName(matlab.ui.internal.JavaMigrationTools.suppressedJavaFrame(h));
    
    import com.mathworks.mlservices.*;
    
    % Get the handle to the parent MDI.
    hMDI = MatlabDesktopServices.getDesktop.getGroupContainer(MDIName);
    
    % Get the x and y position.
    xy = hMDI.getLocationOnScreen;

    % Get the height
    h      = hMDI.getHeight;
    screen = get(0, 'ScreenSize');

    % Restore the JavaFrame warning and lastwarn states.
    warning(oldstate);
    lastwarn(lastWarnMsg, lastWarnId);
    
    % Convert java Y to MATLAB Y position.  Java is from the top and
    % MATLAB is from the bottom.
    y = screen(4)-h-xy.y;
    
    figPos = [xy.x y hMDI.getWidth h];
    
else
    set(h,'Units','pix');
    figPos = get(h,'Position');
    set(hFig,'Units','pix');
end

figCtr = [figPos(1)+figPos(3)/2 figPos(2)+figPos(4)/2];

set(hFig,'Units','pix');
msgPos = get(hFig,'Position');
msgCtr = [msgPos(1)+msgPos(3)/2 msgPos(2)+msgPos(4)/2];

movePos = figCtr - msgCtr;

new_msgPos = msgPos;
new_msgPos(1:2) = msgPos(1:2) + movePos;
set(hFig,'Position',new_msgPos);

% [EOF]
