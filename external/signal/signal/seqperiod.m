function [P,N] = seqperiod(X)  %#ok<STOUT,INUSD>
%SEQPERIOD Find minimum-length repeating sequence in a vector.
% 
%  P = SEQPERIOD(X) returns the index P of the sequence of samples X(1:P)
%  which is found to repeat (possibly multiple times) in X(P+1:end).  P is
%  the sample period of the repetitive sequence. No intervening samples may
%  be present between repetitions.  An incomplete repetition is permitted
%  at the end of X. If no repetition is found, the entire sequence X is
%  returned as the minimum-length sequence and hence P=length(X).
%
%  P = SEQPERIOD(X,TOL) specifies TOL as the absolute tolerance to
%  determine when two numbers are close enough to be considered equal. TOL
%  is a positive scalar. The tolerance defaults to 1e-10.
%
%  [P,N] = SEQPERIOD(...) returns the number of repetitions N of the
%  sequence X(1:P) in X. N is always >= 1 and may have noninteger values.
%
%  If X is a matrix or N-D array, the sequence period is determined along
%  the first array dimension of X with size greater than 1.
%
%   % Example 1:
%   %   Define data and find the minimum-length repeating sequence in it.
%
%   x = repmat([32,43,54],1,4)      % Defining data 
%   P = seqperiod(x)                % Minimum-length repeating sequence
%
%   % Example 2:
%   %   Find the period of each of the column-subsequences of the matrix.
%
%   x = [4 0 1 6; 
%        2 0 2 7; 
%        4 0 1 5; 
%        2 0 5 6];
%   P = seqperiod(x)
%
%   % Example 3:
%   %   Find the period and the number of repetitions of a sine wave.
%
%   x = sin(pi./4*(0:17)); 
%   [P,N] = seqperiod(x,1e-5)

%  Copyright 1988-2019 The MathWorks, Inc.

% The following comment, MATLAB compiler pragma, is necessary to avoid
% compiling this file instead of linking against the MEX-file.  Don't
% remove.
%# mex

error(message('signal:seqperiod:NotSupported'));

% [EOF] seqperiod.m
