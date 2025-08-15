classdef (Abstract) abstractsbarbmag < fspecs.abstractspecwithfs
%ABSTRACTSBARBMAG   Construct an ABSTRACTSBARBMAG object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.abstractsbarbmag class
%   fspecs.abstractsbarbmag extends fspecs.abstractspecwithfs.
%
%    fspecs.abstractsbarbmag properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       Frequencies - Property is of type 'double_vector user-defined'  
%       Amplitudes - Property is of type 'double_vector user-defined'  
%
%    fspecs.abstractsbarbmag methods:
%       get_phases -   PreGet function for the 'phases' property.
%       getmask - Get the mask.
%       measureinfo - Return a structure of information for the measurements.
%       props2normalize -   Return the property name to normalize.
%       set_amplitudes -   PreSet function for the 'amplitudes' property.
%       set_frequencies - PreSet function for the 'frequencies' property.
%       super_validatespecs -   Validate the specs
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %FREQUENCIES Property is of type 'double_vector user-defined' 
    Frequencies = [0:0.01:0.18 [.2 .38 .4 .55 .562 .585 .6 .78] 0.79:0.01:1];
    %AMPLITUDES Property is of type 'double_vector user-defined' 
    Amplitudes = [.5+sin(2*pi*7.5*(0:0.01:0.18))/4 [.5 2.3 1 1 .001 .001 1 1] .2+18*(1-(0.79:0.01:1)).^2];
end


    methods 
        function set.Frequencies(obj,value)
        % User-defined DataType = 'double_vector user-defined'
         validateattributes(value,{'double'},...
          {'vector'},'','Frequencies');
        obj.Frequencies = set_frequencies(obj,value);
        end

        function set.Amplitudes(obj,value)
        % User-defined DataType = 'double_vector user-defined'
         validateattributes(value,{'double'},...
          {'vector'},'','Amplitudes');
        obj.Amplitudes = set_amplitudes(obj,value);
        end

    end   % set and get functions 

    methods  % public methods
    phases = get_phases(this,phases)
    [F,A] = getmask(this)
    minfo = measureinfo(this)
    p = props2normalize(this)
    amplitudes = set_amplitudes(this,amplitudes)
    frequencies = set_frequencies(this,frequencies)
    [F,A,P,nfpts] = super_validatespecs(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef

