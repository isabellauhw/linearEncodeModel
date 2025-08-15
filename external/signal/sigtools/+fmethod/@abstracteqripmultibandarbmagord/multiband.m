function [DH,DW] = multiband(~,N,FF,GF,~,A,F,myW,iscomplex,delay)
%MULTIBAND Frequency response function called by CFIRPM (twice)

%   Copyright 1999-2017 The MathWorks, Inc.

if nargin==3
  % Return symmetry default
  if strcmp(N,'defaults')
    % Second argument (F) is cell-array of args passed later to function
    num_args = length(FF);
    % Get the delay value
    if num_args<9, delay=0; else delay=FF{9}; end
    % Use delay argument to base symmetry decision
    if isequal(delay,0), DH='even'; else DH='real'; end
    return
  end
end

% Standard call
if nargin<10
  delay = 0;
end
delay = delay + N/2;  % adjust for linear phase

DH = interp1(F(:), A(:), GF);
if iscomplex
  DH = DH .* exp(-1i*pi*GF*delay);
end
DW = interp1(F(:), myW(:), GF);

end

