function hChild = getcomponent(hParent, tag, varargin)
%GETCOMPONENT Retrieve a component handle from the container
%   GETCOMPONENT(hOBJ, TAG) Retrieve a component handle from the container
%   by searching for its tag.
%
%   GETCOMPONENT(hOBJ, PROP, VALUE, PROP2, VALUE2, ...) Retrieve a component
%   handle from the container by searching according to property value pairs.
%
%   GETCOMPONENT returns an empty vector if the object is not found.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,inf);

if nargin > 2
    varargin = {tag, varargin{:}};
elseif nargin > 1
    varargin = {'Tag', tag};
end

hChild = allchild(hParent);

if ~isempty(hChild)
    hChild = find(hChild, '-depth', 0, varargin{:});
end

% [EOF]
