function h = realizemdltarget
%REALIZEMDLTARGET Constructor of the realizemdltarget class.

%   Copyright 1995-2010 The MathWorks, Inc.

h = dspfwiztargets.realizemdltarget;
h.blockname = 'Filter';
h.OptimizeZeros = 'on';
h.OptimizeOnes = 'on';
h.OptimizeNegOnes = 'on';
h.OptimizeDelayChains = 'on';

