function [P, z] = analyzeOctaveBank(u, designedFilter, z)
%analyzeOctaveBank Filter input time-domain signal with octave banks
%   analyzeOctaveBank performs filtering of the time-domain input with the
%   coefficients of octave or fractional octave filter-banks. It returns
%   the average power over octave bands. The input parameters are:
%   u      -         Data
%   designedFilter - A cell array comprising the filter banks. When an
%                    entry is a numeric matrix, it
%                    represents an sos filter. When it is a cell array
%                    consisting of two matrices, it designed as a
%                    multi-section fourth order filter.
%
%   The output parameters are:
%   P   - Average power in octave bands
%   z   - Filter states

%   Copyright 2017 MathWorks, Inc.

%   This function is for internal use only. It may be removed.

narginchk(2,3);
nargoutchk(1,2);

[nSamples, nChannels] = size(u);
nBands = size(designedFilter,2);

P = zeros(nBands,nChannels);

% Loop over each parallel band
for bandIdx = 1:nBands
    in = u;
    if ~iscell(designedFilter{1,bandIdx})
        in = sosfilt(designedFilter{1,bandIdx},u);
    else
        sectionFilter = designedFilter{1,bandIdx};
        num = sectionFilter{1};
        den = sectionFilter{2};
        nSections = size(num,1);
        zLength = size(num,2)-1;
        if nargin < 3
            z = zeros(zLength,nChannels,nSections,nBands);
        end
        z_band = z(:,:,:,bandIdx);
        % Loop over each fourth order section
        for secIdx = 1:nSections
            [in,z_band(:,:,secIdx)] = filter(num(secIdx,:),den(secIdx,:),in,z_band(:,:,secIdx),1);
        end
    end
    % Average power
    P(bandIdx,:) = sum(abs(in.^2))/nSamples + eps(0);
end

