function replace(this, idxVect,inputStrs)
%REPLACE Replace a line or a set of lines of the string buffer
%   H.REPLACE(N,C) repaces the Nth line of the buffer, H, with the line
%   specified in string C. If N is a vector of integers and C is a cell
%   array of strings, then the REPLACE replaces multiple lines specified in
%   N with the strings specified in C. In this case, N and C must have the
%   same number of elements.
%
%   See also STRINGBUFFER/ADDCR, STRINGBUFFER/CRADD, STRINGBUFFER/CRADDCR,
%   STRINGBUFFER/CR, SPRINTF.

%   Copyright 2011 The MathWorks, Inc.

validateattributes(idxVect, {'double'}, {'integer','vector'}, '', 'vector of line indices');
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

if numel(idxVect)~=numel(inputStrs)
  error(message('signal:sigcodegen:sigcodegencatalog:InvalidIndxVectStrCell'))
end

buff = this.buffer;

if any(idxVect > numel(buff))
  error(message('signal:sigcodegen:sigcodegencatalog:InvalidIndex'))
end

for idx = 1:numel(idxVect)
  buff{idxVect(idx)} = inputStrs{idx};
end

this.clear;
this.add(buff);

