function fcnHandles = fdplugin
%FDPLUGIN Define the DSP System Toolbox plugin to FDATool.

%   Author(s): J. Schickler 
%   Copyright 1999-2017 The MathWorks, Inc.

fcnHandles.fdatool = @insertplugin;
fcnHandles.sidebar = @insertpanel;
fcnHandles.designpanel = @fddesignmethods;
fcnHandles.fvtool  = @installanalyses;
% fcnHandles.importfile = @importfile;


% --------------------------------------------------------------
function fddesignmethods(hd)

% Add IIRLPNORM
addmethod(hd, {{'lp', 'lp'}, {'hp', 'hp'}, {'bp', 'bp'}, {'bs', 'bs'}, ...
    {'other', 'arbitrarymag'}}, 'iir', 'Least Pth-norm', 'filtdes.iirlpnorm');

% Add IIRLPNORMC
addmethod(hd, {{'lp', 'lp'}, {'hp', 'hp'}, {'bp', 'bp'}, {'bs', 'bs'}, ...
    {'other', 'arbitrarymag'}}, 'iir', 'Constr. Least Pth-norm', 'filtdes.iirlpnormc');

% Add FIRLPNORM
addmethod(hd, {{'lp', 'lp'}, {'hp', 'hp'}, {'bp', 'bp'}, {'bs', 'bs'}, ...
    {'other', 'arbitrarymag'}}, 'fir', 'Least Pth-norm', 'filtdes.firlpnorm');

% Add the Arbitrary Group Delay IIRGRPDELAY
addmethod(hd, {'other', 'arbitrarygrp'}, 'iir', 'Constr. Least Pth-norm', ...
    'filtdes.iirgrpdelay', 'Arbitrary Group Delay');

% Add Lowpass Halfband
addmethod(hd, {'lp', 'halfbandlp'}, 'fir', 'Equiripple', 'filtdes.remez', 'Halfband Lowpass');
addmethod(hd, {'lp', 'halfbandlp'}, 'fir', 'Window', 'filtdes.fir1');

% Add Highpass Halfband
addmethod(hd, {'hp', 'halfbandhp'}, 'fir', 'Equiripple', 'filtdes.remez', 'Halfband Highpass');
addmethod(hd, {'hp', 'halfbandhp'}, 'fir', 'Window', 'filtdes.fir1');

% Add Nyquist
addmethod(hd, {'lp', 'nyquist'}, 'fir', 'Equiripple', 'filtdes.remez', 'Nyquist');
addmethod(hd, {'lp', 'nyquist'}, 'fir', 'Window', 'filtdes.fir1');

% Add firceqrip
addmethod(hd, {{'lp', 'lp'}, {'hp', 'hp'}}, 'fir', 'Constrained Equiripple', 'filtdes.firceqrip');
addmethod(hd, {'lp', 'invsinclp'}, 'fir', 'Constrained Equiripple', 'filtdes.firceqrip', ...
    'Inverse Sinc Lowpass');
addmethod(hd, {'hp', 'invsinchp'}, 'fir', 'Constrained Equiripple', 'filtdes.firceqrip', ...
    'Inverse Sinc Highpass');

addmethod(hd, {{'lp', 'lp'}, {'hp', 'hp'}, {'bp', 'bp'}, {'bs', 'bs'}, ...
    {'other', 'arbitrarymag'}, {'other', 'diff'}, {'other', 'multiband'}}, ...
    'fir', 'Generalized Equiripple', 'filtdes.gremez');

addmethod(hd, {{'lp', 'lp'}, {'hp', 'hp'}, {'bp', 'bp'}, {'bs', 'bs'}, ...
    {'other', 'arbitrarymag'}, {'other', 'diff'}, {'other', 'multiband'}}, ...
    'fir', 'Constr. Band Equiripple', 'filtdes.fircband');

addmethod(hd, {{'lp', 'lp'}, {'hp', 'hp'}}, 'fir', 'Interpolated FIR', 'filtdes.ifir');

