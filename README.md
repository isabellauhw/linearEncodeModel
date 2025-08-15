# Linear Encode Model Toolbox

A MATLAB toolbox for linear encoding of video, neural, and behavioural data. This toolbox is designed to organise and analyse experimental datasets using a modular pipeline.

## Folder Structure
- **data/** – Contains behavioural, neural, and video data files. Users should supply their datasets in the correct format.  
- **examples/** – Demo scripts to show how to preprocess and structure data.  
- **main/** – Main configuration scripts. Run these after preparing your data objects.  
- **utils/** – Helper functions and main functions required by the pipeline.  
- **vidDeconv_options.m** – Defines paths, variable names, types, and parameters needed for your linear encode model.  

## Getting Started

### Set options

Before running any analysis, configure paths and parameters using:
```
options = vidDeconv_options;
```
This will generate an options struct with all folder pathways and model-specific parameters.

Prepare your data
In the `examples/` folder, run:

```
vidDeconv_extractFacemapData;    % Organise video/facial features
vidDeconv_defineRegressorData;   % Organise neural and behavioral data
```
These scripts compile your data into an obj struct containing:

*obj.neural* – neural data table
*obj.bhv – behavioral data table
obj.vid – video data table

*Note*: Users should modify these scripts to fit their dataset formats.

Run main analysis
Go to the `main/` folder and run:
```
loop_run_vidDeconv;
```
Currently, this script runs in a loop over datasets. In the future, the `loop_run_vidDeconv.m` file can be simplified to only include the procedures to run.

### Usage Example
```
% Load options
options = vidDeconv_options; % Make sure you change the configuration beforehand

% Prepare demo data
vidDeconv_extractFacemapData;
vidDeconv_defineRegressorData;

% Run main pipeline
loop_run_vidDeconv;
```

## Pipeline — Step-by-Step

This section describes the chronological execution flow of the `loop_run_vidDeconv` pipeline.
Each step includes:

*Purpose* – Why this step exists
*Inputs* – What’s needed and in what format
*Outputs* – What’s returned and how it’s used later

### 1. Setup Session Model — `setupLinearEncodeModel`

*Purpose*:
Initialise a linearEncodeModel object for the given mouse and session. Loads behaviour, neural, and optional video data; aligns them to a global time axis.

*Inputs*:

- `mouseName` (string) – e.g., "AMK035"
- `expRef` (string) – e.g., "2023-06-13_1"
- `motionData` (table) – motion PCs + calibrated event times aligned to neural/behavioural data
- `options` (struct) – pipeline configuration

*Outputs*:
- `obj` (linearEncodeModel instance) – contains all loaded/processed data for downstream functions

### 2. Build Event Regressors — `buildEventRegressors`

*Purpose*:
Compile behavioural event regressors into a non-time-shifted design matrix.

*Inputs*:

- `obj` – from step 1
- `options` – configuration

*Outputs*:
- `obj` – updated with behavioural regressors in structured subfields

### 3. Build Video Regressors — `buildContinuousRegressors`
*Purpose*:
Extract and organise continuous video PCs into a non-time-shifted design matrix.

*Inputs*:
- `obj` – from step 2
- `options` – configuration

*Outputs*:
- `obj` – updated with video PC regressors, each labelled separately (MotionPC1, MotionPC2, …)

### 4. Build Trial Regressors — `buildTrialRegressors`
*Purpose*:
Create trial-based regressors (e.g., previous choice, difficulty) and insert them into a non-time-shifted design matrix.

*Inputs*:
- `obj` – from step 3
- `options` – configuration

*Outputs*:
- `obj` – updated with trial regressors

### 5. Get Event Design Matrix — `getEventDesignMatrix`
*Purpose*:
Extract only event-related regressors into a separate table for later expansion.

*Inputs*:
- `obj` – from step 4
- `options` – configuration

*Outputs*:
- `R` (table) – non-time-shifted event regressors

### 6. Create Time-Lagged (for events) or non-Time-Lagged (optional, video or trial) Design Matrices
*Purpose*:
Expand regressors over time to capture temporal dynamics.

*Functions & Outputs*:
- `createTaskDesignMatrix` → taskMat, taskLabels, taskIdx (event regressors, time-lagged)
- `createVideoDesignMatrix` → vidMat, vidLabels, vidIdx (video regressors)
- `createTrialDesignMatrix` → trialMat, trialLabels, trialIdx (trial regressors)

### 7. Visualise Design Matrices — `plotDesignMatrix`
*Purpose*:
Plot the first portion of each design matrix for inspection.

*Inputs*:
- Design matrix (expanded or non-expanded)
- `options`

*Outputs*:
- Heatmap visualisations

### 8. Filter Rows Outside Trials — `removeRowsOutsideTrialWindows`
*Purpose*:
Remove non-task time points (zero rows) and keep only data within trial windows.

*Inputs*:
- `obj` – behavioural data with trial timing
- Reference matrix (to detect zero rows within the matrix) 
- Other matrices to filter

*Outputs*:
- `cleanedMats` – filtered matrices (task, video, trial, neural signals)
- `trialVec` – trial number for each frame

### 9. Normalise & Re-centre — `normaliseAndRecentre`
*Purpose*:
Scale predictors and outputs to avoid computational issues.

*Inputs*:
- `X` – combined regressor matrix
- `Y` – neural signal matrix

*Outputs*:
- Normalised X, Y

### 10. Check & Orthogonalise — `checkAndOrthogonalise`
*Purpose*:
Detect and fix high correlations or linear dependencies between regressor groups.

*Inputs*:
- Expanded design matrix
- Labels & indices for task, video, trial regressors
- Correlation threshold (default: 0.95)

*Outputs*:
- Orthogonalised design matrix (`expandR`)
- Updated regressor index mapping (`regIdx`)

### 11. Ridge Regression — `ridgeMML`
*Purpose*:
Fit a ridge regression model using Marginal Maximum Likelihood (Karabatsos, 2017) to estimate optimal λ.

*Inputs*:
- `X` – expanded design matrix
- `Y` – neural data
- `Optional`: initial λ, verbosity, timeout, otherwise `[]`

*Outputs*:
- Optimal λ for each output
- Beta weights per regressor

### 12. Cross-Validated Model — `crossValModel`
*Purpose*:
Evaluate predictive performance (R²) using trial-based cross-validation.

*Inputs*:
- `X` – expanded design matrix
- `Y` – neural data
- `regLabels`, `regIdx` – grouping information
- `folds` – number of CV folds
- `trialVec` – trial labels (from `removeRowsOutsideTrialWindows`)

*Outputs*:
- Predicted fluorescence
- Beta weights per fold
- Reduced design matrices for selected regressors

## License
This toolbox was developed in the LakLab (Department of Physiology, Anatomy, and Genetics [DPAG], University of Oxford, UK). 

It is available for **academic and research purposes only**. If you use this toolbox in your work, please acknowledge the LakLab in any resulting publications or presentations.  

