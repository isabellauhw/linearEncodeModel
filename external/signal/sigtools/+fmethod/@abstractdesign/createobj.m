function Hd = createobj(this,coeffs)
%CREATEOBJ   

%   Copyright 1999-2015 The MathWorks, Inc.

struct = get(this, 'FilterStructure');


% Add pragmas of dfilt classes that cause compiler failures
%#function dfilt.fftfir

Hd = feval(['dfilt.' struct], coeffs{:});

% [EOF]
