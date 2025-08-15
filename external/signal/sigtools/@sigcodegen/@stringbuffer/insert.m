function insert(this, inputIdx,inputStrs)
%INSERT Insert a line or a set of lines at the specified line index
%   H.INSERT(IDX,C) inserts a string C, or a set of strings available in
%   the cell array C, at the IDX-th line of the buffer. IDX is an integer
%   scalar. 
%
%   See also STRINGBUFFER/ADDCR, STRINGBUFFER/CRADD, STRINGBUFFER/CRADDCR,
%   STRINGBUFFER/CR, SPRINTF.

%   Copyright 2011 The MathWorks, Inc.

validateattributes(inputIdx, {'double'}, {'integer','scalar'}, '', 'index value');
errorFlag = false;
if isa(inputStrs,'cell')
  for idx = 1:numel(inputStrs)
    if ~ischar(inputStrs{idx})
      errorFlag = true;  
      break;
    end
  end  
elseif ~ischar(inputStrs)
   errorFlag = true;  
else
  inputStrs = {inputStrs};
end

if errorFlag
  error(message('signal:sigcodegen:sigcodegencatalog:InvalidNotCharNotCell'))
end

buff = this.buffer;

if any(inputIdx > numel(buff))
  error(message('signal:sigcodegen:sigcodegencatalog:InvalidIndexScalar'))
end

this.clear;
if inputIdx == numel(buff)
  buff = [buff inputStrs];
else
  buff = [buff(1:inputIdx-1) inputStrs buff(inputIdx:end)];
end
this.add(buff);

