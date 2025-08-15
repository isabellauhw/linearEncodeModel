function outputVarName = getRPMTrackOutputVarName(stk)
% getOutputVarName returns the output var name

% Default output argument names
outputVarName = '[rpmOut,tOut]';

[fromCommandLine,fromAnonymousFunction,fromFile] = getCallerInfo(stk);

if ~isDesktopAndJavaAndDDGOn() || fromAnonymousFunction
    % Do not parse code if we have no desktop or if we are called from an
    % anonymous function.
    return;
elseif fromFile
    callingFile = stk(2).file;
    callingFileLine = stk(2).line;
    [~,~,callingFileExt] = fileparts(callingFile);
    fromPcodedFile = strcmp(callingFileExt,'.p');
    fromLiveEditor = strcmp(callingFileExt,'.mlx');
    if fromPcodedFile || fromLiveEditor
        return;
    end
    outputVarName = parseRPMTrackCodeFromFile(callingFile,callingFileLine);
    outputVarName = regexprep(outputVarName,';',',');
    if isempty(outputVarName)
        outputVarName = '[rpmOut,tOut]';
    end
elseif fromCommandLine
    % If call comes from command line and we have a desktop, then explore
    % the command line text, or the command line history and extract the
    % output variable name.
    callingCode = getCallHistory();
    outputVarName = parseRPMTrackCallCodeFromCmdLine(callingCode);
    outputVarName = regexprep(outputVarName,';',',');
    if isempty(outputVarName)
        outputVarName = '[rpmOut,tOut]';
    end
end

end

%==========================================================================
function [fromCommandLine,fromAnonymousFunction,fromFile] = getCallerInfo(stk)
%getCallerInfo 
fromAnonymousFunction = false;
fromFile = false;
fromCommandLine = ((numel(stk)==1) || ...
    (numel(stk)==2 && isempty(stk(2).file)));

if numel(stk)>=2 && isempty(stk(2).file)
  fromAnonymousFunction = true;
end

if numel(stk) >= 2 && ~isempty(stk(2).file)
    fromFile = true;
end

end

%==========================================================================
function outputVarName = parseRPMTrackCodeFromFile(callingFileName,callingFileLine)
% parseRPMTrackCodeFromFile Parse rpmtrack calls when they come from a file
% or script.

strBuff = StringWriter;
strBuff.readfile(callingFileName);
strBuffLines = cellstr(strBuff);

isRpmtrackCall = false;
initialCallingLine = callingFileLine;

% Find beginning and end of call to rpmtrack
% Look for relevant code below the callingFileLine
for idx = callingFileLine : numel(strBuffLines)  
  currentLine = strBuffLines{idx};
  if contains(currentLine,'rpmtrack')
    isRpmtrackCall = true;
  end  
  if ~contains(currentLine,'...')
    finalCallingLine = idx;
    break;
  end
end

if ~isRpmtrackCall
  error(message('signal:rpmtrack:InvalidLineOfCode',callingFileName));
end

% Make sure we do not have relevant code above the callingFileLine
isDone = false;
N = initialCallingLine - 1;
while ~isDone && N > 0
  currentLine = strBuffLines{N};
  if ~contains(currentLine,'...')
    isDone = true;    
  else
    N = N - 1;
  end
  initialCallingLine = N + 1;
end

codeLines = strBuffLines(initialCallingLine:finalCallingLine);
isDone = false;
while ~isDone
  % Parse code using MTREE
  [outputVarName, errFlag] = parseRPMTrackCallCode(codeLines);
  
  if (strcmp(errFlag,'incompleteCode') && ...
          (numel(strBuffLines) > finalCallingLine))
    finalCallingLine = finalCallingLine + 1;
    codeLines = strBuffLines(initialCallingLine:finalCallingLine);
  else
    isDone = true;
    if strcmp(errFlag,'incompleteCode')
      error(message('signal:rpmtrack:CannotParseCode'));
    end
  end
end

if islogical(errFlag) && errFlag
  error(message('signal:rpmtrack:InvalidLineOfCode',callingFileName));
end

end

%==========================================================================
function callHist = getCallHistory()
% Get call from command line or command line history
callHist = com.mathworks.mlservices.MLCommandHistoryServices.getSessionHistory;

end

%==========================================================================
function outputVarName = parseRPMTrackCallCodeFromCmdLine(cmdSet)
% parseRPMTrackCallCodeFromCmdLine Parse rpmtrack code coming from the
% command line.
% cmdSet can be a cell array with code lines, a java.lang.String[]
% object, or a string

codeComesFromString = ischar(cmdSet);
outputVarName = '';

if codeComesFromString
    % Code was read from the command line directly. Look for the last >>
    % prompt and get code from there and on.
    
    idx = strfind(cmdSet,'>>');
    if isempty(idx)
        return;
    elseif ((numel(idx) > 1) && (idx(end)+2 == numel(cmdSet)))
        % When calling this from test cases we have an extra set of prompt
        % symbols >> without any code after them. Remove them.
        idx = idx(1:end-1);
        cmdSet = cmdSet(1:end-3); % remove empty >> line
    end
    
    codeLines = cmdSet(idx(end)+2:end);
    
    if isempty(codeLines)
        return;
    end
    
    isDone = false;
    idx = 0;
    while ~isDone
        
        % Code must eventually be valid, but we might need to remove some
        % lines from the bottom to top until this happens.
        T = mtree(codeLines);
        
        if isempty(mtfind(T,'Kind','ERR'))
            isDone = true;
        else
            strCell = regexp(codeLines,'[\f\n\r]','split');
            if numel(strCell) == 1
                error(message('signal:rpmtrack:CannotParseCode'));
            else
                idx = idx + 1;
                codeLines = getString(strCell,1,numel(strCell)-idx);
            end
        end
    end
    
