classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) powermetadataMCOS < hgsetget & matlab.mixin.Copyable
  %dspdata.powermetadata class
  %    dspdata.powermetadata properties:
  %       DataUnits - Property is of type 'string'
  %       FrequencyUnits - Property is of type 'string'
  %
  %    dspdata.powermetadata methods:
  %       disp - Display method for the metadata object.
  %       info -   Return information about the meta data
  %       setsourcespectrum -   Set the Source Spectrum.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %DATAUNITS Property is of type 'string'
    DataUnits = '';
    %FREQUENCYUNITS Property is of type 'string'
    FrequencyUnits = 'Hz';
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %SOURCESPECTRUM Property is of type 'mxArray'
    SourceSpectrum = [];
  end
  
  
  methods
    function set.DataUnits(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','DataUnits')
      obj.DataUnits = value;
    end
    
    function set.FrequencyUnits(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','FrequencyUnits')
      obj.FrequencyUnits = setfrequencyunits(obj,value);
    end
    
    function set.SourceSpectrum(obj,value)
      obj.SourceSpectrum = checkclasstype(obj,value);
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function disp(H)
      %DISP Display method for the metadata object.

      s = get(H);
      disp(s);
      
    end
    
    function varargout = info(this)
      %INFO   Return information about the meta data
      
      f = {'EstimationMethod', 'FrequencyUnits', 'DataUnits'};
      v = {this.FrequencyUnits, lclgetdataunits(this)};
      
      if isempty(this.SourceSpectrum)
        v = {'Unknown', v{:}};
      else
        
        % Get all the fields of the source and remove "estimationmethod"
        nf = fieldnames(this.SourceSpectrum);
        if iscell(nf)
          nf(find(strcmpi(nf,'EstimationMethod'))) = [];
        else
          nf = {};
        end
        f = [f nf(:)'];
        v = {this.SourceSpectrum.EstimationMethod, v{:}};
        
        for indx = 1:length(nf)
          v{end+1} = get(this.SourceSpectrum, nf{indx});
          if isnumeric(v{end})
            v{end} = num2str(v{end});
          end
        end
      end
      
      if nargout > 1
        varargout = {f, v};
      else
        
        for indx = 1:length(f), f{indx} = sprintf('%s:', f{indx}); end
        
        i = [strvcat(f) repmat(' ', length(f), 2) strvcat(v)];
        
        i = cellstr(i);
        i = sprintf('%s\n', i{:});
        
        if nargout
          varargout = {i};
        else
          fprintf(1, i);
        end
      end
      
    end
    
    function setsourcespectrum(this, sourcespectrum)
      %SETSOURCESPECTRUM   Set the Source Spectrum.

      this.SourceSpectrum = sourcespectrum;
      
    end
    
  end  %% public methods
  
end  % classdef

function frequnits = setfrequencyunits(this, frequnits)

if isempty(frequnits)
  frequnits = this.Metadata.FrequencyUnits;
  error(message('signal:dspdata:powermetadata:schema:invalidFrequencyUnits'));
end
end  % setfrequencyunits



%--------------------------------------------------------------------------
function value = checkclasstype(this,value)

if ~isempty(value) && ~isa(value,'spectrum.abstractspectrum')
  error(message('signal:dspdata:powermetadata:schema:InvalidClass'));
end
end  % checkclasstype

% -------------------------------------------------------------------------
function d = lclgetdataunits(this)

d = this.DataUnits;
if isempty(d)
  d = 'none';
end

end


