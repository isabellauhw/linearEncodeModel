function hprintbtns = render_sptprintbtns(htoolbar)
%RENDER_SPTPRINTBTNS Render the "Print" and "Print Preview" toolbar buttons.
%   HPRINTBTNS = RENDER_SPTPRNITBTNS(HTOOLBAR) creates the print portion of a toolbar 
%   (Print, Print Preview) on a toolbar parented by HTOOLBAR and return the handles 
%   to the buttons.

%   Author(s): V.Pellissier
%   Copyright 1988-2017 The MathWorks, Inc.

% Load new, open, save print and print preview icons.
icons = load('sptviewicons');

pushbtns = {icons.printdoc,...
        icons.printprevdoc};

tooltips = {getString(message('signal:sigtools:render_sptprintbtns:Print')),...
        getString(message('signal:sigtools:render_sptprintbtns:PrintPreview'))};

tags = {'printresp',...
        'printprev'};

btncbs = {'printdlg(gcbf);',...
        'printpreview(gcbf);'};

% Render the PushButtons
for i = 1:length(pushbtns)
   hprintbtns(i) = uipushtool('CData',pushbtns{i},...
        'Parent', htoolbar,...
        'ClickedCallback',btncbs{i},...
        'Tag',            tags{i},...
        'TooltipString',  tooltips{i});
end

% [EOF]
