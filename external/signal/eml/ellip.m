function [varargout] = ellip(varargin)
%MATLAB Code Generation Library Function

% Copyright 2008-2010 The MathWorks, Inc.
%#codegen    
myfun = 'ellip';
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(varargin{:});
switch nargout
  case {0,1,2}
    % [B,A]
    [errid,errmsg,b,a] = eml_try_catch(myfun,varargin{:});
    errid = coder.internal.const(errid);
    errmsg = coder.internal.const(errmsg);
    b = coder.internal.const(b);
    a = coder.internal.const(a);
    eml_lib_assert(isempty(errmsg),errid,errmsg);
    varargout{1} = b;
    varargout{2} = a;
  case 3
    % [Z,P,K]
    [errid,errmsg,z,p,k] = eml_try_catch(myfun,varargin{:});
    errid = coder.internal.const(errid);
    errmsg = coder.internal.const(errmsg);
    z = coder.internal.const(z);
    p = coder.internal.const(p);
    k = coder.internal.const(k);
    eml_lib_assert(isempty(errmsg),errid,errmsg);
    varargout{1} = z;
    varargout{2} = p;
    varargout{3} = k;
  case 4
    % [A,B,C,D]
    [errid,errmsg,A,B,C,D] = eml_try_catch(myfun,varargin{:});
    errid = coder.internal.const(errid);
    errmsg = coder.internal.const(errmsg);
    A = coder.internal.const(A);
    B = coder.internal.const(B);
    C = coder.internal.const(C);
    D = coder.internal.const(D);
    eml_lib_assert(isempty(errmsg),errid,errmsg);
    varargout{1} = A;
    varargout{2} = B;
    varargout{3} = C;
    varargout{4} = D;
  otherwise
    eml_lib_assert(0,'MATLAB:nargoutchk:tooManyOutputs',...
                   'Too many output arguments.');
end
