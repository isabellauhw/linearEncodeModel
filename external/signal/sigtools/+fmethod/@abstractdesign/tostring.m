function str = tostring(this,varargin)
%TOSTRING

%   Copyright 1999-2017 The MathWorks, Inc.

% Search for ('sigOnlyDesOpts',value) p-v pair. VALUE must be a structure
% containing signal-only design options. This input will only be passed
% when design comes from designfilt function. 
reduceDesOptsFlag = false;
if nargin > 1 && isfromdesignfilt(this)
  for idx = 1:numel(varargin)
    if ischar(varargin{idx}) && strcmpi(varargin{idx},'sigOnlyDesOpts')
      sigOnlyDesOpts = fieldnames(varargin{idx+1});      
    end    
  end
  reduceDesOptsFlag = true;
end

[s, fn] = getdesignoptstostring(this);

if reduceDesOptsFlag
  fn = intersect(fn,sigOnlyDesOpts,'stable');
end

nfields = length(fn);
value   = cell(1,nfields);
for nc = 1:length(fn)
  val = s.(fn{nc});
  if iscell(val)
    str = ['{',tostr(val{1})];
    for k = 2:length(val)
      str = [str,[', ',tostr(val{k})]]; %#ok<*AGROW>
    end
    str = [str,'}'];
    value{nc} = str;
  elseif isscalar(val) && ishandle(val) && ~isnumeric(val)
    childfn = fieldnames(val);
    tempfn  = cell(size(childfn));
    tempval = cell(size(childfn));
    nfields = nfields + length(childfn) - 1;
    for jndx = 1:length(childfn)
      name = designoptstostringnames(childfn{jndx});
      tempfn{jndx}  = sprintf('%s', name);
      tempval{jndx} = tostr(val.(childfn{jndx}));
    end
    fn{nc}    = char(tempfn); %#ok<*VCAT>
    value{nc} = char(tempval);
  else
    if isnumeric(val)
      val = val(:).'; % make sure values are in a row vector
    end
    value{nc} = tostr(val);
    fn{nc} = designoptstostringnames(fn{nc});
  end
  
  if size(fn{nc},1) == 1 && any(regexp(fn{nc},'B.ForcedFrequencyPoints'))
    if ~this.privActualNormalizedFreq
      [val , ~, valprefix] = engunits(val);
      post    = sprintf(' %sHz', valprefix);
      value{nc} = [tostr(val) post];
    end
  end
end
if ~isempty(fn)
  str = [char(fn) repmat(' : ', nfields, 1) char(value)];
else
  str = '';
end

%--------------------------------------------------------------------------
function str = tostr(val)
if isnumeric(val) && ~isempty(val)
  str = num2str(val);
elseif islogical(val) && val
  str = 'true';
elseif islogical(val)
  str = 'false';
elseif isempty(val)
  str = ' ';
elseif isa(val,'function_handle')
  str = ['@',func2str(val)];
else
  if strcmp(val,'Not used')
    val = lower(val);
  end
  str = val;
end
%--------------------------------------------------------------------------
function nameOut = designoptstostringnames(nameIn)
switch nameIn
  case 'MatchExactly'
    nameOut = getString(message('signal:dfilt:info:MatchExactly'));
  case 'SOSScaleNorm'
    nameOut = getString(message('signal:dfilt:info:ScaleNorm'));
  case 'sosReorder'
    nameOut = getString(message('signal:dfilt:info:ReorderRule'));
  case 'MaxNumerator'
    nameOut = getString(message('signal:dfilt:info:MaximumNumeratorValue'));
  case 'NumeratorConstraint'
    nameOut = getString(message('signal:dfilt:info:NumeratorConstraint'));
  case 'OverflowMode'
    nameOut = getString(message('signal:dfilt:info:OverflowMode'));
  case 'ScaleValueConstraint'
    nameOut = getString(message('signal:dfilt:info:ScaleValueConstraint'));
  case 'ScalePassband'
    nameOut = getString(message('signal:dfilt:info:ScalePassband'));
  case 'MaxScaleValue'
    nameOut = getString(message('signal:dfilt:info:MaximumScaleValue'));
  case 'DensityFactor'
    nameOut = getString(message('signal:dfilt:info:DensityFactor'));
  case 'MaxPhase'
    nameOut = getString(message('signal:dfilt:info:MaximumPhase'));
  case 'MinOrder'
    nameOut = getString(message('signal:dfilt:info:MinimumOrder'));
  case 'MinPhase'
    nameOut = getString(message('signal:dfilt:info:MinimumPhase'));
  case 'StopbandDecay'
    nameOut = getString(message('signal:dfilt:info:StopbandDecay'));
  case 'StopbandShape'
    nameOut = getString(message('signal:dfilt:info:StopbandShape'));
  case 'UniformGrid'
    nameOut = getString(message('signal:dfilt:info:UniformGrid'));
  case 'SincFrequencyFactor'
    nameOut = getString(message('signal:dfilt:info:SincFrequencyFactor'));
  case 'SincPower'
    nameOut = getString(message('signal:dfilt:info:SincPower'));
  case 'Wpass'
    nameOut = getString(message('signal:dfilt:info:Wpass'));
  case 'Wpass1'
    nameOut = getString(message('signal:dfilt:info:Wpass1'));
  case 'Wpass2'
    nameOut = getString(message('signal:dfilt:info:Wpass2'));
  case 'Wstop'
    nameOut = getString(message('signal:dfilt:info:Wstop'));
  case 'Wstop1'
    nameOut = getString(message('signal:dfilt:info:Wstop1'));
  case 'Wstop2'
    nameOut = getString(message('signal:dfilt:info:Wstop2'));
  case {'B1Weights','B2Weights','B3Weights','B4Weights','B5Weights',...
      'B6Weights','B7Weights','B8Weights','B9Weights','B10Weights'}
    
    if strcmp(nameIn(3),'0')
      num = 10;
    else
      num = str2double(nameIn(2));
    end
    
    switch num
      case 1
        prefix = getString(message('signal:dfilt:info:First'));
      case 2
        prefix = getString(message('signal:dfilt:info:Second'));
      case 3
        prefix = getString(message('signal:dfilt:info:Third'));
      case 4
        prefix = getString(message('signal:dfilt:info:Fourth'));
      case 5
        prefix = getString(message('signal:dfilt:info:Fifth'));
      case 6
        prefix = getString(message('signal:dfilt:info:Sixth'));
      case 7
        prefix = getString(message('signal:dfilt:info:Seventh'));
      case 8
        prefix = getString(message('signal:dfilt:info:Eighth'));
      case 9
        prefix = getString(message('signal:dfilt:info:Ninth'));
      case 10
        prefix = getString(message('signal:dfilt:info:Tenth'));
    end
    nameOut = [prefix ' ' getString(message('signal:dfilt:info:BandWeights'))];        
  otherwise        
    nameOut = getTranslatedString('signal:dfilt:info',nameIn);
end


