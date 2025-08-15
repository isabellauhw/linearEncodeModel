function updatecurrentspecs(this)
%UPDATECURRENTSPECS   Update the currentSpecs object.

%   Copyright 1999-2017 The MathWorks, Inc.

% Get the constructor for the current specification type.
cSpecCon = getconstructor(this);

% % If the CurrentSpecs is already correct, just return.
% if strcmpi(class(this.CurrentSpecs), cSpecCon), return; end

% If there are any stored SPEC objects see if our constructor matches.
allSpecs = this.AllSpecs; 
if isempty(allSpecs) 
  cSpec = [];
else 
  cList = {}; %List of classes for each element in allSpecs
  for i = 1:length(allSpecs)
    cList{i} = class(allSpecs(i)); %#ok<AGROW>
  end
  cSpec = allSpecs(strcmp(cList, cSpecCon)); 
end

% If we could not find the needed spec object, create it and store it.
if isempty(cSpec)
    cSpec = feval(cSpecCon);
    this.AllSpecs = [allSpecs; cSpec];
end

% Set the current specs, this will fire the pre-set to update the props.
% Reset value 'FromFilterDesigner' so that 
if ~isempty(this.CurrentSpecs) && ~(cSpec == this.CurrentSpecs) && isequal(this.CurrentSpecs,cSpec)
  % CurrentSpecs and AllSpecs should point to the same object, but Abortset
  % will prevent this for objects with different handles but the same
  % properties. (==) compares the handles of two objects, whereas (isequal)
  % compares the property values. Setcurrentspecs is called in the set
  % method of CurrentSpecs, and is forced here in the case that abortset
  % would prevent the correct object from being assigned.
  setcurrentspecs(this,cSpec);
else
  this.CurrentSpecs = cSpec;
end

end

% [EOF]
