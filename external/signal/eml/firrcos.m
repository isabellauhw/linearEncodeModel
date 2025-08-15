function [b,a]=firrcos(varargin)
%MATLAB Code Generation Library Function

% Copyright 2008-2010 The MathWorks, Inc.
%#codegen    
myfun = 'firrcos';
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(varargin{:});
[errid,errmsg,b,a] = eml_try_catch(myfun,varargin{:});
errid = coder.internal.const(errid);
errmsg = coder.internal.const(errmsg);
b = coder.internal.const(b);
a = coder.internal.const(a);
eml_lib_assert(isempty(errmsg),errid,errmsg);
