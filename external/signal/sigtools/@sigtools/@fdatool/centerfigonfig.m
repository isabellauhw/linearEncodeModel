function centerfigonfig(hFDA, hmsg)
%CENTERFIGONFIG Center figure on top of FDATool.
%   CENTERFIGONFIG(hFDA,hFig) Center figure window associated with
%   hFig on FDATool associated with hFDA.

%   Author(s): P. Costa 
%   Copyright 1988-2010 The MathWorks, Inc.

hFig = get(hFDA,'FigureHandle');

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
