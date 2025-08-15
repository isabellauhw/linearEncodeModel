function [h,err,res] = firpm(varargin)
%MATLAB Code Generation Library Function

% Copyright 2008-2010 The MathWorks, Inc.
%#codegen    
myfun = 'firpm';
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(varargin{:});
[errid,errmsg,h,err,res] = eml_try_catch(myfun,varargin{:});
errid = coder.internal.const(errid);
errmsg = coder.internal.const(errmsg);
h = coder.internal.const(h);
err = coder.internal.const(err);
res = coder.internal.const(res);
eml_lib_assert(isempty(errmsg),errid,errmsg);
