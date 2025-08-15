function w = boxcar(varargin)
%MATLAB Code Generation Library Function

% Copyright 2008-2010 The MathWorks, Inc.
%#codegen    
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(varargin{:});

[errid,errmsg,w] = eml_try_catch('boxcar',varargin{:});
errid = coder.internal.const(errid);
errmsg = coder.internal.const(errmsg);
w = coder.internal.const(w);
eml_lib_assert(isempty(errmsg),errid,errmsg);
