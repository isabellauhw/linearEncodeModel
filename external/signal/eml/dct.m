function y = dct(x_in,n)
%MATLAB Code Generation Library Function

% Limitations for Y = DCT(X) and Y = DCT(X,N)
%   Input X must not vary its size or complexity at a given call site.
%   The length of the transform dimension must be a power of two.  The
%   transform dimension is length(X) if X is a vector, size(X,1) if X is a
%   matrix.  Empty X is not supported.
%
% Further limitations for Y = DCT(X,N)
%   N must be const and a power of 2.

% Copyright 2009-2014 The MathWorks, Inc.
%#codegen

%% This function requires DSP System Toolbox
coder.extrinsic('license', 'exist');
x = license('test','Signal_Blocks');
x = coder.internal.const(x);
coder.internal.errorIf(~x,'signal:isspblksinstalled:noDSP1','dct');   

x = exist('dsp.DCT','class');
x = coder.internal.const(x);
coder.internal.errorIf(~x,'signal:isspblksinstalled:noDSP1','dct');   

%% Input validation
myfun = 'dct';
coder.extrinsic('sigprivate');
eml_lib_assert(nargin>=1, 'signal:dct:notEnoughInputs', 'Not enough input arguments.');
eml_lib_assert(nargin<=2, 'signal:dct:tooManyInputs',   'Too many input arguments.');

% The transform dimension is based on the first nonsingleton dimension of the
% input X.  If X is a matrix and N==1, thus cutting the input down to the row
% vector X(1,:), then the transform dimension is still along columns.
transform_dimension = eml_nonsingleton_dim(x_in);

if nargin>1
    % dct(x,n) pads or truncates x to length n before transforming.
    eml_lib_assert(eml_is_const(n),...
                       'signal:dct:nNotConst',...
                       'The pad or truncation value N must be constant.');
    [errid,errmsg] = sigprivate('dct_validate_inputs', ...
                                 myfun, ...
                                 size(x_in), class(x_in), isreal(x_in),...
                                 n);
    errid = coder.internal.const(errid);
    errmsg = coder.internal.const(errmsg);
    eml_lib_assert(isempty(errmsg),errid,errmsg);
    x = eml_pad_or_truncate_matrix(x_in, n);
else
    % dct(x)
    [errid,errmsg] = sigprivate('dct_validate_inputs', ...
                                 myfun, ...
                                 size(x_in), class(x_in), isreal(x_in));
    errid = coder.internal.const(errid);
    errmsg = coder.internal.const(errmsg);
    eml_lib_assert(isempty(errmsg),errid,errmsg);
    x = x_in;
end

if isempty(x)
    y = [];
elseif size(x,transform_dimension)==1
    % The input along the transform dimension is scalar, so no computation happens.
    y = x;
else
    % Create the output the same size and complexity as X.
    y = coder.nullcopy(x);
    if transform_dimension == 2
        % The input is a row vector, but the DCT System object only works
        % down columns.  Copy the input to a column vector. 
        x_by_columns = x(:);
    else
        % The input is already oriented to work down columns.
        x_by_columns = x;
    end
    % Invoke the System object.
    s = dsp.DCT('SineComputation','Trigonometric function');
    % Overwriting Y(:) will retain it's size and complexity.
    y(:) = step(s,x_by_columns);
end
