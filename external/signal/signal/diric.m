function y = diric(x,N)
%DIRIC	Dirichlet, or periodic sinc function
%   Y = DIRIC(X,N) returns a matrix the same size as X whose elements
%   are the Dirichlet function of the elements of X.  Positive integer
%   N is the number of equally spaced extrema of the function in the 
%   interval 0 to 2*pi. 
%
%   The Dirichlet function is defined as
%       d(x) = sin(N*x/2)./(N*sin(x/2))   for x not a multiple of 2*pi
%              +1 or -1 for x a multiple of 2*pi. (depending on limit)
% 
%   % Example 1:
%   %   Plot the Dirichlet function over the range 0 to 4, for N = 7 and 
%   %   N = 8. 
%
%   x = linspace(0,4*pi,300);           % Generate linearly spaced vectors
%   subplot(211); plot(x,diric(x,7)); 
%   title('Diric, N = 7'); axis tight;     
%   subplot(212); plot(x,diric(x,8));      
%   title('Diric, N = 8'); axis tight; 
%
%   % Example 2:
%   %   Plot and display the difference in shape of Dirichlet and Sinc 
%   %   functions. 
%
%   x_diric = linspace(0,4*pi,300);     % Generate linearly spaced vectors
%   x_sinc  = linspace(-5,5);           % Generate linearly spaced vectors
%   subplot(211); plot(x_diric,diric(x_diric,7));
%   title('Diric, N = 7'); axis tight;     
%   subplot(212); plot(x_sinc,sinc(x_sinc)); 
%   title('Sinc, Range: -5 to 5 '); axis tight;         

%   Copyright 1988-2020 The MathWorks, Inc.
%#codegen

narginchk(2,2);
% 'x' must be real
validateattributes(x, {'single','double'},{'real'}, ...
    'diric','x',1);
% 'N' must be a real nonempty integer scalar with value >= 1
validateattributes(N, {'numeric'},{'real','nonempty','integer','scalar','>=',1}, ...
    'diric','N',2);
NScalar = double(N(1));

sinX = sin(0.5*x);
tol = eps(class(x))*1e4;

if coder.target('MATLAB')
    y = zeros(size(x),'like',x);
    idx = false(size(x));
    % where x is not divisible by 2*pi
    idx(abs(sinX) > tol) = true;
    y(idx) = sin((NScalar*0.5)*x(idx))./(NScalar*sinX(idx));
    y(~idx) = sign(cos(x(~idx)*((NScalar+1)/2)));
else
    y = coder.nullcopy(x);
    for idx = 1:numel(x)
        if abs(sinX(idx)) > tol
            % where x is not divisible by 2*pi
            y(idx) = sin((NScalar*0.5)*x(idx))./(NScalar*sinX(idx));
        else
            y(idx) = sign(cos(x(idx)*((NScalar+1)*0.5)));
        end
    end
end

end