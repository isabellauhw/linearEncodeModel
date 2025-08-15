function data2xp= formatexportdata(h)
%FORMATEXPORTDATA Utility used to call exportdata methods.

% This should be a private method

%   Copyright 1988-2017 The MathWorks, Inc.

% Includes vectors and handle objects
data2xp = {};
data = cell(h.data);

% If Dynamic Property 'ExportAs' exists, can export either objects or arrays
if isprop(h, 'ExportAs') && isdynpropenab(h,'ExportAs')
  if any(strcmpi({'Objects','System Objects'},get(h,'ExportAs')))
    data2xp = data;
    for indx = 1:length(data2xp)
      data2xp{indx} = copy(data2xp{indx});
      % Convert filters to System objects if it has been requested
      if strcmpi(get(h,'ExportAs'),'System Objects')
        data2xp{indx} = sysobj(data2xp{indx});
      end
    end
  else
    % Call the object specific exporting methods
    for n = 1:length(data)
      newdata  = exportdata(data{n});
      data2xp =  {data2xp{:},newdata{:}}; %#ok<CCAT>
    end
  end
else
  % For the case of exporting arrays, call the built-in exporting method.
  data2xp = exportdata([data{:}]);
end
