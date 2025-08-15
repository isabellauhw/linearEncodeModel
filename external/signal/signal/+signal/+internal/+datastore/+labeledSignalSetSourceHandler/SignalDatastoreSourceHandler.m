classdef SignalDatastoreSourceHandler < signalwavelet.internal.labeling.BaseSourceHandler
%SignalDatastoreSourceHandler Source handler for SignalDatastore used by labeledSignalSet
%   This class is for internal use only and may change in the future.
    
    %   Copyright 2020 MathWorks, Inc.
    
properties (SetAccess = protected)
    Datastore
end

methods
    function this = SignalDatastoreSourceHandler(ds,varargin)
        assert(isa(ds,'signalDatastore') && isvalid(ds), ...
            getString(message('signal:signalDatastore:labeledSignalSetSourceHandler:SignalDatastoreSourceHandler:InvalidObjectType')));
        this.Datastore = copy(ds);
        this.Datastore.ReadSize = 1;
    end
end

% implement abstract methods for signalwavelet.internal.labeling.BaseSourceHandler
methods (Hidden)
    function sInfo = addMembers(this,newDatastore,~)
        % Merge new datastore with source datastore
                        
        newObservations = string(getObservationsNames(newDatastore));
        
        % add the new files to the datastore
        this.Datastore = mergeImpl(this.Datastore,newDatastore);
                
        % return new files info
        sInfo.NewNumMembers = numel(newObservations);
        sInfo.NewMemberNameList = newObservations;
    end
    
    function removeMembers(this,mIdxVect)
        % Remove items from the datastore
        numMembers = numobservations(this.Datastore);
        currentIdx = 1:numMembers;
        keepIdx = ismember(currentIdx,mIdxVect);
        keepIdx = find(keepIdx == false);
        this.Datastore = subset(this.Datastore,keepIdx);        
    end
    
    function numMembers = getNumMembers(this)
        numMembers = numobservations(this.Datastore);
    end
    
    function nameList = getMemberNameList(this)
        nameList = string(getObservationsNames(this.Datastore));
    end
    
    function tInfo = getTimeInformation(~)
        tInfo = "inherent";
    end
           
    function data = getSourceData(this)
        data = copy(this.Datastore);
    end
    
    function data = getPrivateSourceData(this)
        data = this.Datastore;
    end
    
    function [s,info] = getSignalEnsemble(this,mIdx)
        [s, info] = read(subset(this.Datastore,mIdx));
    end   
end

methods (Access = protected)
    function cp = copyElement(this)
        % Properties that are handle objects need to be individually
        % copied for a deep copy.
        cp = copyElement@matlab.mixin.Copyable(this);
        if ~isempty(this.Datastore)
            cp.Datastore = copy(this.Datastore);
        end
    end
end

methods (Hidden, Static)
    function flag = isDataSupportedBySourceHandler(ds,errorFlag)
        if nargin < 2
            errorFlag = false;
        end
        % SignalDatastoreSourceHandler supports a signalDatastore object
        flag = isa(ds,'signalDatastore') && isvalid(ds);
        
        if ~flag && errorFlag
            error(message('signal:signalDatastore:labeledSignalSetSourceHandler:SignalDatastoreSourceHandler:InvalidObjectType'));
        end
    end
    
    function flag = isSupportedInSignalLabeler(sourceHandler)
        % Only file datastore is supported
        flag = ~sourceHandler.Datastore.isInMemory &&...
            sourceHandler.Datastore.isReadFcnDefault &&...
            isempty(sourceHandler.Datastore.AlternateFileSystemRoots);
    end
end
end