addmethod(hd, {'other', 'peak'}, 'iir', 'Comb', 'filtdes.iircomb', 'Peaking');
addmethod(hd, {'other', 'notch'}, 'iir', 'Comb', 'filtdes.iircomb', 'Notching');

addmethod(hd, {'other', 'notch'}, 'iir', 'Single Notch', 'filtdes.iirnotchpeak');
addmethod(hd, {'other', 'peak'}, 'iir', 'Single Peak', 'filtdes.iirnotchpeak');

% --------------------------------------------------------------
function insertplugin(hFDA)
% INSERTPLUGIN makes the necessary changes to FDATool to enable 
%   the launch of the plugin.

% Add a menu item which enables exporting coefficients to XILINX .COE files
addtargetmenu(hFDA, getString(message('signal:sigtools:sigtools:XILINXCoefficientFile')), ...
    @(hcbo, eventData) export2coe(hFDA), 'export2COE');

% Add a menu item which enables importing XILINX .COE files
addmenu(hFDA, [1 7], getString(message('signal:sigtools:sigtools:ImportFromXILINXCoefficientFile')), ...
    @(hcbo, eventData) importfromcoe(hFDA), 'importfromCOE');

% Insert DSP System Toolbox help
insertdspsystbxhelp(hFDA,[3, 11, 13]);

l = handle.listener(hFDA, hFDA.findprop('Filter'), 'PropertyPostSet', ...
    @(hSrc, eventData) lclfilter_listener(hFDA));
sigsetappdata(hFDA, 'qpanel', 'listener', l);

% --------------------------------------------------------------
function insertpanel(hSB)

icons = load('fd_icons');

hFDA = getfdasessionhandle(hSB.FigureHandle);
notblks = ~getflags(hFDA, 'calledby', 'dspblks');

if notblks

    % Only register the QFILTPANEL if this is not called by DSP Blockset and
    % the SFCNPARAMS method does not exist.  This method may not exist if the
    % user has the latest filterdesign but an older dspblks.  This should only
    % happen in between web releases of the 2 products.
    qopts.tooltip = getString(message('signal:sigtools:sigtools:Setquantizationparameters'));

    qopts.icon    = color2background(icons.quantize);
    % qopts.icon    = icons.quantize; % See G122899

    qopts.csh_tag = ['fdatool_setquantization_tab' filesep 'dsp'];
    registerpanel(hSB,@fdatool_qfiltpanel,'quantize',qopts);
end

opts.tooltip = getString(message('signal:sigtools:sigtools:Transformfilter'));
opts.icon    = color2background(icons.xform);
opts.csh_tag = ['fdatool_xform_overview' filesep 'dsp'];
% opts.icon    = icons.xform;

registerpanel(hSB,@fdatool_xformtool,'xform',opts);

if notblks
    opts.tooltip = getString(message('signal:sigtools:sigtools:Createamultiratefilter'));
    opts.icon    = color2background(icons.multirate);
    opts.csh_tag = ['fdatool_mfilt_overview' filesep 'dsp'];

    registerpanel(hSB,@fdatool_mfilttool,'mfilt',opts);
end


% ----------------------------------------------------------------------
function lclfilter_listener(hFDA)

Hd = getfilter(hFDA);

if isquantized(Hd)
    fdatool_qfiltpanel(hFDA);
end

% --------------------------------------------------------------------
function installanalyses(hFVT)

if isa(hFVT, 'siggui.fvtool')

    icons = load('fd_icons');

    % Register the analysis with FVTool
    registeranalysis(hFVT, getString(message('signal:sigtools:sigtools:MagnitudeResponseEstimate')), 'magestimate', ...
        'filtresp.noisemagnitude', icons.magestimate, '', @checkFilters);
    registeranalysis(hFVT, getString(message('signal:sigtools:sigtools:RoundoffNoisePowerSpectrum')), 'noisepower', ...
        'filtresp.noisepowerspectrum', icons.noisepowerspectrum, '', @checkFilters);

