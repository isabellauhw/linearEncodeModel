function c = getline(this, idxInput)
%GETLINE Gets specified buffer lines
%   C = H.GETLINE(N) gets the buffer lines specified in vector of integers
%   N and returns them in cell array of strings output C.
%
%   See also STRINGBUFFER/ADDCR, STRINGBUFFER/CRADD, STRINGBUFFER/CRADDCR,
%   STRINGBUFFER/CR, SPRINTF.

%   Copyright 2011 The MathWorks, Inc.

validateattributes(idxInput, {'double'}, {'integer','vector'}, '', 'vector of line indices');

buff = this.buffer;

if any(idxInput > numel(buff))
  error(message('signal:sigcodegen:sigcodegencatalog:InvalidIndex'))
end

c = buff(idxInput);


