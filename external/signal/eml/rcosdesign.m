function b = rcosdesign(varargin)
%MATLAB Coder Library Function

% Copyright 2013 The MathWorks, Inc.
%#codegen    
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(varargin{:});

[errid,errmsg,b] = eml_try_catch('rcosdesign',varargin{:});
errid = coder.internal.const(errid);
errmsg = coder.internal.const(errmsg);
b = coder.internal.const(b);
eml_lib_assert(isempty(errmsg),errid,errmsg);

