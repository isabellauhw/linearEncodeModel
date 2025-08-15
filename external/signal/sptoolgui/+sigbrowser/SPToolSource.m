classdef SPToolSource < matlabshared.scopes.source.StaticSource
    %SPToolSource   Define the SPToolSource class.
    
    %   Copyright 2013 The MathWorks, Inc.
    
    properties
        
        Signals;
        SnapShotMode = false; 
        
    end
    
    methods
        
        function obj = SPToolSource(varargin)
            %SPToolSource   Construct the SPToolSource class.
            obj@matlabshared.scopes.source.StaticSource(varargin{:});
        end
        
        function addData(this, name, sampleRate, data)
            %ADDDATA add data to the existing source
            %
            % name       is a string containing the name of the signal
            % sampleRate is the sample rate for the data
            % data       a 2D matrix containing real/complex samples along the columns
            
            if isempty(this.Signals)
                % if no signals are present, just assign to Signals
                this.Signals = struct( ...
                    'Name',name, ...
                    'Data',data, ...
                    'Rate',sampleRate);
            else
                % otherwise, add to the end of the existing list
                n = numel(this.Signals);
                this.Signals(n+1) = struct( ...
                    'Name',name, ...
                    'Data',data, ...
                    'Rate',sampleRate);
            end
        end
        
        function clearData(this, inputIndex)
            %CLEARDATA clears all data from the source
            %
            %   If inputIndex is specified, clear the corresponding signal
            %   and re-install the data source for immediate viewing
            
            if nargin == 1
                this.Signals = [];
            else
                this.Signals(inputIndex) = [];
                installDataSource(this.Application, this);
            end
        end
        
        function enableData(this)
            %ENABLEDATA
            
            updateDisplay(this);
        end
        
        function data = getData(this, ~, ~, inputIndex)
            %GETDATA  Get the data.
            %   We return all data as we will only have one timestamp.
            
            if nargin < 4
                n = numel(this.Signals);
                inputIndex = 1:n;
            else
                n = 1;
            end
            data = repmat(struct('values',[],'time',0),1,n);
            for i = 1:numel(inputIndex)
                data(i).values     = this.Signals(inputIndex(i)).Data.';
                data(i).time       = (0:(size(this.Signals(inputIndex(i)).Data,1)-1)) ./ this.Signals(inputIndex(i)).Rate;
            end
        end
        
        function dataTypes = getDataTypes(this, inputIndex)
            %GETDATATYPES Get the dataTypes for the inputs.
            
            if nargin < 2
                dataTypes = cell(numel(this.Signals),1);
                for i=1:numel(dataTypes)
                    dataTypes{i} = class(this.Signals(i).Data);
                end
            else
                dataTypes = class(this.Signals(inputIndex).Data);
            end
        end
        
        function endTime = getEndTime(this)
            %GETENDTIME Get the last sample instant of all signals present
            
            endTime = 0;
            
            for i=1:numel(this.Signals)
                endTime = max(size(this.Signals(i).Data,1) ./ this.Signals(i).Rate, endTime);
            end
            
            if isequal(endTime,0)
                % safeguard against empty/null signals
                % TimeDomainVisual uses 10 sec. as a default
                endTime = 10;
            end
        end
        
        function inputNames = getInputNames(this, inputIndex)
            %GETINPUTNAMES Get the inputNames.
            
            if nargin > 1
                inputNames = this.Signals(inputIndex).Name;
            else
                inputNames = {this.Signals.Name};
            end
        end
        
        function maxDimensions = getMaxDimensions(this, inputIndex)
            %GETMAXDIMENSIONS Get the maxDimensions.
            
            if nargin == 1
                maxDimensions = zeros(numel(this.Signals),2);
                for i=1:numel(this.Signals)
                    maxDimensions(i,:) = [1 size(this.Signals(i).Data, 2)];
                end
            elseif inputIndex <= numel(this.Signals)
                maxDimensions = [1 size(this.Signals(inputIndex).Data, 2)];
            else
                maxDimensions = [1 0];
            end
        end
        
        function minorSampleTimes = getMinorSampleTimes(this, ~)
            %GETMINORSAMPLETIMES Get the minorSampleTimes.
            
            minorSampleTimes = 0;
            if nargin < 2
                minorSampleTimes = repmat(minorSampleTimes, getNumInputs(this), 1);
            end
        end
        
        function numInputs = getNumInputs(this)
            %GETNUMINPUTS Get the numInputs.
            
            numInputs = numel(this.Signals);
        end
        
        function rawData = getRawData(this, ~)
            %GETRAWDATA Get the rawData.
            
            if nargin < 2
                rawData = {this.Signals.Data};
            end
        end
        
        function sampleTimes = getSampleTimes(this, ~)
            %GETSAMPLETIMES Get the sampleTimes.
            
            if ~isempty(this.Signals)
                sampleTimes = 1./cell2mat({this.Signals.Rate});
            else
                sampleTimes = [];
            end
            
            for i=1:numel(sampleTimes)
                sampleTimes(i) = sampleTimes(i) * size(this.Signals(i).Data, 1);
            end
        end
        
        function srcStr = getSourceName(~)
            
            srcStr = '';
        end
        
        function timeOfDisplayData = getTimeOfDisplayData(this)
            %GETTIMEOFDISPLAYDATA Get the timeOfDisplayData.
            
            timeOfDisplayData = 0;
            sigs = this.Signals;
            for indx = 1:numel(sigs)
                nSamples = size(sigs(indx).Data, 1);
                timeOfDisplayData = max(timeOfDisplayData, (nSamples-1)/sigs(indx).Rate);
            end
        end
        
        function b = isDataEmpty(this)
            %ISDATAEMPTY True if the object has empty data.
            
            b = isempty(this.Signals);
        end
        
        function b = isInputComplex(this, inputIndex)
            %ISINPUTCOMPLEX True if the input is complex
            
            if nargin == 1
                %return a column vector containing the complexity of each signal
                n = numel(this.Signals);
                b = false(n,1);
                for i=1:n
                    if ~isreal(this.Signals(i).Data)
                        b(i) = true;
                    end
                end
            else
                %return the complexity of the specified signal
                b = ~isreal(this.Signals(inputIndex).Data);
            end
        end
        
        function flag = isSerializable(~)
            %ISSERIALIZABLE Is data source serializable.
            %  Returns false if this data source should not be serialized
            %  into a data store, whether it is a file or a recent source list.
            %  Generally, sources that do not have a text-string that can be
            %  used to refer to the actual data repository are non-serializable,
            %  otherwise the actual data itself must be recorded into the
            %  repository leading to storage and efficiency issues.
            
            flag = false;
        end
        
        function onVisualChange(~)
            %ONVISUALCHANGE
            %   SPTool does not currently change the visual.
            
        end
        
        function updateDisplay(this) 
            hScope = this.Application; 
            if ~isempty(hScope.Visual) && this.IsSourceValid 
                update(hScope.Visual); 
                sendEvent(hScope, 'VisualUpdated'); 
            end 
        end 
        
        function flag = shouldShowControls(~, ~)
            %SHOULDSHOWCONTROLS For source specific control visibility
            % Returns true if the controls should be visible on the scope
            
            flag = false;
        end
    end
    
    methods (Hidden)
        function disable(this)
            %DISABLE Called when extension is disabled, overloaded for SrcSPTool.
            
            if this.ActiveSource
                % Stop the controls from sending more information up to the
                % source/visual combo.
                clearDisplay(this);
                releaseData(this.Application);
            end
        end
    end
    
    methods (Access = protected)
        function plugInGUI = createGUI(~)
            %CreateGUI Build and cache UI plug-in.
            %   This override prevents the default buttons/sources
            %   from being added to the scope.
            %   No install/render needs to be done here.
            
            plugInGUI = [];
            
        end
        
        function engageConnection_SourceSpecific(this)
            %engageConnection_SourceSpecific Called by Source::enable method when a source is enabled.
            %   Overload for SrcSPTool.
            
            this.ErrorStatus = 'success';
            this.ErrorMsg = '';
        end
        
        function controlsClass = getControlsClass(~)
            %GETCONTROLSCLASS Get the controlsClass.
            
            controlsClass = 'matlabshared.scopes.source.PlaybackControlsNull';
        end
        
        function def = getDefaultHandlerClass(~)
            def = '';
        end
    end
end

% [EOF]
