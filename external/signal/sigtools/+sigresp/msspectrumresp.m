classdef msspectrumresp < sigresp.freqz
  %sigresp.msspectrumresp class
  %   sigresp.msspectrumresp extends sigresp.freqz.
  %
  %    sigresp.msspectrumresp properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %       Legend - Property is of type 'on/off'
  %       Grid - Property is of type 'on/off'
  %       Title - Property is of type 'on/off'
  %       FrequencyScale - Property is of type 'string'
  %       NormalizedFrequency - Property is of type 'string'
  %       FrequencyRange - Property is of type 'string'
  %       MagnitudeDisplay - Property is of type 'string'
  %       Spectrum - Property is of type 'dspdata.abstractfreqresp'
  %
  %    sigresp.msspectrumresp methods:
  %       getylabels -  Method to get the list of strings to be used for the ylabels.
  
  
  
  methods  % constructor block
    function hresp = msspectrumresp(varargin)
      %MSSPECTRUMRESP   Construct a mean-square response object.
      %    MSSPECTRUMRESP(Sxx,Fs) constructs a mean-square response object with
      %    the spectrum specified by the object H.  H must be an object that
      %    extends DSPDATA.ABSTRACPS.

      % Create a response object.
      % hresp = sigresp.msspectrumresp;
      freqz_construct(hresp,varargin{:});
      
      % Set the name first and let the constructor overwrite it.
      hresp.Name = 'Mean-square Response';  % Title string
      hresp.Tag  = 'msspectrumresp';
      
      
    end  % msspectrumresp
    
  end  % constructor block
  
  methods  %% public methods
    function ylabels = getylabels(this)
      %GETYLABELS  Method to get the list of strings to be used for the ylabels.

      if isempty(this.Spectrum)
        dataunits = '';
      else
        dataunits = sprintf(' (%s)', this.Spectrum.MetaData.DataUnits);
      end
      
      lblstr = 'Power';
      ylabels = {...
        sprintf('%s%s',lblstr,dataunits), ...
        [lblstr,' (dB)']};
      
    end
    
  end  %% public methods
  
end  % classdef

