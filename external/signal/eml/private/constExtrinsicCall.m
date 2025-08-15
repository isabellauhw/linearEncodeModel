function varargout = constExtrinsicCall(fname,varargin)
%MATLAB Code Generation Private Function

%   Ideally, this would be as simple as
%
%   [varargout{1:nargout}] = coder.const('feval',fname,varargin{:});
%
%   but when evaluating code coverage in interpreted mode, we need to
%   dispatch to the MATLAB version of the function fname, and in
%   interpreted mode that won't happen unless we pass through a function
%   that is not in the same directory or the private directory of the
%   codegen version of fname. Here, eml_try_catch serves that purpose.

% Copyright 2016 The MathWorks, Inc.
%#codegen

eml_assert_all_constant(varargin{:});
% This error occurs when using varargout{1:nargout}):
% ??? On the left side of an assignment, an index into a cell array must extract exactly one element.
if nargout == 0
    [errid,errmsg] = coder.const(@feval, ...
        'eml_try_catch',fname,varargin{:});
elseif nargout == 1
    [errid,errmsg,varargout{1}] = coder.const(@feval, ...
        'eml_try_catch',fname,varargin{:});
elseif nargout == 2
    [errid,errmsg,varargout{1},varargout{2}] = coder.const(@feval, ...
        'eml_try_catch',fname,varargin{:});
elseif nargout == 3
    [errid,errmsg,varargout{1},varargout{2},varargout{3}] = coder.const(@feval, ...
        'eml_try_catch',fname,varargin{:});
elseif nargout == 4
    [errid,errmsg,varargout{1},varargout{2},varargout{3},varargout{4}] = coder.const(@feval, ...
        'eml_try_catch',fname,varargin{:});
elseif nargout == 5
    [errid,errmsg,varargout{1},varargout{2},varargout{3},varargout{4},varargout{5}] = coder.const(@feval, ...
        'eml_try_catch',fname,varargin{:});
elseif nargout == 6
    [errid,errmsg,varargout{1},varargout{2},varargout{3},varargout{4},varargout{5},varargout{6}] = coder.const(@feval, ...
        'eml_try_catch',fname,varargin{:});
else
    coder.internal.assert(false,'MATLAB:maxlhs');
end

errid = coder.internal.const(errid);
errmsg = coder.internal.const(errmsg);
eml_lib_assert(isempty(errmsg),errid,errmsg);
