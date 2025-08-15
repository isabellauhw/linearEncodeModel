function subclassnames = findnonabstractsubclasses(varargin)
%FINDNONABSTRACTSUBCLASSES Find all the non-abstract subclasses of class c0
%   SUBCLASSNAMES = FINDNONABSTRACTSUBCLASSES(CO, P) find all the
%   non-abstract subclasses of class C0 in the package P and returns a cell
%   array of the class names in SUBCLASSNAMES.
%
%   SUBCLASSNAMES = FINDNONABSTRACTSUBCLASSES(CO, P, P1, P2, etc.) find all
%   non-abstract subclasses in packages P, P1, P2, etc.
%
%   SUBCLASSNAMES = FINDNONABSTRACTSUBCLASSES(H) find all non-abstract
%   subclasses for the specified object H.
%
%   SUBCLASSNAMES = FINDNONABSTRACTSUBCLASSES(CLASS) find all non-abstract
%   subclasses for the specified class CLASS, where CLASS is the full
%   constructor call including the package name.
%
%   SUBCLASSNAMES = FINDNONABSTRACTSUBCLASSES find all non-abstract
%   subclasses for the class defined in the current directory.
%
%   See also FINDALLWINCLASSES.

%   Author(s): V.Pellissier
%   Copyright 1988-2017 The MathWorks, Inc.

% Parse the inputs.
[c0, p0, pAll, isfull, fMCOS] = parseInputs(varargin{:});


%The input argument p0 corresponds to only MCOS or UDD packages (not both).
%If p0 package exists in both UDD and MCOS, use the flag parameter ('-MCOS'
%or '-UDD'. This must come after -full, if provided). If none is provided,
%error out. If the package only exists in UDD or MCOS (not both), ignore
%this flag. Any additional packages are assumed to be from the same class
%system as p0. If they are not found, this function will error out.
isUDD = ~isempty(findpackage(p0));
isMCOS = ~isempty(meta.package.fromName(p0));

if isUDD && isMCOS 
  switch fMCOS
    case 'MCOS'
      isUDD = false;
    case 'UDD'
      isMCOS = false;
    case 'none'
      error(message('signal:findnonabstractsubclasses:UDDandMCOS'));
  end
end

if isUDD % package is UDD
  p = findpackage(p0);
  c = findclass(p);

  for indx = 1:length(pAll)
      pp = findpackage(pAll{indx});
      if isempty(pp)
        %The package name is not valid in UDD
        error(message('signal:findnonabstractsubclasses:InvalidParam'));
      end
      c  = union(c, findclass(pp));
  end

  % Find class c0
  i = 1;
  index = [];
  while isempty(index) && i<=length(c)
      if strcmpi(c0,c(i).Name)
          index = i;
      else
          i = i+1;
      end
  end
  c0 = c(index);
  c(index) = [];

  % Find the subclasses of c0
  nsubclasses=[];
  for i=1:length(c)
      if c(i).isDerivedFrom(c0)
          nsubclasses = [nsubclasses; i];
      end
  end

  % Remove the abstract classes
  removedindex = [];
  for j=1:length(nsubclasses)
      if strcmpi(c(nsubclasses(j)).Description, 'abstract')
          removedindex=[removedindex; j];
      end
  end
  nsubclasses(removedindex) = [];

  % Get the class names
  subclassnames={};
  for k=1:length(nsubclasses)
      if isfull
          pkgname = get(c(nsubclasses(k)).Package, 'Name');
          subclassnames=[subclassnames;{[pkgname '.' c(nsubclasses(k)).Name]}];
      else
          subclassnames=[subclassnames;{c(nsubclasses(k)).Name}];
      end
  end

  % Re-order
  subclassnames = subclassnames(end:-1:1);
elseif isMCOS % package is MCOS
    mp = meta.package.fromName(p0);
    c0 = [p0 '.' c0];
    pl = length(p0)+1; %length of the package name string, including the dot
    c = mp.ClassList;
    
    for indx = 1:length(pAll)
      mp = meta.package.fromName(pAll{indx});
      if isempty(mp)
        %The package name is not valid in MCOS
        error(message('signal:findnonabstractsubclasses:InvalidParam'));
      end
      c  = union(c, mp.ClassList);
    end
    
    % Find class c0
    i = 1;
    index = [];
    while isempty(index) && i<=length(c)
        if strcmpi(c0,c(i).Name)
            index = i;
        else
            i = i+1;
        end
    end
    c0 = c(index);
    c(index) = [];
    
      
    if ~isempty(c0)
      c0Name = c0.Name;
    else
      c0Name = '';
    end

    % Find the subclasses of c0
    nsubclasses=[];
    for i=1:length(c)
      scl = superclasses(c(i).Name);
      if any(strcmp(scl,c0Name))
          nsubclasses = [nsubclasses; i];
      end
    end
    
    % Remove the abstract classes
    removedindex = [];
    for j=1:length(nsubclasses)
        if c(nsubclasses(j)).Abstract
            removedindex=[removedindex; j];
        end
    end
    nsubclasses(removedindex) = [];
    
    % Get the class names
    subclassnames={};
    for k=1:length(nsubclasses)
        if isfull
            subclassnames=[subclassnames;{[c(nsubclasses(k)).Name]}];
        else
            newname = c(nsubclasses(k)).Name;
            subclassnames=[subclassnames;{newname(pl+1:end)}];
        end
    end

    % Re-order
    subclassnames = subclassnames(end:-1:1);
else
  error(message('signal:findnonabstractsubclasses:NotSupported'));
end

% -------------------------------------------------------------------------
function [cls, pkg, otherPackages, isfull, fMCOS] = parseInputs(varargin)

% Check if the last argument is the "-MCOS" or "-UDD" flag and remove it from the
% arguments list if it is present.
if nargin > 0 && ischar(varargin{end}) && strcmpi(varargin{end}, '-MCOS')
    fMCOS = 'MCOS';
    varargin(end) = [];
elseif nargin > 0 && ischar(varargin{end}) && strcmpi(varargin{end}, '-UDD')
    fMCOS = 'UDD';
    varargin(end) = [];
else
    fMCOS = 'none';
end
% Check if the last argument is the "-full" flag and remove it from the
% arguments list if it is present.
if ~isempty(varargin) > 0 && ischar(varargin{end}) && strcmpi(varargin{end}, '-full')
    isfull        = true;
    varargin(end) = [];
else
    isfull = false;
end

if isempty(varargin)

    % If there are no arguments, we need to decipher the package and class
    % from the path.
    p          = pwd;
    [p, pkg]   = strtok(p, '@+');
    if isempty(pkg)
        error(message('signal:findnonabstractsubclasses:NotSupported'));
    end
    pkg(1)     = [];
    [pkg, cls] = strtok(pkg, '@');
    pkg(end)   = [];
    cls(1)     = [];
elseif all(ishandle(varargin{1})) || isobject(varargin{1})
        
    % If the first input is an object get the package and class from
    % the CLASS method.
    [pkg, cls]  = strtok(class(varargin{1}), '.');
    cls(1)      = [];
    varargin(1) = [];
elseif nargin > 1
    cls           = varargin{1};
    pkg           = varargin{2};
    varargin(1:2) = [];
else
    error(message('signal:findnonabstractsubclasses:InvalidParam'));
end

otherPackages = varargin;

% [EOF]
