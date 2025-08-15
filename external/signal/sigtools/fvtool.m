function varargout = fvtool(varargin) 
%FVTOOL Filter Visualization Tool (FVTool)
%   FVTool is a Graphical User Interface (GUI) that allows you to analyze
%   digital filters.  
%
%   FVTOOL(B,A) launches the Filter Visualization Tool and computes the
%   Magnitude Response for the filter defined by numerator and denominator
%   coefficients in vectors B and A.
%
%   FVTOOL(SOS) launches the Filter Visualization Tool and computes the
%   Magnitude Response for the filter defined by the second order sections
%   matrix, SOS. SOS is a Kx6 matrix, where the number of sections, K, must
%   be greater than or equal to 2.
%
%   FVTOOL(D) launches the Filter Visualization Tool and computes the
%   Magnitude Response for the digital filter D. You design a digital
%   filter, D, by calling the <a href="matlab:help designfilt">designfilt</a> function.
% 
%   FVTOOL(B,A,B1,A1,SOS,SOS1,D1,D2,...) will perform an analysis on
%   multiple filters.
%
%   If the DSP System Toolbox is installed, the input object Hd can also
%   be a filter System object, discrete-time filter object (DFILT),
%   multirate filter object (MFILT), or an adaptive filter object,
%   (ADAPTFILT).
%
%   FVTOOL(Hd1,..,Hdn) will perform analysis on multiple filter objects
%   Hd1,...,Hdn.
%
%   When the input filter is a DFILT or MFILT object, FVTool will perform
%   fixed-point analysis if the Arithmetic property of the filter objects
%   is set to 'fixed'.
%
%   FVTOOL(Hd,'Arithmetic',ARITH,...) analyzes the filter System object,
%   Hd, based on the arithmetic specified in the ARITH input. ARITH can be
%   set to one of 'double', 'single', or 'fixed'. The analysis tool assumes
%   a double precision filter when the arithmetic input is not specified
%   and the filter System object is in an unlocked state. The 'Arithmetic'
%   input is only relevant for the analysis of filter System objects. The
%   arithmetic setting, ARITH, applies to all the filter System objects
%   that you input to FVTool.
%
%   H = FVTOOL(...) returns the handle to FVTool.  This handle can be
%   used to interface with FVTool through the GET and SET commands as you
%   would with a normal figure, but with additional properties.  Some of
%   these properties are analysis-specific and will change whenever the 
%   analysis changes.  Execute GET(H) to see a list of FVTool's properties 
%   and current values.
%
%   FVTOOL(...,PROP1,VALUE1,PROP2,VALUE2, etc.) launches FVTool and sets
%   the specified properties to the specified values.
%
%   The following methods are defined for H, the handle to FVTool:
%
%   ADDFILTER(H, FILTOBJ), where FILTOBJ is a DFILT or a <a href="matlab:help digitalFilter">digitalFilter</a> object,
%   will add a new filter, FILTOBJ, to FVTool without affecting the filters
%   currently being analyzed.
%
%   ADDFILTER(H, FILTOBJ, 'Arithmetic', ARITH), where FILTOBJ is a System
%   object, adds a new filter, FILTOBJ, to FVTool without affecting the
%   filters currently being analyzed. The analysis of the filter System
%   object is based on the arithmetic specified in the ARITH input. The
%   analysis tool assumes a double precision filter when the arithmetic
%   input is not specified and the filter System object is in an unlocked
%   state.
%   
%   SETFILTER(H, FILTOBJ) replaces the filter in FVTool with the DFILT or
%   <a href="matlab:help digitalFilter">digitalFilter</a> object, FILTOBJ.
%
%   SETFILTER(H, FILTOBJ, 'Arithmetic', ARITH) replaces the filter in
%   FVTool with the System object, FILTOBJ. The analysis of the filter
%   System object is based on the arithmetic specified in the ARITH input.
%   The analysis tool assumes a double precision filter when the arithmetic
%   input is not specified and the filter System object is in an unlocked
%   state.
%
%   DELETEFILTER(H, INDEX) deletes the filter at specified INDEX from FVTool.
%
%   LEGEND(H, STRING1, STRING2, etc.) creates a legend on FVTool by
%   associating STRING1 with Filter #1, STRING2 with Filter #2 etc.
%
%   ZOOM(H, [XMIN XMAX YMIN YMAX]) zoom into the area specified by XMIN,
%   XMAX, YMIN and YMAX.
%
%   ZOOM(H, 'x', [XMIN XMAX]) constrain the zoom to the x-axis.
%
%   ZOOM(H, 'y', [YMIN YMAX]) constrain the zoom to the y-axis.
%
%   ZOOM(H, 'default') restore the default axis limits.
%
%   ZOOM(H, 'passband') zoom into the passband. This feature is only
%   available when you have a DSP System Toolbox license and when all of
%   the filters in FVTool were designed with the <a href="matlab:help designfilt">designfilt</a> function 
%   or with an FDESIGN object.
%
%   % Example 1:
%   %   Magnitude Response of an IIR filter.
% 
%   [b,a] = butter(5,.5);                                                 
%   h1 = fvtool(b,a);                                                     
%   Hd = dfilt.df1(b,a); % Discrete-time filter (DFILT) object            
%   h2 = fvtool(Hd);                                                      
%
%   % Example 2:
%   %   Using FVTool's API.
%   
%   set(h2, 'Analysis', 'impulse'); % Change the analysis 
%   
%   b = firpm(20,[0 0.4 0.5 1],[1 1 0 0]); 
%   Hd2 = dfilt.dffir(b);                                                
%   addfilter(h2, Hd2);             % Add a new filter 
%
%   % Setting FVTool's analysis-specific properties
%   h = fvtool(Hd2,'Analysis','phase','PhaseDisplay','Continuous Phase');
%
%   % Example 3:
%   %   Analysis of multiple FIR filters.
%  
%   b1 = firpm(20,[0 0.4 0.5 1],[1 1 0 0]); 
%   b2 = firpm(40,[0 0.4 0.5 1],[1 1 0 0]); 
%   fvtool(b1,1,b2,1);
%
%   % Example 4:
%   %   Design a Butterworth highpass IIR filter, represent its coefficients 
%   %   using second order sections, and visualize the filter with fvtool.
%
%   [z,p,k] = butter(6,0.7,'high');
%   SOS = zp2sos(z,p,k);    
%   fvtool(SOS)             % Visualize the filter
%   
%   See also FILTERDESIGNER, SPTOOL.

%    Copyright 1988-2017 The MathWorks, Inc.

% Parse the inputs
narginchk(1,inf);

if (isempty(varargin{1}))
    ME = MException('signal:fvtool:EmptyInput', getString(message('signal:sigtools:fvtool:EmptyInputIsNotSupported')));
    throwAsCaller(ME);
end

try
    % Instantiate the fvtool object.
    hObj = sigtools.fvtool(varargin{:});
catch ME
    throwAsCaller(ME);
end



% Turn FVTool on
set(hObj,'Visible','On');

% Turn off warnings, call drawnow to update the figure and then call
% refresh to fix g339805.  Warnings are being thrown from DRAWNOW on intel
% mac because of an HG issue.
w = warning('off'); %#ok<WNOFF>
drawnow
warning(w);
refresh(double(hObj));

% Return FVTools' handle
if nargout > 0
    varargout{1} = hObj;
end

% [EOF]
