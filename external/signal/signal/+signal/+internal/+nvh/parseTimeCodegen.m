function [xout,t,td,timeType,timeFormat] = parseTimeCodegen(x,fncStr,T,isMultiChannel)
%PARSETIMECODEGEN Parse signal and time information
%   This function is for internal use only. It may be removed. 

%   Copyright 2017 The MathWorks, Inc.

% This function parses the pattern in MATLAB and codegen:
% fnc(x)      x is a vector or matrix
% fnc(x,fs)   x is a vector or matrix, fs is a scalar
% fnc(x,T)    x is a vector or matrix, T is a vector or scalar/vector duration 
% fnc(XT)     XT is a timetable with one column
%
% Returns additional time information (datetime, duration, sample number)
% vectors in td for plotting.

%#ok<*EMCLS>
%#ok<*EMCA>
%#codegen

% Indicate if the user specified T
isInMATLAB = coder.target('MATLAB');
hasT = ~isempty(T);
isTTable = isa(x,'timetable');
isSingle = isa(x,'single');
if isSingle
  td = zeros(0,0,'like',single(0)); % By default, no extra time information
else
  td = zeros(0,0);
end
timeType = '';
timeFormat = '';

if isInMATLAB
  % Parse X and T
  if isTTable
      
    % Ensure tables contain numeric variables that are matrices or vectors
    if ~all(varfun(@isnumeric,x,'OutputFormat','uniform'))
        error(message('signal:tsa:InvalidTT','XT'));
    end                              
    
    if isMultiChannel
        % Make sure we have a table with a single variable containing a
        % matrix or multiple variables containing vectors
        if (size(x,2) > 1 && ~all(varfun(@isvector,x,'OutputFormat','uniform'))) || ...
                (size(x,2) == 1 && ~ismatrix(x{:,:}))
            error(message('signal:tsa:InvalidTTMultiChannel','XT'));
        end        
    else
        % Make sure we have only one vector of values in the table.
        if size(x,2) > 1 || ~isvector(x{:,:})
            error(message('signal:tsa:InvalidTTSingleChannel','XT'));
        end        
    end
    if isTTable && hasT
      error(message('signal:tsa:TTORT'));
    end
    t = x.Properties.RowTimes;
    x = x{:,:};
    if isa(t,'duration')
      td = t;
      timeType = 'duration';
      timeFormat = t.Format;
      t = seconds(t);
    else % datetime
      td = t;
      timeType = 'datetime';
      timeFormat = t.Format;      
      t = t - t(1);
      t = seconds(t);
    end
  elseif hasT
    t = T;
    validateattributes(t,{'double','single','duration'},{},fncStr,'T');
    if isduration(t)
      if ~isvector(t) 
        % Throw error if empty or we have a matrix.
        error(message('signal:tsa:VectorDuration'));
      end
      timeType = 'duration';
      timeFormat = t.Format;
      if isscalar(t)                
        t = (0:length(x)-1)'*seconds(t);
      else
        td = t;
        t = seconds(t(:));
      end
    elseif isscalar(t) 
      % Sample rate was provided.
      t = (0:length(x)-1)'/t;
    else
      % No op
    end
  else
    % No time information provided. Return samples.
    t = (1:length(x))';
    td = t;
  end
else
 % Parse X and T
  cond = isa(x,'single')|isa(x,'double');
  coder.internal.assert(cond,'signal:tsa:XTNumeric','X','T');
  if hasT
    cond = isa(T,'single')|isa(T,'double');
    coder.internal.assert(cond,'signal:tsa:XTNumeric','X','T');
    if isSingle
      tArg = single(T);
    else
      tArg = double(T);
    end
    if isscalar(tArg) 
      % Sample rate was provided.
      t = (0:length(x)-1)'/tArg;
    else
      t = tArg;
    end
  else
    % No time information provided. Return samples.
    if isSingle
      t = single((1:length(x))'); 
    else
      t = (1:length(x))';
    end
    td = t;
  end
end

% Return a matrix or a column vector.
if isvector(x)
  xout = x(:);
else
  xout = x;
end

end