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
vidDeconv_config;
```
Currently, this script runs in a loop over datasets. In the future, the `vidDeconv_config.m` file can be simplified to only include the procedures to run.

### Usage Example
```
% Load options
options = vidDeconv_options; % Make sure you change the configuration beforehand

% Prepare demo data
vidDeconv_extractFacemapData;
vidDeconv_defineRegressorData;

% Run main pipeline
vidDeconv_config;
```

## License
This toolbox was developed in the LakLab (Department of Physiology, Anatomy, and Genetics [DPAG], University of Oxford, UK). 

It is available for **academic and research purposes only**. If you use this toolbox in your work, please acknowledge the LakLab in any resulting publications or presentations.  
