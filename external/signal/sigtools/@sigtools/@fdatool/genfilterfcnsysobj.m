function genfilterfcnsysobj(this, file, launchEditorFlag)
%GENMCODE Generate filtering function for filter System objects

%   Copyright 2011-2017 The MathWorks, Inc.

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

codegenDone = false;
codeStr = string(mcode);

% CASE 0: filter was designed using sos reordering and scaling. Hard code
% coefficients and do not show commented code
if this.IsSOSConvertedMCode
  Hdfilt = getfilter(this);
  Hsysobj = sysobj(Hdfilt);
  supportsCodegen = ~isa(Hdfilt,'mfilt.firtdecim');

  tmpCode = [];
  if contains(codeStr,'fdesign')
    % Since there is fdesign code, show the code and comment it out. Use
    % the genmcodesysobj function.
    tmpCode = genmcodesysobj(this,'',true);
  end
  
  mcode = sigcodegen.mcodebuffer;
  
  mcode.add(['  % ' FilterDesignDialog.message('CCodegenCommandLineHelp') newline]);
  mcode.addcr;
  
  mcode.add(sprintf('%s \n','persistent Hd;'));
  mcode.add(sprintf('%s \n','if isempty(Hd)'));
  
  if ~isempty(tmpCode)
    idx = numel(mcode.buffer);
    mcode.addcr(FilterDesignDialog.message('FDESIGNComments'));
    mcode.add(tmpCode);
    mcode.MaxWidth = mcode.MaxWidth + 2;
    mcode.commentlines(idx,'end')
    mcode.addcr;    
  end  
  
  % Generate code for the System object using the filterbuilder code
  % generator. Append it to the mcode buffer. Use the filterbuilder
  % designer abstract design class.
  source = FilterDesignDialog.AbstractDesign;
  % Passing input the 'inputs' cell of strings will make
  % getMCodeBufferSysObj set the coefficients to variables in inputs
  % instead of writing the hard coded coefficients.
  mcode = getMCodeBufferSysObj(source,mcode,Hsysobj,{});
  
  mcode.addcr;
  mcode.addcr('end');
  mcode.addcr;
  emitFilterStepCode(Hdfilt, mcode);
  
  codegenDone = true;
  
elseif contains(codeStr,'fdesign')
  % CASE 1: filter is designed via FDESIGN
    
  % Get the current filter and convert it to a System object
  Hdfilt = getfilter(this);
  supportsCodegen = ~isa(Hdfilt,'mfilt.firtdecim');

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
    if isprop(Hdfilt,'Arithmetic')
        % Handle filter design Quantization settings
        if strcmpi(Hdfilt.Arithmetic,'fixed')
            source.FixedPoint.Arithmetic = 'Fixed point';
        elseif strcmpi(Hdfilt.Arithmetic,'single')
            source.FixedPoint.Arithmetic = 'Single precision';
        else
            source.FixedPoint.Arithmetic = 'Double precision';
        end
    end
    
    % Call export of the filterbuilder designer with second argument equal
    % to a dummy handle that is not a DAStudio dialog. Then export will not
    % render GUI 'unapplied changes' warnings
    if launchEditorFlag
      export(source, source, 'mcodefiltering',false,'')
    else
      export(source, source, 'mcodefiltering',false,'',file)
    end
    return;
    
  catch %#ok<CTCH>
    % Not successful (filter design is unsupported by filterbuilder),
    % so use the code to generate the filter
    
    % Find the design line  and add the System object design option
    designLine = mcode.find('design(','partial');
    endLineIdx = mcode.find(');','partial');
    lineToChangeIdx = min(endLineIdx(endLineIdx>=designLine));
    lineToChange = mcode.getline(lineToChangeIdx);
    idx = strfind(lineToChange{:},');');
    newLine = [lineToChange{:}(1:idx-1) ', ''SystemObject'', true);'];
    mcode.replace(lineToChangeIdx, newLine);
    
    mcode.insert(1,sprintf('%s \n','persistent Hd;'));
    mcode.insert(3,sprintf('%s \n','if isempty(Hd)'));
    
    mcode.insert(5,FilterDesignDialog.message('FDESIGNComments'));
    mcode.MaxWidth = mcode.MaxWidth + 2;
    commentlines(mcode,5,'end')
    mcode.addcr;
    
    mcode.insert(1,['  % ' FilterDesignDialog.message('CCodegenCommandLineHelp') newline]);
    mcode.addcr;
    
    % Generate code for the System object using the filterbuilder code
    % generator. Append it to the mcode buffer. Use the filterbuilder
    % designer abstract design class.
    source = FilterDesignDialog.AbstractDesign;
    % Passing input the 'inputs' cell of strings will make
    % getMCodeBufferSysObj set the coefficients to variables in inputs
    % instead of writing the hard coded coefficients.
    mcode = getMCodeBufferSysObj(source,mcode,Hsysobj,{});
    
    mcode.addcr;
    mcode.addcr('end');
    mcode.addcr;
    emitFilterStepCode(Hdfilt, mcode);
    
    codegenDone = true;
  end
