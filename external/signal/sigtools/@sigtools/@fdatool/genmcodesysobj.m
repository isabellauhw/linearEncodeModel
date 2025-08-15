function mcode = genmcodesysobj(this, file, refCodeFlag, launchEditorFlag, mcode)
%GENMCODE Generate M-code for filter System objects

%   Copyright 2011-2017 The MathWorks, Inc.

if nargin < 4
  launchEditorFlag = true;
end

% When refCodeFlag and this.IsSOSConvertedMCode are true, we return the code
% of a reference double precision filter
if nargin < 3
  refCodeFlag = false;
end

if nargin<5
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
end
if isempty(mcode)
  error(message('signal:sigtools:fdatool:genmcode:noMATLABcode'));
end

outputVar = 'Hd';
codegenDone = false;
codeStr = string(mcode);

% CASE 1: filter is designed via FDESIGN
if contains(codeStr,'fdesign')
  
  if this.IsSOSConvertedMCode
    Hdfilt = getfilter(this);
    if refCodeFlag
      % We want to generate code for a reference double filter 
      Hdfilt = copy(Hdfilt);
      Hdfilt.Arithmetic = 'double';
    end
    Hsysobj = sysobj(Hdfilt);
    addSysObjDesignOpt(this,mcode,Hdfilt,Hsysobj);
    codegenDone = true;
  else
    % Get the current filter and convert it to a System object
    Hdfilt = getfilter(this);
    % Get the Fs from the code (the filter object has normalized fdesign
    % metadata). Unnormalize the fdesign metadata using the Fs value and then
    % convert the dfilt/mfilt object to a System object.
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
    Hsysobj = sysobj(Hdfilt);
    
    try
      % Call the code generation methods of filterbuilder. Instantiate a
      % filterbuilder designer and pass the 'DoNotRenderGUI'flag so that the
      % GUI is not rendered and the designer object is returned as an output
      source = filterBuilder(Hsysobj,'DoNotRenderGUI');
      if strcmpi(Hdfilt.Arithmetic,'fixed')
        source.FixedPoint.Arithmetic = 'Fixed point';
      end
      
      % Call export of the filterbuilder designer with second argument equal
      % to a dummy handle that is not a DAStudio dialog. Then export will not
      % render GUI 'unapplied changes' warnings
      if launchEditorFlag
        export(source, source, 'mcode',false,'')
      else
        export(source, source, 'mcode',false,'',file)
      end
      return;
    catch %#ok<CTCH>
      % Not successful (filter design is unsupported by filterbuilder), so use
      % the code to generate the filter
      addSysObjDesignOpt(this,mcode,Hdfilt,Hsysobj);
      codegenDone = true;
    end
  end
end