else
    adddynprop(hFVT, 'ShowReference', 'on/off', @setsrr, @getsrr)
    adddynprop(hFVT, 'PolyphaseView', 'on/off', @setpolyphase, @getpolyphase)
    
    % Force the get functions to fire so the stored value is correct.  This
    % will keep the set from being "aborted".
    get(hFVT,'ShowReference');
    get(hFVT,'PolyphaseView');
end

% --------------------------------------------------------------------
function sra = setsrr(h, sra)

hfvt = getcomponent(h, 'siggui.fvtool');
set(hfvt, 'ShowReference', sra);

% --------------------------------------------------------------------
function sra = getsrr(h, sra) %#ok

hfvt = getcomponent(h, 'siggui.fvtool');
sra = get(hfvt, 'ShowReference');

% --------------------------------------------------------------------
function poly = setpolyphase(h, poly)

hfvt = getcomponent(h, 'siggui.fvtool');
set(hfvt, 'PolyphaseView', poly);

% --------------------------------------------------------------------
function poly = getpolyphase(h, poly) %#ok

hfvt = getcomponent(h, 'siggui.fvtool');
poly = get(hfvt, 'PolyphaseView');

% --------------------------------------------------------------------
function export2coe(hFDA)
% Export to XILINX .COE file

filtobj = getfilter(hFDA);
msg     = getString(message('signal:sigtools:YourFilterMustBeAFixedpointSinglesectionDirectformFIRFi'));
if isquantized(filtobj)
    if strcmpi(filtobj.Arithmetic, 'Fixed') && strcmpi(class(filtobj), 'dfilt.dffir')
        coewrite(filtobj);
    else
        senderror(hFDA, msg);
    end
else
    senderror(hFDA, msg);
end

% --------------------------------------------------------------------
function importfromcoe(hFDA)
% Import from XILINX .COE file

dlgstr = getString(message('signal:sigtools:sigtools:ImportFromXILINXCoefficientFile'));
filterspec = {'*.coe', ...
    fdatoolmessage('XilinxCoreGenCoeefFile')};

% Put up the file selection dialog
[filename, pathname] = lcluigetfile(dlgstr,filterspec);

if ~isempty(filename)
    deffile = [pathname filename];
    
    try  
        filtobj = feval('coeread',deffile);
        
        if ~isempty(filtobj)
            opts.source = 'Imported';
            sendstatus(hFDA,getString(message('signal:sigtools:sigtools:ImportingfromXILINXcoefficientfile')));
            hFDA.setfilter(filtobj,opts);
        end
    catch
        % No op
    end
end

% --------------------------------------------------------------------
function b = checkFilters(Hd)

b = false;
% If we find 1 dfilt, then the analysis can work.  Check for the odd case
% where we have a dfilt.parallel that contains multirate information and
% disallow the analysis.
for indx = 1:length(Hd)
    h = get(Hd(indx), 'Filter');
    if (isprop(h,'FromSysObjFlag') && h.FromSysObjFlag)
       if h.SupportsNLMethods && ~isa(h,'mfilt.abstractmultirate')
         b = true;
       end
    elseif (isa(h, 'dfilt.singleton') || ...
            (isa(h, 'dfilt.multistage') && ~isa(h, 'mfilt.cascade') && ...
            all(h.getratechangefactors == 1)))             
        b = true;
    end
end

% % --------------------------------------------------------------
% function opts = importfile
% % Importing a filter from a text-file.
% 
% % Plug-in to read XILINX CORE Generator coefficient files
% opts.fcn = @coeread;
% opts.filterspec = {'*.coe','XILINX CORE Generator coefficient file(*.coe)';};
% 
% % To add additional file readers
% % opts(2).fcn = @fcnhandle; 
% % opts(2).filterspec = {'*.TXT','File Type';};

%------------------------------------------------------------------------
function [filename, pathname,idx] = lcluigetfile(dlgStr,fileformat)
% Local UIGETFILE: Return an empty string for the "Cancel" case

[filename, pathname,idx] = uigetfile(fileformat,dlgStr);

% filename is 0 if "Cancel" was clicked
if filename == 0, filename = ''; end

% [EOF]
