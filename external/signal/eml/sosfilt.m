function y = sosfilt(SOS,x)
%MATLAB Code Generation Library Function

%    Copyright 2002-2010 The MathWorks, Inc.
%#codegen

eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(isfloat(SOS), ...
    ['Function ''sosfilt'' is not defined for values of class ''' class(SOS) '''.']);
eml_lib_assert(size(SOS,2) == 6, ...
    'signal:sosfilt:InvalidDimensions', ...
    'Size of SOS matrix must be Mx6.');
ZERO = eml_scalar_eg(x,SOS);
y = coder.nullcopy(eml_expand(ZERO,size(x)));
if isempty(x)
    return
end
if isvector(x) && size(x,2) > 1
    % Special logic for row vectors.
    numSamps = size(x,2);
    numChans = 1;
else
    numSamps = size(x,1);
    numChans = eml_rdivide(eml_numel(x),numSamps); % Support N-D input.
end
numSections = size(SOS,1);
for i = 1:numSections
    sosi4 = SOS(i,4);
    if sosi4 ~= 1
        SOS(i,1) = rdivide(SOS(i,1),sosi4);
        SOS(i,2) = rdivide(SOS(i,2),sosi4);
        SOS(i,3) = rdivide(SOS(i,3),sosi4);
        SOS(i,5) = rdivide(SOS(i,5),sosi4);
        SOS(i,6) = rdivide(SOS(i,6),sosi4);
    end
end
ixy = ones(eml_index_class);
tin  = ZERO;
tout = ZERO;
for ichan = 1:numChans
    z = eml_expand(ZERO,[numSections*2,1]);
    for isamp = 1:numSamps
        iz = ones(eml_index_class);
        tin(1) = x(ixy);
        for isect = 1:numSections
            tout(1) = z(iz) + tin*SOS(isect,1);
            izp1 = eml_index_plus(iz,1);
            z(iz) = z(izp1) + tin*SOS(isect,2) - tout*SOS(isect,5);
            z(izp1) = tin*SOS(isect,3) - tout*SOS(isect,6);
            iz = eml_index_plus(izp1,1);
            tin = tout;
        end
        y(ixy) = tout;
        ixy = eml_index_plus(ixy,1);
    end
end
