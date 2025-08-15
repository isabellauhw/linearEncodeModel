function strIdx = find(this, inputVar, varargin)
%FIND Find a line or a set of lines on the string buffer
%   IDX = H.FIND(C) finds the lines of the buffer that match the specified
%   string C in their entirety. If C is a cell array of strings then FIND
%   finds the lines that match each element of the cell. When C is a
%   string, IDX is a vector containing the line indexes where the string
%   was found in the buffer. When C is a cell array, IDX is a cell array
%   with the ith element equal to a vector of indexes that indicate the
%   lines in the buffer matching the ith string. Input strings are case
%   sensitive.
%
%   IDX = H.FIND(C,TYPE) finds the lines of the buffer that partially match
%   the specified string C when TYPE is set to 'partial'. H.FIND(C,'whole')
%   is equivalent to IDX = H.FIND(C).
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
elseif ~ischar(inputVar)
  errorFlag = true;
end

if errorFlag
  error(message('signal:sigcodegen:sigcodegencatalog:InvalidNotCharNotCell'))
end

buff = this.buffer;

if strcmpi(typeFlag,'whole')
  if iscell(inputVar)
    for idx = 1:numel(inputVar)
      strIdx{idx} = find(strcmp(buff,inputVar{idx}));  %#ok<*AGROW>
    end
  else
    strIdx = find(strcmp(buff,inputVar));
  end
else
  convertToVect = false;
  if ~iscell(inputVar)
    inputVar = {inputVar};
    convertToVect = true;
  end
  
  for k = 1:numel(inputVar)
    findIdx = [];
    for p = 1:numel(buff)
      tmpIdx = strfind(buff{p},inputVar{k});
      if ~isempty(tmpIdx)
        findIdx = [findIdx p];
      end
    end
    strIdx{k} = findIdx;
  end
  if convertToVect
    strIdx = strIdx{:};
  end
end



% [EOF]