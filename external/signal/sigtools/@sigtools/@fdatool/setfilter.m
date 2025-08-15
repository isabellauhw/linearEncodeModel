function setfilter(this, filt, varargin)
%SETFILTER Sets the current filter and the reference filter (optional) in FDATool.
%   hFDA.SETFILTER(FILT) sets the filter object, FILT, as the current
%   filter in FDATool.  FILT must be a DFILT object.
%
%   hFDA.SETFILTER(FILT, OPTS) uses the structure OPTS to determine how to
%   set the filter.
%
%   Fields of OPTS
%       source      - String containing the source.
%       filedirty   - Boolean flag which will make the file dirty if true.
%       update      - Boolean flag which will cause the 'FilterUpdated'
%                     event to be sent.
%       fs          - Sampling Frequency of the filter.  [] is normalized.
%       name        - String to name the filter.
%
%   See also GETFILTER.

%   Copyright 1988-2017 The MathWorks, Inc.

% Check number of inputs
narginchk(2,3);
validate_inputs(filt);

% Parse optional inputs
options = parse_optional_inputs(this, varargin{:});

if options.filedirty
  sendfiledirty(this);
else
  set(this, 'FileDirty', false);
end

% Not every call to set filter sets a new source
if ~isempty(options.source), set(this,'filterMadeBy',options.source); end

if ~isa(filt, 'dfilt.dfiltwfs')
  filt = dfilt.dfiltwfs(filt, options.fs, options.name);
end

% Save the MCode before setting the filter in case quantize is on.
% Quantize will intercept the filter and add its own mcode. Pass the new
% filter in the options structure so that it can be used by the savemcode
% method.
options.NewFilter = filt.Filter;
savemcode(this, options);

% Set filter
this.Filter = filt;

% Update GUI
if options.update
  if options.fastupdate
    send(this,'FastFilterUpdated',handle.EventData(this,'FastFilterUpdated'));
  else
    send(this,'FilterUpdated',handle.EventData(this,'FilterUpdated'));
  end
  if ~strcmpi(get(this.figurehandle, 'Tag'), 'initializing') && options.default
    send(this, 'DefaultAnalysis', handle.EventData(this, 'DefaultAnalysis'));
  end
end

%----------------------------------------------------------------------
function savemcode(this, options)

% Save any mcode information.

% MATLAB code generation not supported when the filter has been edited in
% the pz editor. 
if strcmpi(this.McodeType,'pzeditor')
  this.MCodeSupported = false;
end

