function c = chi2conf(conf,k)
%#codegen
%CHI2CONF Confidence interval using inverse of chi-square cdf
%   This is a helper function for Spectrum objects

%   C = CHI2CONF(CONF,K) calculates confidence interval C based on
%   confidence level CONF and K independent measurements.  C is a two
%   element vector.  
%
%   Reference:
%     Stephen Kay, "Modern Spectral Estimation, Theory & Application," 
%     Prentice Hall, 1988, pp 76, eqn 4.16. 

%   Copyright 1998-2018 The MathWorks, Inc.

narginchk(2,2);

% Ensure double precision arithmetic
conf = double(conf);
k=double(k);

v=2*k;
alfa = 1 - conf;
c=chi2inv([1-alfa/2 alfa/2],v);
c=v./c;

end

%--------------------------------------------------------------------------

function x = chi2inv(p,v)
%CHI2INV Inverse of the chi-square cumulative distribution function (cdf).
%   X = CHI2INV(P,V)  returns the inverse of the chi-square cdf with V
%   degrees of freedom at the values in P. The chi-square cdf with V
%   degrees of freedom, is the gamma cdf with parameters V/2 and 2.
%
%   The size of X is the common size of P and V. A scalar input
%   functions as a constant matrix of the same size as the other input.

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.4.
%      [2] E. Kreyszig, "Introductory Mathematical Statistics",
%      John Wiley, 1970, section 10.2 (page 144)

x=zeros(size(p),'like',p);
NAN = coder.internal.nan('like',p);
for i=1:numel(p)
    if (v > 0 && round(v) == v)
        % Call the gamma inverse function.
        x(i) = gaminv(p(i),v/2,2);
        
        % Return NaN if the degrees of freedom is not a positive integer.
    else
        x(i) = NAN;
    end
end
end


%--------------------------------------------------------------------------
function x = gaminv(pk,ak,bk)
%GAMINV Inverse of the gamma cumulative distribution function (cdf).
%   X = GAMINV(P,A,B)  returns the inverse of the gamma cdf with  
%   parameters A and B, at the probabilities in P.
%
%   The size of X is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 6.5.

%   B.A. Jones 1-12-93
%   Was: Revision: 1.2, Date: 1996/07/25 16:23:36

if 0 <= ak && ~isinf(ak) && 0 < bk && pk >= 0 && pk <= 1
    if pk > 0 && pk < 1 && ak > 0
        qk = real(gammaincinv(pk,ak));
        x = qk*bk;

    else
        if ak == 0 || pk == 0
            x = 0;
        elseif pk == 1
            x = inf;
        else
            x = nan;
        end

    end
else
    x = nan;
end
end