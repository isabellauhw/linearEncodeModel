function addelement(this, input)
%ADDELEMENT Add the element to the vector
%   H.ADDELEMENT(INPUT) Add INPUT to the end of the vector

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

narginchk(2,2);

data = get(this, 'Data');

% Add the input to the end of the vector
this.Data = {data{:}, input};

% Send the NewElement event with the index of the new element (the end).
sendchange(this, 'NewElement', length(this));

% [EOF]
