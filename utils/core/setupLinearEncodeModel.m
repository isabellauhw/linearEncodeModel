function obj = setupLinearEncodeModel(obj, mouseName, expRef, options)
    % CONSTRUCTOR CLASS: a function that helps to initalise an instance
    % of a new object (for here, this is the the respective mouse name [mouseName],
    % experimental session reference [expRef], and the motion data + experimental 
    % time in global time scale [motionData]. This function first
    % define file and data paths, load behavioural and neural
    % data for the session, define global time axis (according to the task data), 
    % interpolate neural data and video PCs data with the respective time 
    % frames in the global time axis 

    % INPUT:
    % - *mouseName*: the name of the animal in *string* format (e.g., 'AMK035')
    % - *expRef*: the experiment session reference in *string* format (e.g., '2023-06-13_1')
    % - *motionData*: the data table that contains two variables in *table*
    % format: 1) the motion PCs that was extracted from facemap, and 2)
    % the callibrated event times in aligned global timeline (e.g., in sync 
    % with the neural and behavioural data)that was extracted (e.g., motionData)
    
    % OUTPUT:
    % - *obj* (could be of any name your have defined in your procedural
    % script): a class instance that contains 1) data table, or 2) empty regressor container
    % for all the necessary information for calling subsequent functions in *object* 
    % format (e.g., mouse name, data roots, behavioural and neural data tables)

% --- Basic Metadata Setup ---
obj.mouseName = mouseName;
obj.expRef = expRef;
obj.sRate = options.sRate;
obj.preTime = options.preTime;
obj.postTime = options.postTime;

% --- Store Variable Definitions ---
obj.variableDefs = options.variableDefs;

% --- Trial count information ---
obj.bhvTrialCnt = height(obj.bhv);

% --- Global Time Axis ---
obj.globalStartTime = min(obj.bhv.stimulusOnsetTime) - 5;
obj.globalEndTime   = max(obj.bhv.outcomeTime) + 5;
obj.globalTime      = obj.globalStartTime : 1/obj.sRate : obj.globalEndTime;
nT = numel(obj.globalTime);

% --- Neural Interpolation ---
neuralTime = obj.neural.Timestamp;
obj.neuralInterpolated = struct();  % holds any interpolated fluor signal
neuralVars = obj.variableDefs.neural.timeRef;     % e.g., {'LeftDLS_DA', 'RightDLS_ACH'}

for i = 1:numel(neuralVars)
    var = neuralVars{i};
    obj.(var) = interp1(neuralTime, obj.neural.(var), obj.globalTime, 'linear', 'extrap');
end

% --- Continuous Data Interpolation ---
% Video PCs
obj = interpolateContinuous(obj, obj.variableDefs.vid, 'vid', nT);

% Keypoints
obj = interpolateContinuous(obj, obj.variableDefs.keypoint, 'vid', nT);

end