if isfield(options, 'mcode') && ~isempty(options.mcode)
  if isempty(this.MCode)
      this.MCode = sigcodegen.mcodebuffer;
  end
  if isempty(this.BaseMCode)
      this.BaseMCode = sigcodegen.mcodebuffer;
  end
  if isempty(this.MultirateMCode)
      this.MultirateMCode = sigcodegen.mcodebuffer;
  end
  if isempty(this.FxPtMCode)
      this.FxPtMCode = sigcodegen.mcodebuffer;
  end
  if isequal(this.MCode, options.mcode)
    return;
  end
  if ~iscell(options.mcode), options.mcode = {options.mcode}; end
  
  % We keep the base code (that contains the coefficients or the
  % coefficient design), the fixed point code, and the multirate code in
  % separate buffers. We put together the final code in the MCode buffer.
  if options.resetmcode
    this.MCode.clear;
    this.MCode.add(options.mcode);
    idx = this.Mcode.find('''Arithmetic'',','partial');
    if strcmpi(this.McodeType,'import') && length(idx) == 1
      % We enter this branch when we import a filter object with a
      % non-double arithmetic. The fixed point code comes appended to
      % the code from the start and we need to save this code in the
      % FxPtMCode property. We need to remove the fixed point code from
      % the base code.
      fxPtLines = this.MCode.getline(idx:length(this.Mcode.buffer));
      this.FxPtMCode.add(fxPtLines);
      this.BaseMCode.clear;
      this.BaseMCode.add(this.MCode);
      this.BaseMCode.remove(idx:length(this.Mcode.buffer));
      if isprop(options.NewFilter,'Arithmetic') && ...
          strcmpi(options.NewFilter.Arithmetic,'double')
        this.MCode.remove(idx:length(this.Mcode.buffer));
      end
    else
      this.FxPtMCode.clear;
      this.BaseMCode.clear;
      this.BaseMCode.add(this.MCode);
    end
    % Initialize the rest of the flags and buffers
    
    % MultirateMCode buffer keeps the multirate code
    this.MultirateMCode.clear; 
    % The DesignedCoefficientsInputVar property keeps the string with the
    % variable name used in a multirate filter that was designed from an
    % existing filter.
    this.DesignedCoefficientsInputVar = '';
    % The IsSOSConvertedMCode flag is true when the filter has gone through an
    % SOS operation such as reorder, scale, or convert to SOS or to single
    % section filter. 
    this.IsSOSConvertedMCode = false;
    % The IsSpecialCaseStructMCode flag is true when the filter is a
    % lattice structure or has been converted to one. It is also true when
    % the filter is a delay, allpass or multistage structure. The
    % MCodeSupported, and SysObjMCodeSupported  flags are used in
    % toolbox\signal\sigtools\@sigtools\@fdatool\thisrender.m to decide if
    % MATLAB code generation menus are enabled or not
    if islattice(options.NewFilter) || ...
        iscoupledallpass(options.NewFilter) || ...
        isa(options.NewFilter,'dfilt.abstractallpass') || ...
        isa(options.NewFilter,'dfilt.multistage') || ...
        isa(options.NewFilter,'dfilt.delay')
      this.IsSpecialCaseStructMCode = true;
      if sysobj(options.NewFilter,true)
        % System objects do support latticemamin structures (although they
        % do not support conversions to other structures afterwards)
        this.SysObjMCodeSupported = true;
      else
        this.SysObjMCodeSupported = false;
      end
    else
      this.IsSpecialCaseStructMCode = false;
      this.SysObjMCodeSupported = true;
    end    
    this.MCodeSupported = true;
        
    % The SysObjConvertStructLines is a buffer to store convert structure
    % lines of the System object MATLAB code generation. This buffer is
    % used in toolbox\signal\sigtools\@sigtools\@fdatool\genmcodesysobj.m
    % and toolbox\signal\sigtools\@sigtools\@fdatool\genfilterfcnsysobj.m
    this.SysObjConvertStructLines = {};
  else % The reset flag is false so we need to update the current code
    if isempty(this.BaseMCode)
      return;
    end
    this.MCode.clear;
    this.MCode.add(this.BaseMCode);
            
    if strcmpi(this.McodeType,'convert')
            
      % If we convert to an unsupported structure, then we disable
      % codegen for System objects until a code reset occurs.
      if this.IsSOSConvertedMCode && ~sysobj(options.NewFilter,true)
        this.SysObjMCodeSupported = false;
      end            
      
      % Leave if dealing with a CIC filter, hold interpolator, or linear
      % interpolator. The conversion is to the same structure so we do not
      % need to do anything in the code.
      currentFilter = getfilter(this);
      if isa(currentFilter,'mfilt.abstractcic') || ...
          isa(currentFilter,'mfilt.holdinterp') || ...
          isa(currentFilter,'mfilt.linearinterp')
        return;
      end
      
      % We cannot just replace the dfilt or fdesign constructor with the
      % new structure when dealing with lattice, coupled all pass, or
      % multistage structures. For these cases just add the convert method
      % line and set the IsSpecialCaseStructMCode flag to true.
      if this.IsSpecialCaseStructMCode || islattice(options.NewFilter) || ...
          iscoupledallpass(options.NewFilter)
                
        this.MCode.cr;
        this.MCode.cr;
        this.MCode.add(options.mcode);
        this.BaseMCode.cr;
        this.BaseMCode.cr;
        this.BaseMCode.add(options.mcode);        
        this.IsSpecialCaseStructMCode = true;
        this.SysObjMCodeSupported = false;
        return;
      end
      
      % Code to convert structure - directly convert the structure in the
      % constructor instead of calling the convert method.
      if strncmpi(this.filterMadeBy,'multirate design',16) && ~isempty(this.MultirateMCode)
        % Find the convert call, read the new structure and replace the
        % structure in the mfilt constructor.
        tmpBuff = sigcodegen.mcodebuffer(options.mcode{:});
        codeLine = tmpBuff.getline(tmpBuff.find('convert(','partial'));
        idxBegin = strfind(codeLine{:},',')+1;
        idxEnd = strfind(codeLine{:},')')-1;
        newStrucName = codeLine{1}(idxBegin:idxEnd);
        newStrucName = strrep(newStrucName,'''','');
        newStrucName = newStrucName(~isspace(newStrucName));
        codeLineIdx = this.MultirateMCode.find('mfilt.','partial');
        codeLine = this.MultirateMCode.getline(codeLineIdx);
        idxBegin = strfind(codeLine{:},'mfilt.')+6;
        idxEnd = strfind(codeLine{:},'(')-1;
        oldStrucName = codeLine{:}(idxBegin:idxEnd);
        codeLine = strrep(codeLine,oldStrucName,newStrucName);
        this.MultirateMCode.replace(codeLineIdx,codeLine);
        this.MCode.clear;
        this.MCode.add(this.BaseMCode);
        this.Mcode.cr;
        this.Mcode.cr;
        this.Mcode.add(this.MultirateMCode);
      elseif isempty(this.BaseMCode.find('fdesign','partial')) && ~this.IsSOSConvertedMCode
        % Find the convert call, read the new structure and replace the
        % structure in the dfilt constructor.
        tmpBuff = sigcodegen.mcodebuffer(options.mcode{:});
        codeLine = tmpBuff.getline(tmpBuff.find('convert(','partial'));
        idxBegin = strfind(codeLine{:},',')+1;
        idxEnd = strfind(codeLine{:},')')-1;
        newStrucName = codeLine{1}(idxBegin:idxEnd);
        newStrucName = strrep(newStrucName,'''','');
        newStrucName = newStrucName(~isspace(newStrucName));
        codeLineIdx = this.BaseMCode.find('dfilt.','partial');
        searchStr = 'dfilt.';
        if isempty(codeLineIdx)
          % It could be a default Nyquist design
          codeLineIdx = this.BaseMCode.find('mfilt.','partial');
          searchStr = 'mfilt.';
        end
        codeLine = this.BaseMCode.getline(codeLineIdx);
        idxBegin = strfind(codeLine{:},searchStr)+6;
        idxEnd = strfind(codeLine{:},'(')-1;
        oldStrucName = codeLine{:}(idxBegin:idxEnd);
        codeLine = strrep(codeLine,oldStrucName,newStrucName);
        this.BaseMCode.replace(codeLineIdx,codeLine);
        this.MCode.clear;
        this.MCode.add(this.BaseMCode);
      elseif ~this.IsSOSConvertedMCode
        % Has fdesign, use the structure directly in the design method
        % Find the convert call, read the new structure and add the
        % 'FilterStructure' design option to the design method call.
        tmpBuff = sigcodegen.mcodebuffer(options.mcode{:});
        codeLine = tmpBuff.getline(tmpBuff.find('convert(','partial'));
        idxBegin = strfind(codeLine{:},',')+1;
        idxEnd = strfind(codeLine{:},')')-1;
        newStrucName = codeLine{1}(idxBegin:idxEnd);
        newStrucName = strrep(newStrucName,'''','');
        newStrucName = newStrucName(~isspace(newStrucName));
        
        lineToChangeIdx = this.BaseMCode.find('''FilterStructure'',','partial');
        if isempty(lineToChangeIdx)
          % If BaseMcode does not contain a FilterStructure input in the
          % call to the design method, then add one
          designLine = this.BaseMCode.find('design(','partial');
          endLineIdx = this.BaseMCode.find(');','partial');
          lineToChangeIdx = min(endLineIdx(endLineIdx>=designLine));
          lineToChange = this.BaseMCode.getline(lineToChangeIdx);
          idx = strfind(lineToChange{:},');');
          newLine = [lineToChange{:}(1:idx-1) ', ''FilterStructure'', ''' newStrucName ''');'];
        else
          % If BaseMcode contains a FilterStructure input, then replace
          % the structure with the new one.
          lineToChange = this.BaseMCode.getline(lineToChangeIdx);
          idxBegin = strfind(lineToChange{:},'''FilterStructure'', ''');
          if isempty(idxBegin)
            % The structure is in the next line of code
            lineToChangeIdx = lineToChangeIdx+1;
            lineToChange = this.BaseMCode.getline(lineToChangeIdx);
            idx = strfind(lineToChange{:},'''');
            oldStrucName = lineToChange{:}(idx(1)+1:idx(2)-1);
          else
            % The structure is in the same line of code as the
            % FilterStructure input
            idxEnd = strfind(lineToChange{:},''');')-1;
            oldStrucName = lineToChange{:}(idxBegin+20:idxEnd);
            oldStrucName = oldStrucName(~isspace(oldStrucName));
          end
          newLine = strrep(lineToChange,oldStrucName,newStrucName);
        end
        this.BaseMCode.replace(lineToChangeIdx, newLine);
        this.MCode.clear;
        this.MCode.add(this.BaseMCode);
      else
        this.MCode.cr;
        this.MCode.cr;
        this.MCode.add(options.mcode);
        this.BaseMCode.cr;
        this.BaseMCode.cr;
        this.BaseMCode.add(options.mcode);
      end
    elseif strcmpi(this.McodeType,'quantize')
      % Fixed point code
      if ~isempty(this.MultirateMCode)
        this.Mcode.cr;
        this.Mcode.add(this.MultirateMCode);
      end
      if ~strcmp(string(options.mcode{:}),'set(Hd, ''Arithmetic'', ''double'');')
        % Add fixed point code only when Arithmetic is not double
        this.Mcode.cr;
        this.MCode.add(options.mcode);
        this.FxPtMCode.clear;
        this.FxPtMCode.add(options.mcode);
      end
    elseif strcmpi(this.McodeType,'multirate')
      % Multirate filter design code
      this.MultirateMCode.clear;
      this.MultirateMCode.add(options.mcode);
      inputIdx = this.BaseMCode.find({'(b);','(Numerator);','num);'},'partial');      
      idxXform = this.BaseMcode.find({'firlp2hp','firlp2lp'},'partial');
      idxXform = [idxXform{~cellfun(@isempty,idxXform)}];      
      if ~isempty(inputIdx{1}) && isempty(idxXform)
        % Remove the dfilt/mfilt constructor and replace it with new
        % mfilt constructor. Replace num in the new constructor with the
        % coefficients variable name 'b'. We enter this branch when
        % designing a multirate filter from an FIR filter previously
        % designed in the design panel.
        this.BaseMCode.remove(inputIdx{1});
        this.MultirateMCode.remove('get(Hd, ''Numerator'');','partial');
        constructIdx = this.MultirateMCode.find('Hd  = ','partial');
        lineStr = this.MultirateMCode.getline(constructIdx);
        lineStr = strrep(lineStr,'num','b');
        this.MultirateMCode.replace(constructIdx,lineStr);
        this.DesignedCoefficientsInputVar = 'b';
      elseif ~isempty(inputIdx{2}) && isempty(idxXform)
        % Remove the dfilt/mfilt constructor and replace it with new
        % mfilt constructor. Replace num in the new constructor with the
        % coefficients variable name 'Numerator'. We enter this branch
        % when designing a multirate filter from an imported set of
        % coefficients.
        this.BaseMCode.remove(inputIdx{2});
        this.MultirateMCode.remove('get(Hd, ''Numerator'');','partial');
        constructIdx = this.MultirateMCode.find('Hd  = ','partial');
        lineStr = this.MultirateMCode.getline(constructIdx);
        lineStr = strrep(lineStr,'num','Numerator');
        this.MultirateMCode.replace(constructIdx,lineStr);
        this.DesignedCoefficientsInputVar = 'Numerator';
      elseif ~isempty(inputIdx{3}) && isempty(idxXform)
        % We enter this branch when we are designing a multirate filter
        % from an imported multirate filter object
        this.BaseMCode.remove(inputIdx{3});
        this.BaseMCode.remove({'decf','intf'},'partial');
        this.MultirateMCode.remove('get(Hd, ''Numerator'');','partial');
        this.DesignedCoefficientsInputVar = 'num';
      elseif ~isempty(this.DesignedCoefficientsInputVar)
        % We enter this branch when we design a multirate filter from
        % another multirate filter previously designed in the multirate
        % panel using the 'Use current FIR filter' option.
        this.MultirateMCode.remove('get(Hd, ''Numerator'');','partial');
        constructIdx = this.MultirateMCode.find('Hd  = ','partial');
        lineStr = this.MultirateMCode.getline(constructIdx);
        lineStr = strrep(lineStr,'num',this.DesignedCoefficientsInputVar);
        this.MultirateMCode.replace(constructIdx,lineStr);
      elseif isempty(idxXform)
        % We enter here when the design comes from a default Nyquist FIR
        % filter.        
        this.MultirateMCode.remove('get(Hd, ''Numerator'');','partial');
        idxConstructLine = this.MultirateMCode.find('num);','partial');
        constructLine = this.MultirateMCode.getline(idxConstructLine);        
        constructLine = strrep(constructLine{:},', num','');
        this.MultirateMCode.replace(idxConstructLine,constructLine);
        this.BaseMCode.clear;
        this.BaseMCode.add(this.MultirateMCode);
        this.MultirateMCode.clear;
      end
      this.MCode.clear;
      this.MCode.add(this.BaseMCode);
      if ~isempty(this.MultirateMCode)
        % Avoid adding cr's if MultirateMCode is empty
        this.Mcode.cr;
        this.Mcode.cr;
        this.Mcode.add(this.MultirateMCode);
      end
    elseif strcmpi(this.McodeType,'xform')
      this.MCode.cr;
      this.MCode.add(options.mcode);
      this.MCode.cr;
      this.MCode.add(this.FxPtMCode);
      this.BaseMCode.cr;
      this.BaseMCode.add(options.mcode);
      this.SysObjMCodeSupported = false;
    elseif strcmpi(this.McodeType,'sos') || ...
        strcmpi(this.McodeType,'convert2singlesection') || ...
        strcmpi(this.McodeType,'converttosos')
      this.MCode.cr;
      this.MCode.cr;
      this.MCode.add(options.mcode);
      this.MCode.cr;
      this.MCode.cr;
      this.MCode.add(this.FxPtMCode);
      this.BaseMCode.cr;
      this.BaseMCode.cr;
      this.BaseMCode.add(options.mcode);
      if strcmpi(this.McodeType,'convert2singlesection') || ...
          strcmpi(this.McodeType,'converttosos')
        this.SysObjMCodeSupported = false;
      end
      % This flag indicates that the filter has gone through an SOS
      % transformation. 
      this.IsSOSConvertedMCode = true;      
    end
  end
  
else
  if isfield(options, 'mcode') && isequal(this.MCode, options.mcode)
    return;
  end
  if isempty(this.MCode)
    if isempty(ishandle(this.MCode))
      % Create an empty buffer, don't leave a null there.  null
      % means the user hasn't done anything and the generated code
      % will be for the default filter.
      this.MCode = sigcodegen.mcodebuffer;
    end
  elseif ~isempty(options.source) && options.update 
    this.MCode.clear;
  end
end

%----------------------------------------------------------------------
function defaultopts = parse_optional_inputs(h, options)
%PARSE_OPTIONAL_INPUTS Parse the optional inputs to SETFILTER

% Defaults
oldfilt = get(h, 'Filter');
if isempty(oldfilt)
  fs   = [];
  name = '';
else
  fs   = get(oldfilt, 'Fs');
  name = get(oldfilt, 'Name');
end

if strcmpi('pzeditor', h.McodeType)
  name = '';
end

defaultopts = struct('update', true, ...
  'default', true, ...
  'source', '', ...
  'fastupdate', false, ...
  'resetmcode', false, ...
  'name', name, ...
  'fs', fs, ...
  'filedirty', 1);

if nargin > 1
  if ~isstruct(options)
    error(message('signal:sigtools:fdatool:setfilter:SigErr'))
  else
    defaultopts = setstructfields(defaultopts, options);
  end
end

%----------------------------------------------------------------------
function validate_inputs(filt)
%VALIDATE_INPUTS Validate the inputs

if ~isa(filt, 'dfilt.basefilter') && ~isa(filt, 'dfilt.dfiltwfs')
  error(message('signal:sigtools:fdatool:setfilter:SecondInputMustBeFilter'))
end

if isa(filt, 'adaptfilt.baseclass')
  error(message('signal:sigtools:fdatool:setfilter:NotSupportAdaptFilters'))
end

if isa(filt, 'dfilt.statespace')
  error(message('signal:sigtools:fdatool:setfilter:NotSupportSSFilters'))
end

if isa(filt, 'dfilt.farrowfd') || isa(filt, 'dfilt.farrowlinearfd') || ...
    isa(filt, 'mfilt.farrowsrc')
  error(message('signal:sigtools:fdatool:setfilter:NotSupportFarrowFilters'))
end

% [EOF]
