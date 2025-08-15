# Linear Encode Model Toolbox

A MATLAB toolbox for linear encoding of video, neural, and behavioral data. This toolbox is designed to organize and analyze experimental datasets using a modular pipeline.

## Folder Structure

linearEncodeModel/
├── data/ # CSVs and video data (user-provided)
├── examples/ # Demo scripts for running the pipeline
├── main/ # Master configuration and script files
├── utils/ # Functions used by config and main scripts
├── vidDeconv_options.m # Sets folder paths and model parameters

kotlin
Copy
Edit

- **data/** – Contains behavioral, neural, and video data files. Users should supply their own datasets in the correct format.  
- **examples/** – Demo scripts to show how to preprocess and structure data.  
- **main/** – Main configuration scripts. Run these after preparing your data objects.  
- **utils/** – Helper functions and main functions required by the pipeline.  
- **vidDeconv_options.m** – Defines paths, variable names, types, and parameters needed for your linear encode model.  

## Getting Started

### Set options

Before running any analysis, configure paths and parameters using:

options = vidDeconv_options;
This will generate an options struct with all folder pathways and model-specific parameters.

Prepare your data
In the examples/ folder, run:

matlab
Copy
Edit
vidDeconv_extractFacemapData;    % Organize video/facial features
vidDeconv_defineRegressorData;   % Organize neural and behavioral data
These scripts compile your data into an obj struct containing:

obj.neural – neural data table
obj.bhv – behavioral data table
obj.vid – video data table

Note: Users should modify these scripts to fit their own dataset formats.

Run main analysis
Go to the main/ folder and run:
vidDeconv_config;
Currently, this script runs in a loop over datasets. In the future, the vidDeconv_config.m file can be simplified to only include the procedures to run.

Usage Example
% Load options
options = vidDeconv_options;

% Prepare demo data
vidDeconv_extractFacemapData;
vidDeconv_defineRegressorData;

% Run main pipeline
vidDeconv_config;
Contributing
Fork the repository

Create a new branch for your changes

Submit a pull request with a clear description of your modifications

License
This toolbox was developed in the LakLab (Department of Physiology, Anatomy, and Genetics [DPAG], University of Oxford, UK). 

It is available for **academic and research purposes only**. If you use this toolbox in your work, please acknowledge the LakLab in any resulting publications or presentations.  
