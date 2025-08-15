function hIT = fdatool_import(hSB)
%FDATOOL_IMPORT Add the import panel to FDATool
%   FDATOOL_IMPORT(hSB) Interface function between FDATool and the import panel.

%   Copyright 1988-2011 The MathWorks, Inc.

hFig = get(hSB,'FigureHandle');
hFDA = getfdasessionhandle(hFig);

status(hFDA, getString(message('signal:sigtools:private:LoadingFilterImportpanel')));

hIT  = siggui.import;

status(hFDA, [getString(message('signal:sigtools:private:LoadingFilterImportpanel')) ' ...']);

sz = fdatool_gui_sizes(hFDA);
render(hIT, hFig, sz.panel);

% resizefcn(hIT, [sz.fig_w sz.fig_h]*sz.pixf);

l = handle.listener(hIT, 'FilterGenerated', {@filtergenerated_eventcb, hFDA});
setappdata(hFig, 'ImportFilterGeneratedListener', l);

setunits(hIT, 'Normalized');

status(hFDA, [getString(message('signal:sigtools:private:LoadingFilterImportpanel')) ...
              ' ... ' getString(message('signal:sigtools:private:Done'))]);

% ------------------------------------------------------------------
function filtergenerated_eventcb(hIT, eventData, hFDA)

data = get(eventData, 'Data');

if isempty(data.filter)
  send(hFDA,'FilterUpdated',handle.EventData(hFDA,'FilterUpdated'));
else
  
  filtobj = data.filter;
  
  options.fs         = data.fs;
  options.source     = 'Imported';
  options.fcnhndl    = @setimportedflag; % This line will be eliminated when all panels are objects
  options.update     = 1;
  options.mcode      = genmcode(hIT);
  options.resetmcode = true;
  if isprop(filtobj, 'FilterStructure')
    options.name   = getTranslatedString('signal:sigtools:siggui',get(filtobj, 'FilterStructure'));
  elseif isprop(filtobj, 'Algorithm')
    options.name   = getTranslatedString('sigtools/private/fdatool_import',get(filtobj, 'Algorithm'));
  else
    options.name   = '';
  end
  
  hFDA.McodeType = 'import';
  
  try
    hFDA.setfilter(filtobj,options);
  catch ME
    senderror(hFDA, ME.identifier, ME.message);
  end
end

% [EOF]
