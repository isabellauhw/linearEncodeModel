function genmcodedesobj(this, file , launchEditorFlag)
%GENMCODEDESOBJ Generate M-code using filter designer objects

%   Copyright 2012-2017 The MathWorks, Inc.

if nargin < 3
  launchEditorFlag = true;
end

% If there is no mcode, generate the default mcode.
mcode = get(this, 'MCode');
if isempty(ishandle(mcode))
  [~, tmpCode] = defaultfilter(this);
  mcode = sigcodegen.mcodebuffer;
  mcode.add(tmpCode);
else
  mcode = sigcodegen.mcodebuffer;
  mcode.add(this.BaseMCode);
end
if isempty(mcode)
  error(message('signal:sigtools:fdatool:genmcode:noMATLABcode'));
end

Hdfilt = getfilter(this);

% Filter is designed via FDESIGN
if ~isempty(getfdesign(Hdfilt))
  
  % Get the Fs from the code (the filter object has normalized fdesign
  % metadata). Unnormalize the fdesign metadata using the Fs value and
  % then convert the dfilt/mfilt object to a System object.  
  fsIdx = mcode.find('Fs =','partial');
  if ~isempty(fsIdx)
    fsLine = mcode.getline(fsIdx); fsLine = fsLine{:};
    idxBegin = strfind(fsLine,'=');
    idxEnd = strfind(fsLine,';');
    Fs = str2double(fsLine(idxBegin+1:idxEnd-1));
    fd = getfdesign(Hdfilt);
    normalizefreq(fd,false,Fs);
    setfdesign(Hdfilt,fd);
  end
      
  % Call the code generation methods of filterbuilder. Instantiate a
  % filterbuilder designer and pass the 'DoNotRenderGUI'flag so that the
  % GUI is not rendered and the designer object is returned as an output
  source = filterBuilder(Hdfilt,'DoNotRenderGUI');
  
  % Call export of the filterbuilder designer with second argument equal
  % to a dummy handle that is not a DAStudio dialog. Then export will not
  % render GUI 'unapplied changes' warnings
  if launchEditorFlag
    export(source, source, 'mcode',false,'')
  else
    export(source, source, 'mcode',false,'',file)
  end
  return;
end

% Find dfilt constructor and remove it
dmfiltIdx = mcode.find({'dfilt.','mfilt.'},'partial');
mcode.remove([dmfiltIdx{:}])

bstr = 'b =';
bIdx = mcode.find({bstr},'partial');
if isempty(bIdx{:})
  bstr = 'b  =';
  bIdx = mcode.find({bstr},'partial');
end
line = mcode.getline([bIdx{:}]);
line = strrep(line,bstr,'B =');
mcode.replace([bIdx{:}],line);

% Write the code to a file ------------------------------------------------
if nargin < 2
  [file, path] = uiputfile('*.m', ...
    getString(message('signal:sigtools:sigtools:GenerateMATLABCode')), ...
    'untitled.m');
  if isequal(file, 0)
    return;
  end
  file = fullfile(path, file);
end

if ~contains(file, '.')
  file = [file '.m'];
end

% Set up the options for the public writer.
opts.H1 = getString(...
  message('signal:sigtools:sigtools:ReturnsDiscreteTimeFilterCoeffs'));
opts.outputargs = 'B';
opts.attachfooter = false; % avoid EOF addition

% Call the public writer.
genmcode(file, mcode, opts);

% Indent the code
strBuff = StringWriter;
strBuff.readfile(file);
strBuff.indentMATLABCode;
strBuff.write(file);

% Launch the editor with the file.
if launchEditorFlag
  edit(file);
end
end