end

if ~codegenDone
  
  % CASE 2: filter is designed via a filtering function
  
  % Identify the line that has the dfilt/mfilt constructor and create new
  % code buffer containing all lines up to that line
  Hdfilt = getfilter(this);
  Hsysobj = sysobj(Hdfilt);
      
  dmfiltIdx = mcode.find({'dfilt.','mfilt.'},'partial');
  idx = max([max(dmfiltIdx{1}) max(dmfiltIdx{2})]);
  
  % If no dfilt/mfilt constructor was found in the BaseMCode then check if
  % this is a multirate design, add the multirate code, and look for the
  % mfilt constructor again
  if isempty(idx) && strncmpi(this.filterMadeBy, 'multirate design',16)
    mcode.addcr;
    mcode.add(this.MultirateMCode);
    idx = mcode.find('mfilt.','partial');
  end
  
  isFilterCascade = isa(Hsysobj, 'dsp.FilterCascade');
  isIFIR = ~isempty(this.MCode.find('ifir(', 'partial'));
  
  bufferLines = mcode.buffer;
  inputs = {};
  % If dfilt or mfilt constructors were found then find input 'b' and
  % remove it from inputs in order to hard code the coefficients.
  % In case a FilterCascade is present, add design code only for IFIR
  if (~isFilterCascade && ~isempty(idx)) || (isFilterCascade && isIFIR)
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
        mcode.addcr;
        mcode.addcr;
    end
    if isfir(Hdfilt)
      bIdx = find(strcmp(inputs,'b'), 1);
      if ~isempty(bIdx)
        mcode.insert(1,FilterDesignDialog.message('FDESIGNComments'));
        commentIdx = mcode.find('b  = ','partial');
        commentIdx2 = mcode.find(');','partial');
        commentIdx = min(commentIdx2(commentIdx2>=commentIdx));
        mcode.MaxWidth = mcode.MaxWidth + 2;
        commentlines(mcode,1,commentIdx)
        mcode.addcr;
        if length(inputs) == 1
          inputs = {};
        else
          inputs{bIdx} = '';
        end
      elseif (isFilterCascade && isIFIR)
        mcode.insert(1,FilterDesignDialog.message('FDESIGNComments'));
        commentIdx = mcode.find('ifir(','partial');
        mcode.MaxWidth = mcode.MaxWidth + 2;
        commentlines(mcode,1,commentIdx)
        mcode.addcr;
      end
    else
      sosIdx = find(strcmp(inputs,'sos_var'), 1);
      if ~isempty(sosIdx)
        mcode.insert(1,FilterDesignDialog.message('FDESIGNComments'));
        commentIdx = mcode.find('g] = ','partial');
        if isempty(commentIdx)
          commentIdx = mcode.find('sos_var] = ','partial');
        end
        commentIdx2 = mcode.find(');','partial');
        commentIdx = min(commentIdx2(commentIdx2>=commentIdx));
        mcode.MaxWidth = mcode.MaxWidth + 2;
        commentlines(mcode,1,commentIdx)
        mcode.addcr;
        if length(inputs) == 1
          inputs = {};
        else
          inputs{sosIdx} = '';          
          inputs{sosIdx+1} = '';         
        end
      end
    end
  elseif isFilterCascade
      mcode = sigcodegen.mcodebuffer;
      mcode.addcr;
  end
  
  if ~isFilterCascade
    mcode.insert(1,sprintf('%s \n','persistent Hd;'));
    mcode.insert(3,sprintf('%s \n','if isempty(Hd)'));
  end

  supportsCodegen = ~isa(Hdfilt,'mfilt.firtdecim');
  supportsCodegen = supportsCodegen && ...
      ~isa(Hsysobj, 'dsp.CoupledAllpassFilter');

  if supportsCodegen && isFilterFunctionSupportCodeGen(mcode)
    mcode.insert(1,['  % ' FilterDesignDialog.message('CCodegenCommandLineHelp') newline]);
    mcode.addcr;
  end
  
  if ~isFilterCascade
      % Generate code for the System object using the filterbuilder code
      % generator. Append it to the mcode buffer. Use the filterbuilder
      % designer abstract design class.
      source = FilterDesignDialog.AbstractDesign;
      % Passing input the 'inputs' cell of strings will make
      % getMCodeBufferSysObj set the coefficients to variables in inputs
      % instead of writing the hard coded coefficients.
      mcode = getMCodeBufferSysObj(source,mcode,Hsysobj,inputs);

      mcode.addcr;
      mcode.addcr('end');
      mcode.addcr;
      emitFilterStepCode(Hdfilt, mcode);
  else
      % Use the methods of dsp.FilterCascade
      mcode.addcr(getConstructionString(Hsysobj));
      if isprop(Hdfilt,'Arithmetic')
          % Handle filter design Quantization settings
          if strcmpi(Hdfilt.Arithmetic,'single')
              DT = 'Single precision';
              mcode.addcr(getStepString(Hsysobj,DT));
          elseif strcmpi(Hdfilt.Arithmetic,'double')
              DT = 'Double precision';
              mcode.addcr(getStepString(Hsysobj,DT));
          else
              % DT = 'Fixed point';
              mcode.addcr(getStepString(Hsysobj));
          end
      else
          mcode.addcr(getStepString(Hsysobj));
      end
  end
