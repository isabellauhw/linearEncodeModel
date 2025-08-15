function updateexportaspopup(this)
%UPDATEEXPORTASPOPUP Remove export as 'objects' or 'System objects' if not
%supported

%   Copyright 2012-2015 The MathWorks, Inc.

sysObjSupported = false; 
objSupported = true;

for idx = 1:length(this.Data)
  if isa(this.Data.elementat(idx),'dfilt.basefilter')
    if isfdtbxinstalled
      currentFilt = this.Data.elementat(idx);
      sysObjSupported = sysobj(currentFilt,true);
      % Disable exporting MFILT objects when System object is supported.
      if sysObjSupported && isa(this.Data.elementat(idx),'mfilt.abstractmultirate')
          objSupported = false;
      end
    end  
  elseif isa(this.Data.elementat(idx),'sigwin.window')
    objSupported = false;
  end
end

expHdl = get(this,'handles');
if isfield(expHdl,'exportas')
  expHdl = expHdl.exportas;
  
  strs  = set(this,'ExportAs');
  strsT = getTranslatedStringcell('signal:sigtools:sigtools', strs);
  
  if ~sysObjSupported
    % System objects are not supported for the current filter
    sysObjIdx = strcmpi(strs,'System Objects');
    strs(sysObjIdx)  = [];
    strsT(sysObjIdx) = [];
    if strcmpi('System objects',this.ExportAs)
      % Set the property to a valid option if it was set to 'System objects'
      this.ExportAs = 'Objects';
    end
  end
  
  if ~objSupported
    % objects are not supported
    objIdx = strcmpi(strs,'Objects');
    strs(objIdx)  = [];
    strsT(objIdx) = [];
    if strcmpi('objects',this.ExportAs)
      % Set the property to a valid option if it was set to 'Objects'
      if sysObjSupported && isa(this.Data.elementat(idx),'mfilt.abstractmultirate')
        this.ExportAs = 'System Objects';
      else
        this.ExportAs = 'Coefficients';
      end
    end
  end
  
  % Set the popup 'String' property to the translated strings
  set(expHdl,'String',strsT);
  
  % Set the popup selection accordingly.
  set(expHdl, 'Value', find(strcmpi(strs,this.ExportAs)));
  
  % Save untranslated strings in the app data for use in the callback
  setappdata(expHdl, 'PopupStrings', strs);
  
end
