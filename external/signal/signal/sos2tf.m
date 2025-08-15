function [b,a] = sos2tf(sos,g)
%SOS2TF 2nd-order sections to transfer function model conversion.
%   [B,A] = SOS2TF(SOS,G) returns the numerator and denominator
%   coefficients B and A of the discrete-time linear system given
%   by the gain G and the matrix SOS in second-order sections form.
%
%   SOS is an L by 6 matrix which contains the coefficients of each
%   second-order section in its rows:
%       SOS = [ b01 b11 b21  1 a11 a21
%               b02 b12 b22  1 a12 a22
%               ...
%               b0L b1L b2L  1 a1L a2L ]
%   The system transfer function is the product of the second-order
%   transfer functions of the sections times the gain G. If G is not
%   specified, it defaults to 1. Each row of the SOS matrix describes
%   a 2nd order transfer function as
%       b0k +  b1k z^-1 +  b2k  z^-2
%       ----------------------------
%       1 +  a1k z^-1 +  a2k  z^-2
%   where k is the row index.
%
%   % Example:
%   %   Compute the transfer function representation of a simple second-
%   %   -order section system.
%
%   sos = [1  1  1  1  0 -1; -2  3  1  1 10  1];
%   [b,a] = sos2tf(sos)
%
%   See also ZP2SOS, SOS2ZP, SOS2SS, SS2SOS

%   Copyright 1988-2017 The MathWorks, Inc.

%#codegen

narginchk(1,2)

% Input check
if nargin == 1
    g = 1;
end

if coder.target('MATLAB')
    % MATLAB
    [b,a] = esos2tf(sos,g);
else
    allConst = coder.internal.isConst(sos) && coder.internal.isConst(g);
    
    if allConst && coder.internal.isCompiled
        % Constant Inputs
        [b,a] = coder.const(@feval,'sos2tf',sos,g);
    else
        % Variable Inputs
        [b,a] = esos2tf(sos,g);
    end
end
end


function [b,a] = esos2tf(sos,g)

% Validate input attributes
validateattributes(sos,{'numeric'},{'2d','finite'},'sos2tf');
validateattributes(g,{'numeric'},{'2d','finite'},'sos2tf');

% Cast to enforce Precision Rules
% Single/double datatype check
if isa(sos,'single') || isa(g,'single')
    flscls = 'single';
else
    flscls = 'double';
end

sos = cast(sos,flscls);
g = cast(g,flscls);


[L,n] = size(sos);
coder.internal.errorIf(n ~= 6,'signal:sos2tf:InvalidDimensionsSOS');

% Declaring variables with variable size
coder.varsize('b2','a2');

if L == 0
    b = cast([],flscls);
    a = cast([],flscls);
    return
else
    
    % Complex datatype check
    if(~isreal(g) || ~isreal(sos))
        b2 = complex(sos(1,1:3));
        a2 = complex(sos(1,4:6));
    else
        b2 = sos(1,1:3);
        a2 = sos(1,4:6);
    end
    
    % Obtain the num and den coefficients through convolution
    for m=2:L
        b1 = sos(m,1:3);
        a1 = sos(m,4:6);
        b2 = conv(b2,b1);
        a2 = conv(a2,a1);
    end
    
    % Multiply by gain
    b2 = b2.*prod(g(:));
    
    if length(b2) > 3
        if b2(end) == 0
            b2 = b2(1:end-1); % Remove trailing zeros if any for order > 2
        end
    end
    if length(a2) > 3
        if a2(end) == 0
            a2 = a2(1:end-1); % Remove trailing zeros if any for order > 2
        end
    end
    b = b2;
    a = a2;    
end
end
