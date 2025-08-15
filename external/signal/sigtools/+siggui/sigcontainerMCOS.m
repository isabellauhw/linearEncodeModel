classdef (Abstract) sigcontainerMCOS < siggui.sigguiMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %siggui.sigcontainer class
  %   siggui.sigcontainer extends siggui.siggui.
  %
  %    siggui.sigcontainer properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %
  %    siggui.sigcontainer methods:
  %       addcomponent - Add a component to the container
  %       allchild - Return the children of this object
  %       cshelpcontextmenu - Add context sensitive help for the frame
  %       enable_listener - Listener to the Enable Property
  %       getcomponent - Retrieve a component handle from the container
  %       getstate - Returns the state for the container and its components
  %       notification_listener - Listener notification events
  %       resizefcn -  Layout the uis if figure is different from default
  %       rmcomponent -   Remove the component.
  %       setstate - Set the state of the object
  %       setunits - Set the units of the frame and its children
  %       sigcontainer_enable_listener - Perform the work of the enable listener
  %       sigcontainer_getstate - GETSTATE Returns the state for the container and its components
  %       sigcontainer_setstate - SETSTATE Set the state of the object
  %       thisunrender - Unrender the container and its components
  %       visible_listener - Listener to the Enable Property
  
  
  properties (Access=protected, SetObservable, GetObservable)
    %NOTIFICATIONLISTENER Property is of type 'addlistener vector'
    NotificationListener = [];
  end
  
  
  methods
    function set.NotificationListener(obj,value)
      if ~isempty(value)
        validateattributes(value,{'event.listener'}, {'vector'},'','NotificationListener')
      end
      obj.NotificationListener = value;
    end
    
    
    function addcomponent(hParent, hChildren)
      %ADDCOMPONENT Add a component to the container
      %   ADDCOMPONENT(hPARENT, hCHILDREN) Add the objects hCHILDREN to be
      %   children of the sigcontainer hPARENT.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      narginchk(2,2);
      
      hChildren = hChildren(:)';
      
      for hindx = hChildren
        if ~isa(hindx, 'siggui.sigguiMCOS')
          warning(message('signal:sigcontainer:ChildMustBeSiggui'));
        else
          hParent.addChildren(hindx);
        end
      end
      
      % Call a separate method to add the listener to the notification event.
      % This will allow subclasses to overload this method.
      attachnotificationlistener(hParent);
      
    end
    
    function hChildren = allchild(hParent)
      %ALLCHILD Return the children of this object
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % Get all the children of the object
      hChildren = findobj(hParent, '-depth', 1);
      
      % Remove the first element which is hParent
      hChildren(1) = [];
      
      hChildren = [hChildren(:)]';
      
    end
    
    
    function cshelpcontextmenu(hObj, varargin)
      %CSHELPCONTEXTMENU Add context sensitive help for the frame
      
      % Author(s): J. Schickler
      % Copyright 1988-2002 The MathWorks, Inc.
      
      % Add the CSH to all HG objects at this level
      siggui_cshelpcontextmenu(hObj, varargin{:});
      
      hC = allchild(hObj);
      
      for indx = 1:length(hC)
        
        % Add the CSH to all the HG objects at the contained level
        if isrendered(hC(indx))
          cshelpcontextmenu(hC(indx), varargin{:});
        end
      end
      
      
    end
    
    
    function enable_listener(hObj, varargin)
      %ENABLE_LISTENER Listener to the Enable Property
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      sigcontainer_enable_listener(hObj, varargin{:});
      
    end
    
    
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
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      narginchk(2,inf);
      
      if nargin > 2
        varargin = {tag, varargin{:}};
      elseif nargin > 1
        varargin = {'Tag', tag};
      end
      
      hChild = allchild(hParent);
      
      if ~isempty(hChild)
        hChild = findobj(hChild, '-depth', 0, varargin{:});
      end
      
    end
    
    function s = getstate(hParent)
      %GETSTATE Returns the state for the container and its components
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      s = sigcontainer_getstate(hParent);
      
      
    end
    
    
    function notification_listener(hObj, eventData)
      %NOTIFICATION_LISTENER Listener notification events
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      % The default notification_listener simply rethrows the notification.
      % Individual subclasses must overload notification_listener if they want to
      % intercept the event.
      
      notify(hObj, 'Notification', eventData);
      
    end
    
    function resizefcn(this, varargin)
      % Layout the uis if figure is different from default
      % H - Input is the handle to the object after all children have been added
      % IdealSize - Size at which the figure would ideally have been created
      
      %   Author(s): Z. Mecklai
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      siggui_resizefcn(this, varargin{:});
      
      % Get the children (if any), ignore dialogs
      hC = findobj(allchild(this), '-depth', 0, '-not', '-isa', 'siggui.dialogMCOS');
      
      for indx = 1:length(hC)
        if isrendered(hC(indx))
          resizefcn(hC(indx), varargin{:});
        end
      end
      
      
    end
    
    
    function rmcomponent(this, h)
      %RMCOMPONENT   Remove the component.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      narginchk(2,2);
      
      h = h(:)';
      
      for hindx = h
        if ~isa(hindx, 'siggui.sigguiMCOS')
          warning(message('signal:sigcontainer:ChildMustBeSiggui'));
        else
          disconnect(hindx);
        end
      end
      
      % Call a separate method to add the listener to the notification event.
      % This will allow subclasses to overload this method.
      attachnotificationlistener(this);
      
    end
    
    
    function setstate(hParent, s)
      %SETSTATE Set the state of the object
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      narginchk(2,2);
      
      sigcontainer_setstate(hParent, s);
      
    end
    
    
    function setunits(hObj, units)
      %SETUNITS Set the units of the frame and its children
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      narginchk(2,2);
      
      % Set the units for the object itself
      siggui_setunits(hObj, units);
      
      % Set the units of the objects children
      for hindx = allchild(hObj)
        if isrendered(hindx), setunits(hindx, units); end
      end
      
      
    end
    
    function sigcontainer_enable_listener(hObj, varargin)
      %SIGCONTAINER_ENABLE_LISTENER Perform the work of the enable listener
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      % Set the enable state of all HG object
      siggui_enable_listener(hObj, varargin{:});
      
      hC = allchild(hObj);
      
      for indx = 1:length(hC)
        if isrendered(hC(indx))
          set(hC(indx), 'Enable', hObj.Enable);
        end
      end
      
      
    end
    
    
    function s = sigcontainer_getstate(hParent)
      %GETSTATE Returns the state for the container and its components
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      s = siggui_getstate(hParent);
      
      % Loop over all the children and get their states
      for hindx = allchild(hParent)
        ClassName = regexp(class(hindx),'\.','split');
        ClassName = ClassName{end};
        
        if strcmpi(ClassName(end-3:end),'MCOS')
          ClassName = ClassName(1:end-4);
        end
        
        s.(ClassName) = getstate(hindx);
      end
      
    end
    
    
    function sigcontainer_setstate(hParent, s)
      %SETSTATE Set the state of the object
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      narginchk(2,2);
      
      fields = fieldnames(s);
      
      for indx = 1:length(fields)
        hChild = getcomponent(hParent, '-class', ['siggui.' fields{indx}]);
        if ~isempty(hChild)
          setstate(hChild, s.(fields{indx}));
          s = rmfield(s, fields{indx});
        end
      end
      
      siggui_setstate(hParent, s);
      
      
    end
    
    function thisunrender(this)
      %THISUNRENDER Unrender the container and its components
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      %     o
      
      delete(handles2vector(this));
      
      % Unrender all the children
      for hindx = allchild(this)
        unrender(hindx);
      end
      
      delete(this.Container);
      
      
    end
    
    function visible_listener(hObj, eventData)
      %VISIBLE_LISTENER Listener to the Enable Property
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      sigcontainer_visible_listener(hObj, eventData);
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function attachnotificationlistener(hParent)
      %ATTACHNOTIFICATIONLISTENER
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2002 The MathWorks, Inc.
      
      hAllChildren = allchild(hParent);
      
      % Add a listener to a local function.  Creating function handles for
      % external MATLAB files is very slow.  Local functions is much faster.
      if ~isempty(hAllChildren)
        for idx = 1:length(hAllChildren)
          hListener(idx) = event.listener(hAllChildren(idx), 'Notification', @(s,e)lclnotification_listener(hParent,e)); %#ok<AGROW>
        end
        
        hParent.NotificationListener = hListener;        
      end    
      
    end
    
    
    function sigcontainer_visible_listener(hObj, varargin)
      %SIGCONTAINER_VISIBLE_LISTENER
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      % Set the visible state of all HG object
      siggui_visible_listener(hObj, varargin{:});
      
      % Get the children (if any), ignore dialogs
      Children = allchild(hObj);
      if strcmpi(get(hObj, 'Visible'), 'on')
        Children = findobj(Children, '-depth', 0, '-not', '-isa', 'siggui.dialog');
      end
      
      for indx = 1:length(Children)
        if isrendered(Children(indx))
          set(Children(indx), 'Visible', hObj.Visible);
        end
      end
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef


% -----------------------------------------------------------
function lclnotification_listener(hObj, eventData, varargin)

notification_listener(hObj, eventData, varargin{:});

end
