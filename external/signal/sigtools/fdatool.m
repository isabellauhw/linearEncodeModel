function varargout = fdatool(varargin)
%FDATOOL Filter Design & Analysis Tool.
%   The FDATOOL command will be removed in a future release. Use
%   filterDesigner instead.
%   
%   FDATOOL launches the Filter Design & Analysis Tool (FDATool).
%   FDATool is a Graphical User Interface (GUI) that allows you to
%   design or import, and analyze digital FIR and IIR filters.
%
%   If the DSP System Toolbox is installed, FDATool seamlessly
%   integrates advanced filter design methods and the ability to
%   quantize filters.
%
%   % Example:
%   %   Launch Filter Design & Analysis Tool.
%   
%   fdatool;     % Lanches fdatool
%
% See also FILTERDESIGNER, FVTOOL, SPTOOL.

%   Author(s): P. Pacheco, R. Losada, P. Costa
%   Copyright 1988-2016 The MathWorks, Inc.

warning(message('signal:fdatool:FunctionToBeRemoved'));
[varargout{1:nargout}] = filterDesigner(varargin{:});

% [EOF] fdatool.m
