function remove(this, inputVar, varargin)
%REMOVE Remove a line or a set of lines from the string buffer
%   H.REMOVE(N) removes the lines of the buffer specified in the vector of
%   integers, N.
%
%   H.REMOVE(C) removes the lines of the buffer that match the specified
%   string, C, in its entirety. If a string is not found, then the string
%   is just ignored and no error occurs. If a string is found in multiple
%   lines, all those lines are removed. Multiple strings can be removed by
%   letting C be a cell array of strings. Input strings are case sensitive.
%
%   H.REMOVE(C,TYPE) removes the lines of the buffer that partially contain
%   the string (or strings) in C when TYPE is set to 'partial'. Removes the
%   lines of the buffer that match the string (or strings) in C in its
%   entirety when TYPE is set to 'whole'. H.REMOVE(C,'whole') is equivalent
%   to H.REMOVE(C).
%
%   See also STRINGBUFFER/ADDCR, STRINGBUFFER/CRADD, STRINGBUFFER/CRADDCR,
%   STRINGBUFFER/CR, SPRINTF.

%   Copyright 2011 The MathWorks, Inc.

narginchk(2,3)

if nargin > 2
  typeFlag = varargin{1};
  if ~any(strcmpi({'whole','partial'},typeFlag))
    error(message('signal:sigcodegen:sigcodegencatalog:InvalidPartialTypeFlag'))
  end
else
  typeFlag = 'whole';
end

errorFlag = false;
if isa(inputVar,'cell')
  for idx = 1:numel(inputVar)
    if ~ischar(inputVar{idx})
      errorFlag = true;  
      break;
    end
  end  
elseif isnumeric(inputVar) 
  try validateattributes(inputVar, {'double'}, {'integer','vector'}, '', 'numeric input vector N');
  catch %#ok<CTCH>
     errorFlag = true;  
  end
elseif ~ischar(inputVar)
   errorFlag = true;  
else
  inputVar = {inputVar};
end

if errorFlag
  error(message('signal:sigcodegen:sigcodegencatalog:InvalidNotCharNotCellNotInt'))
end

buff = this.buffer;

if iscell(inputVar)
  if strcmpi(typeFlag,'whole')
    for idx = 1:numel(inputVar)
      strIdx = strcmp(buff,inputVar{idx});
      buff(strIdx) = [];
    end
  else % typeFlag = 'partial'
    rmvIdx = [];
    for p = 1:numel(inputVar)
      for k = 1:numel(buff)
        strIdx = strfind(buff{k},inputVar{p});
        if ~isempty(strIdx)
         rmvIdx = [rmvIdx k]; %#ok<AGROW>                 
        end
      end
    end
    buff(unique(rmvIdx)) = [];   
 end  
else
  if any(inputVar > numel(buff))
    error(message('signal:sigcodegen:sigcodegencatalog:InvalidIndex'))
  end
   buff(inputVar) = [];
end
  
this.clear;
this.add(buff);

  


% [EOF]