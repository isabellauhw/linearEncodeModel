function [B,A] = yulewalk(varargin)
%MATLAB Code Generation Library Function

% Copyright 2008-2010 The MathWorks, Inc.
%#codegen    
myfun = 'yulewalk';
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(varargin{:});
[errid,errmsg,B,A] = eml_try_catch(myfun,varargin{:});
errid = coder.internal.const(errid);
errmsg = coder.internal.const(errmsg);
B = coder.internal.const(B);
A = coder.internal.const(A);
eml_lib_assert(isempty(errmsg),errid,errmsg);
