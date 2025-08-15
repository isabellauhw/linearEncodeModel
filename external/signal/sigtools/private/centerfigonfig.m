function centerfigonfig(hFig, hmsg)
% CENTERFIGONFIG Center hmsg figure on top of hfig figure.
%
% Inputs:
%   hFig - Handle to the Filter Design GUI figure. 
%   hmsg - Handle to the figure to be centered on hFig.

%   Author(s): P. Costa 
%   Copyright 1988-2010 The MathWorks, Inc.

set(hFig,'Units','pix');
figPos = get(hFig,'Position');
figCtr = [figPos(1)+figPos(3)/2 figPos(2)+figPos(4)/2];

set(hmsg,'Units','pix');
msgPos = get(hmsg,'Position');
msgCtr = [msgPos(1)+msgPos(3)/2 msgPos(2)+msgPos(4)/2];

movePos = figCtr - msgCtr;

new_msgPos = msgPos;
new_msgPos(1:2) = msgPos(1:2) + movePos;
set(hmsg,'Position',new_msgPos);

% [EOF] centerfigonfig.m
