function varargout = actualdesign(this, hspecs, varargin)
%ACTUALDESIGN Design the maximally flat highpass IIR filter

%   Copyright 1999-2017 The MathWorks, Inc.

lpSpecs = copy(hspecs);
lpSpecs.F3dB = 1-hspecs.F3dB;
[b,a] = lpprototypedesign(this, lpSpecs, varargin{:});
[b, a] = transform2lp(b, a, lpSpecs.F3dB, hspecs.F3dB);
[sos, g] = tf2sos(b,a);
varargout = {{sos, g}};

% [EOF]

%-------------------------------------------------
function  [outnum,outden] = transform2lp(orignum,origden,wo,wt)

alpha      = - cos(pi*(wo+wt)/2) / cos(pi*(wo-wt)/2);
ftfnum = [-alpha -1];
ftfden = [1 alpha  ];

if wo==.5 && wt==.5
    ftfnum = [0 -1];
    ftfden = [1 0];
end

if length(ftfnum) == 1 && length(ftfden) == 1 && ftfnum == 1 && ftfden == 1
    [outnum,outden] = eqtflength(orignum,origden);
else
    [outnum, outden] = allpassSub(orignum, origden, ftfnum, ftfden);

    % Force stability
    s = signalpolyutils('isstable',outden);
    if s == 0
        outden = polystab(outden);
    end
end

function [num,den] = allpassSub(b,a,allpassnum,allpassden)

b = b(1:find(b~=0, 1, 'last' )); M = length(b);
a = a(1:find(a~=0, 1, 'last' )); N = length(a);

tempnum = newpoly(b,allpassnum,allpassden,M);
tempden = newpoly(a,allpassnum,allpassden,N);

num = conv(tempnum,polypow(allpassden,N-M));
den = conv(tempden,polypow(allpassden,M-N));

num = num/den(1);
den = den/den(1);
%-------------------------------------------------------------------
function temppoly = newpoly(b,allpassnum,allpassden,M)

for n = 1:M
	temppoly(n,:) = b(n).*conv(polypow(allpassden,M-n),...
		polypow(allpassnum,n-1)); %#ok<AGROW>
end

temppoly = sum(temppoly);

%-------------------------------------------------------------------
function p = polypow(q,N)

p = 1;

if N <= 0
	return
end

for n = 1:N
	p = conv(p,q);
end

