function build(this)
%BUILD Sync the gui and the parameter and build the model

%   Copyright 1995-2017 The MathWorks, Inc.

str  = getString(message('signal:sigtools:siggui:RealizingModel'));

% Send the message that realization has begun
sendstatus(this,str);

switch this.InputProcessing
  case 'Columns as channels (frame based)'
    inputProcessing = 'columnsaschannels';
  case 'Elements as channels (sample based)'
    inputProcessing = 'elementsaschannels';
  case 'Inherited (this choice will be removed - see release notes)'
    inputProcessing = 'inherited';
end

switch this.RateOptions
  case 'Enforce single-rate processing'
    rateOption = 'enforcesinglerate';
  case 'Allow multirate processing'
    rateOption = 'allowmultirate';
end

if strcmpi(this.UseBasicElements, 'On')

    fcn = 'realizemdl';

    % Get the values from the GUI and remove those that the parameter object
    % does not care about.
    s = getstate(this);
    s = rmfield(s, {'Version', 'Tag', 'Filter', 'UseBasicElements', ...
      'OptimizeScaleValues', 'InputProcessing', 'RateOptions'});

    if strcmpi(this.Destination, 'user defined')
        s.Destination = s.UserDefined;
    end
    s = rmfield(s, 'UserDefined');

    % Sync the parameter with the GUI
    p = fieldnames(s);
    v = struct2cell(s);

    inputs = [p v]';  
    inputs = [inputs {'InputProcessing';inputProcessing}];
    if ismultirate(this.Filter) 
      inputs = [inputs {'RateOption';rateOption}];    
    end
else
    
    if strcmpi(this.Destination, 'user defined')
        destination = this.UserDefined;
    else
        destination = this.Destination;
    end
        
    fcn = 'block';
                  
    inputs = {'Destination', destination, 'BlockName', this.BlockName, ...
        'OverwriteBlock', this.OverWrite,'InputProcessing',inputProcessing};
      
    if ismultirate(this.Filter) 
      inputs = [inputs,{'RateOption', rateOption}];
    end
end

sendstatus(this,sprintf('%s ...', str));

if isa(this.Filter, 'dfilt.abstractsos')
    oldOptim = this.Filter.OptimizeScaleValues;
    this.Filter.OptimizeScaleValues = strcmp(this.OptimizeScaleValues, 'on');
end

capturewarnings(fcn, this.Filter, inputs{:});

if isa(this.Filter, 'dfilt.abstractsos')
    this.Filter.OptimizeScaleValues = oldOptim;
end

% Send the message that realization is complete
sendstatus(this,sprintf('%s ... %s', str, ...
                        getString(message('signal:sigtools:siggui:Done'))));

% [EOF]