if ~codegenDone
  
  % CASE 2: filter is designed via a filtering function
  
  % Identify the line that has the dfilt/mfilt constructor and create new
  % code buffer containing all lines up to that line
  Hdfilt = getfilter(this);
  Hsysobj = sysobj(Hdfilt);
  
  if isa(Hsysobj, 'dsp.FilterCascade')
      source = FilterDesignDialog.AbstractDesign;
      mcode = getMCodeBufferSysObjCascade(source, this, mcode, Hsysobj);
      outputVar = 'Hcascade';
  else
      dmfiltIdx = mcode.find({'dfilt.','mfilt.'},'partial');
      idx = max([max(dmfiltIdx{1}) max(dmfiltIdx{2})]);
      
      % If no dfilt/mfilt constructor was found in the BaseMCode then check if
      % this is a multirate design, add the multirate code, and look for the
      % mfilt constructor again
      if isempty(idx) && strncmpi(this.filterMadeBy, 'multirate design',16)
          mcode.cr;
          mcode.add(this.MultirateMCode);
          idx = mcode.find('mfilt.','partial');
      end
      
      bufferLines = mcode.buffer;
      inputs = {};
      restOfLines = [];
      % If no dfilt or mfilt constructors were found then hard code the filter
      % coefficients by passing an empty 'inputs' cell to the
      % getMCodeBufferSysObj method of the filterbuilder designer.
      if ~isempty(idx)
          % We have a dfilt/mfilt constructor, find the input variables and pass
          % them in the 'inputs' cell array
          mcode = sigcodegen.mcodebuffer;
          idxBegin = strfind(bufferLines{idx},'(');
          idxEnd = strfind(bufferLines{idx},');');
          inputsBuffer = bufferLines{idx}(idxBegin+1:idxEnd-1);
          if ~isempty(inputsBuffer)
              idxCommas = strfind(inputsBuffer,',');
              idxCommas = [0 idxCommas length(inputsBuffer)+1]; %#ok<*AGROW>
              for k = 1:length(idxCommas)-1
                  inputs{k} = inputsBuffer(idxCommas(k)+1:idxCommas(k+1)-1);
                  inputs{k} = inputs{k}(~isspace(inputs{k}));
              end
          end
          if(~isa(Hsysobj, 'dsp.CoupledAllpassFilter'))
              add(mcode,bufferLines(1:idx(end)-1));
          else
              inputs(1:end) = [];
          end
          mcode.addcr;
          restOfLines = bufferLines(idx(end)+1:numel(bufferLines));
      end
      
      % Generate code for the System object using the filterbuilder code
      % generator. Append it to the mcode buffer. Use the filterbuilder
      % designer abstract design class.
      source = FilterDesignDialog.AbstractDesign;
      
      if this.IsSOSConvertedMCode
          tmpFilt = copy(Hdfilt);
          tmpFilt.Arithmetic = 'double';
          tmpSysObj = sysobj(tmpFilt);
          mcode = getMCodeBufferSysObj(source,mcode,tmpSysObj,inputs);
          mcode.addcr(restOfLines);
          
          % Change calls to 'convert' method to a setting of the structure
          convertStructures(this,mcode,Hsysobj);
          
          % Add fixed point code if needed
          addFixedPointCode(this,mcode,Hdfilt,Hsysobj)
      else
          % Passing input the 'inputs' cell of strings will make
          % getMCodeBufferSysObj set the coefficients to variables in inputs
          % instead of writing the hard coded coefficients.
          mcode = getMCodeBufferSysObj(source,mcode,Hsysobj,inputs);
      end
  end
end

if ~refCodeFlag
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
  if isa(getfilter(this), 'mfilt.abstractmultirate')
    opts.H1 = getString(...
      message('signal:sigtools:sigtools:ReturnsMultirateFilterObj'));
  else
    opts.H1 = getString(...
      message('signal:sigtools:sigtools:ReturnsDiscreteTimeFilterObj'));
  end
  
  opts.outputargs = outputVar;
  
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
end
%--------------------------------------------------------------------------
function addSysObjDesignOpt(this,mcode,Hdfilt,Hsysobj)
% Find the design line and add the System object design option
designLine = mcode.find('design(','partial');
endLineIdx = mcode.find(');','partial');
lineToChangeIdx = min(endLineIdx(endLineIdx>=designLine));
lineToChange = mcode.getline(lineToChangeIdx);
idx = strfind(lineToChange{:},');');

newLine = [lineToChange{:}(1:idx-1) ', ''SystemObject'', true);'];
mcode.replace(lineToChangeIdx, newLine);
mcode.addcr;

% Change calls to 'convert' method to a setting of the structure
convertStructures(this,mcode,Hsysobj);

% Add fixed point code if needed
addFixedPointCode(this,mcode,Hdfilt,Hsysobj)
end
%-------------------------------------------------------------------------
function convertStructures(this,mcode,Hsysobj)
% Convert structures if needed
convertLineIdx = mcode.find('Hd = convert(Hd','partial');
if ~isempty(convertLineIdx)
  for idx = 1:length(convertLineIdx)-1
    mcode.replace(convertLineIdx(idx),this.SysObjConvertStructLines{idx});
  end
  newLine = ['Hd.Structure = ''' Hsysobj.Structure ''';'];
  mcode.replace(convertLineIdx(end),newLine);
  if length(convertLineIdx) > length(this.SysObjConvertStructLines)
    this.SysObjConvertStructLines{end+1} = newLine;
  end
end
end
%-------------------------------------------------------------------------
function addFixedPointCode(~,mcode,Hdfilt,Hsysobj)
% Add fixed point code if needed
if strcmpi(Hdfilt.Arithmetic,'fixed')
  % Set a filterbuilder fixed point source object according to the
  % System object
  source = FilterDesignDialog.FixedPoint;
  source.SystemObject = true;
  updateSettingsSysObj(source,Hsysobj);
  getMCodeBuffer(source, Hsysobj, mcode);
end
end
% [EOF]
