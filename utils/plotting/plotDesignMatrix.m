function plotDesignMatrix(fullR, options)
    % *plotDesignMatrix*: a helper function that plots the first 2 minutes of the
    % design matrix out for visualisation across all regressors (can be expanded/ non-expanded)
    % Plot the first 30s (downsampled) of the design matrix for speed.
    
    % INPUT:
    % - *fullR*: the design matrix in *table* or *matrix* format
    % for visualisation
    % - *options*: the options struct that was defined at the beginning of the
    % analysis in storing all configuration information
    
    % OUTPUT:
    % A heat map/ diagramme that shows the design matrix and
    % relative value for each data point in respective to other
    % data points

downFactor = 5; % keep every 5th sample

% Convert table to matrix if needed
if istable(fullR)
    fullR = table2array(fullR);
end

% Extract first 30s
numSamples = round(30 * options.sRate);
if size(fullR, 1) < numSamples
    warning('Design matrix shorter than 30s; plotting available data only.');
    dataToPlot = fullR;
else
    dataToPlot = fullR(1:numSamples, :);
end

% Downsample
dataToPlot = dataToPlot(1:downFactor:end, :);

% Detect sparsity and plot accordingly
if issparse(dataToPlot)
    figure;
    spy(dataToPlot);
    xlabel('Regressors');
    ylabel('Samples (first 30s, downsampled)');
    title('Sparse Design Matrix Pattern');
else
    figure;
    clims = [min(dataToPlot(:)), max(dataToPlot(:))];
    imagesc(dataToPlot, clims);
    colormap(parula);
    colorbar;
    xlabel('Regressors');
    ylabel('Samples (first 30s, downsampled)');
    title('Design Matrix Visualisation');
end
end