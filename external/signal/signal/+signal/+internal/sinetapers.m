function tapers = sinetapers(N,M,prec)
% SINETAPERS   returns sine taper values.
%  N is the length of tapers(must be same as length of signal)
%  M is the number of tapers
%  prec is the precision of taper value
%  tapers = sinetapers(N,M,prec);
% This function is for internal use only.

%#codegen
Np = cast(N,prec);
Mp = cast(M,prec);
%tapers1 = zeros(Np,Mp,prec);
t = linspace(1,Np,Np);
k = linspace(1,Mp,Mp);
tapers = sqrt((2/(Np+1)))* sin(t'*k*(pi/(Np+1)));