end

% Add the codegen pragma
if supportsCodegen && isFilterFunctionSupportCodeGen(mcode)
  mcode.insert(1,sprintf('%s \n','%#codegen'));
end

% Write the code to a file ------------------------------------------------
if nargin < 2
  [file, path] = uiputfile('*.m',...
    getString(message('signal:sigtools:sigtools:GenerateMATLABCode')),...
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
H1MsgId = 'ReturnsFilteredData';

opts.H1         = FilterDesignDialog.message(H1MsgId);
opts.outputargs = 'y';
opts.inputargs = 'x';

% Call the public writer.
genmcode(file, mcode, opts);

% Indent the code
strBuff = StringWriter;
strBuff.readfile(file);
strBuff.indentMATLABCode;
strBuff.write(file);

% Launch the editor with the file.
if launchEditorFlag
  edit(file)
end
end

function flag = isFilterFunctionSupportCodeGen(mcode)
flag = true;
idx = find(mcode,'iircomb(','partial');
if ~isempty(idx)
  flag = false;
  return;
end
idx = find(mcode,'iirpeak(','partial');
if ~isempty(idx)
  flag = false;
  return;
end
idx = find(mcode,'iirnotch(','partial');
if ~isempty(idx)
  flag = false;
  return;
end

end

function emitFilterStepCode(Hdfilt, mcode)
if isprop(Hdfilt,'Arithmetic')
    % Handle filter design Quantization settings
    if strcmpi(Hdfilt.Arithmetic,'fixed')
        % NOTE: assuming signed (SG = '1') fi input
        mcode.addcr(...
            sprintf('s = fi(x,1,%s,%s,''RoundingMethod'',''Round'',''OverflowAction'',''Saturate'');', ...
            num2str(Hdfilt.InputWordLength), ...
            num2str(Hdfilt.InputFracLength)));
        
        mcode.addcr('y = step(Hd,s);');
        
    elseif strcmpi(Hdfilt.Arithmetic,'single')
        mcode.addcr('y = step(Hd,single(x));');
    else
        mcode.addcr('y = step(Hd,double(x));');
    end
else
    mcode.addcr('y = step(Hd,x);');
end
end
