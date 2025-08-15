function a = sysmatrix(den,N,M)
%SYSMATRIX  Build the system matrix for df2, also used for FIR df1
%           and df1t

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.

a = [-den(2:end) zeros(1,N-M);
        eye(N-1) zeros(N-1,1)];