else
    N = numel(cmdSet);
    
    rpmtrackIdx = [];
    rpmtrackCallLine = [];
    % Find the place where rpmtrack is called
    for idx = N:-1:1
        cmdStr = getCodeLine(cmdSet,idx);
        rpmtrackIdx = strfind(cmdStr,'rpmtrack');
        if isempty(rpmtrackIdx)
            if (idx - 1) > 0 && ~contains(getCodeLine(cmdSet,idx-1),'...')
                break;
            end
        else
            rpmtrackCallLine = idx;
            break;
        end
    end
    
    if isempty(rpmtrackIdx)
        % We did not find a rpmtrack call so return without parsing
        % parameters
        return;
    end
    
    % Need to find beginning and end of the command
    isDone = isempty(rpmtrackIdx);
    N = rpmtrackCallLine-1;
    initLineIdx = N+1;
    while ~isDone && (N > 0)
        % Look for cont dots above the call line
        cmdStr = getCodeLine(cmdSet,N);
        if ~contains(cmdStr,'...')
            initLineIdx = N+1;
            isDone = true;
        else
            N = N-1;
        end
        if N < 1
            initLineIdx = 1;
        end
    end
    
    isDone = isempty(rpmtrackIdx);
    N = rpmtrackCallLine;
    finalLineIdx = N;
    while ~isDone && (N <= numel(cmdSet))
        % Look for cont dots below the call line
        cmdStr = getCodeLine(cmdSet,N);
        if ~contains(cmdStr,'...')
            finalLineIdx = N;
            isDone = true;
        else
            N = N+1;
        end
    end
    
    [~,codeLines] = getString(cmdSet,initLineIdx,finalLineIdx);
end

isDone = false;
while ~isDone
    % Parse code using MTREE
    [outputVarName,errFlag] = parseRPMTrackCallCode(codeLines);
        
    if (~codeComesFromString && strcmp(errFlag,'incompleteCode') && ...
            (numel(cmdSet) > finalLineIdx))
        finalLineIdx = finalLineIdx + 1;
        [~,codeLines] = getString(cmdSet,initLineIdx,finalLineIdx);
    else
        isDone = true;
        if strcmp(errFlag,'incompleteCode')
            error(message('signal:rpmtrack:CannotParseCode'));
        end
    end
end

end

%==========================================================================
function str = getCodeLine(cmdSet,N)

if isa(cmdSet,'java.lang.String[]')
    str = toCharArray(cmdSet(N)).';
else
    str = cmdSet{N};
end

end

%==========================================================================
function [str,strCell] = getString(cmdSet,initLineIdx,finalLineIdx)
if nargin < 2
    initLineIdx = 1;
    finalLineIdx = numel(cmdSet);
end

cmdSet = cmdSet(initLineIdx:finalLineIdx);

for idx = 1:numel(cmdSet)
    
    if isa(cmdSet,'java.lang.String[]') || isa(cmdSet,'java.lang.String')
        strCell{idx} = toCharArray(cmdSet(idx)).'; %#ok<*AGROW>
    else
        strCell{idx} = cmdSet{idx};
    end
    
    % Concatenate a string, do not use char since we need a one dimensional
    % string to pass to mtree
    if idx == 1
        str = strCell{idx};
    else
        str = sprintf('%s\n%s',str,strCell{idx});
    end
end

end

%==========================================================================
function [outputVarName, errFlag] = parseRPMTrackCallCode(cmdSet)
% parseRPMTrackCallCode Find output variable name and parse code
% involved in rpmtrack call
% cmdSet can be a cell array with code lines, a java.lang.String[]
% object, or a string.

% Get sting of code involving the rpmtrack call
if ischar(cmdSet)
  str = cmdSet;
else
  str = getString(cmdSet);
end

% Parse the code
[outputVarName, errFlag] = parseCode(str);


end

%==========================================================================
function [outputVariableName, errFlag] = parseCode(str)
% parseCode Parse output variable name using mtree

outputVariableName = '';
errFlag = false;


T = mtree(str);

if isempty(T)
  errFlag = true;
  return;
end

if ~isempty(mtfind(T, 'Kind', 'ERR'))
  errFlag = 'incompleteCode';
  return;
end

P = mtfind(T, 'Fun','rpmtrack');

if (isempty(P) || (count(P) > 1) || ~isempty(mtfind(full(P),'Kind','ANON')))
  % If we did not find a rpmtrack call, or we find more than one call, or
  % if call comes from anonymous function, then return with error flag set
  % to true.
  errFlag = true;
  return;
end

outputVariableName = '';
done = isempty(P);
while ~done
  P = P.trueparent;
  
  if ~isempty(P)
    E = mtfind(P,'Kind','EQUALS');
    if ~isempty(E)
      outputVariableName = convertTree2str(E.Left);
      done = true;
    end    
  else
    done = true;
  end
end

end

%==========================================================================
function str = convertTree2str(T)
%convertTree2str Get string from tree T and remove blank spaces
str = tree2str(T);
str = strrep(str,' ','');

end

%==========================================================================
function flag = isDesktopAndJavaOn()
% isDesktopAndJavaOn Check if desktop and java are available

isDesktopOn = usejava('desktop');
isJavaOn = all([usejava('jvm') usejava('swing') usejava('awt')]);
flag = isDesktopOn && isJavaOn;
end

%==========================================================================
function flag = isDesktopAndJavaAndDDGOn()
% isDesktopAndJavaAndDDGOn Check if desktop and java are available and if
% DDG is supported

isDDGOn = signal.internal.SPTCustomSettings.isDDGSupported;    
flag = isDesktopAndJavaOn && isDDGOn;
end