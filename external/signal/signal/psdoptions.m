function [options1,msg,msgobj] = psdoptions(isreal_x,options,varargin)
%PSDOPTIONS   Parse the optional inputs to most psd related functions.
%
%  Inputs:
%   isreal_x             - flag indicating if the signal is real or complex
%   options              - the same structure that will be returned with the
%                          fields set to the default values
%   varargin             - optional input arguments to the calling function
%
%  Outputs:
%  PSDOPTIONS returns a structure, OPTIONS, with following fields:
%   options.nfft         - number of freq. points at which the psd is estimated
%   options.Fs           - sampling freq. if any
%   options.range        - 'onesided' or 'twosided'
%   options.centerdc     - true if 'centered' specified
%   options.conflevel    - confidence level between 0 and 1 ('omitted' when unspecified)
%   options.ConfInt      - this field only exists when called by PMTM 
%   options.MTMethod     - this field only exists when called by PMTM
%   options.NW           - this field only exists when called by PMUSIC (see PMUSIC for explanation)
%   options.Noverlap     - this field only exists when called by PMUSIC (see PMUSIC for explanation)
%   options.CorrFlag     - this field only exists when called by PMUSIC (see PMUSIC for explanation)
%   options.EVFlag       - this field only exists when called by PMUSIC (see PMUSIC for explanation)
%   options.isNFFTSingle - true if nfft is single precision. This field only exists when called by
%                          WELCHPARSE   
%#codegen

%  Copyright 1988-2019 The MathWorks, Inc.

inputArgs = cell(size(varargin));

if nargin > 2
    [inputArgs{:}] = convertStringsToChars(varargin{:});
else
    inputArgs = varargin;
end

options.centerdc = false;
noverlapFlag = true;
visitedOpts = zeros(1,16);
index = 1;

% Lower case, no punctuation:
strOpts = {'half','onesided','whole','twosided', ...
           'adapt','unity','eigen', ...
           'corr', 'ev', ...
           'centered','power','psd','ms','reassigned','confidencelevel',...
           'mean','maxhold','minhold','mimo'};

% Check for mutually exclusive options
exclusiveOpts = {strOpts{1} strOpts{3}; strOpts{2} strOpts{4}; strOpts{5} strOpts{6}; ...
                 strOpts{5} strOpts{7}; strOpts{6} strOpts{7}; strOpts{1} strOpts{10};...
                 strOpts{2} strOpts{10}};
             
             
for i=1:size(exclusiveOpts,1)
    if any(strcmpi(exclusiveOpts{i,1},inputArgs)) && ...
         any(strcmpi(exclusiveOpts{i,2},inputArgs))
     [msg,msgobj] = ConstructErrorObj('signal:psdoptions:ConflictingOptions',exclusiveOpts{i,1}, exclusiveOpts{i,2});
     options1 = options;

     return
   end
end

if numel(inputArgs)<1
    options1 = options;
    msg = '';
    msgobj = [];
    return; 
end

confLevelFlag = false;
numReals = 0;
ExclusiveMsgStr = 'signal:psdoptions:MultipleValues';

for argnum=1:numel(inputArgs)
    if confLevelFlag
        confLevelFlag = false;
        continue;
    end
    
    arg1 = inputArgs{argnum};
    
   isStr     = ischar(arg1);
   isRealVector = isnumeric(arg1) && ~issparse(arg1) && isreal(arg1) && any(size(arg1)<=1);
   isValid   = isStr || isRealVector;
   
   if ~isValid
      [msg,msgobj] = ConstructErrorObj('signal:psdoptions:NeedValidOptionsType');
      options1 = options;
      return;
   end
   
   
   if isStr
      % String option
      % Convert to lowercase and remove special chars:
      arg2 = RemoveSpecialChar(arg1);
      arg = validatestring(arg2,strOpts,'psdoptions');
      
      % Match option set:
      i = find(strcmp(arg, strOpts));
      if length(i)>1
          [msg,msgobj] = ConstructErrorObj('signal:psdoptions:UnknStringOption');
          options1 = options;
          return
      end
      
       switch i
           case {1,2,3,4}
               [err,visitedOpts,index] = checkUniqueOpts(visitedOpts,i,index);
               if err
                    [msg,msgobj] = ConstructErrorObj(ExclusiveMsgStr);
                    options1 = options;
                    return
               end
               
               if isfield(options,'range')
                   % Map half to one-sided (index 1 -> index 2)
                   % Map whole to two-sided (index 3 -> index 4)
                   if i==1 | i==2
                       options.range = 'onesided';
                   else
                       options.range = 'twosided';
                   end
                   if ~isreal_x & strcmpi(options.range,'onesided') %#ok<AND2>
                       [msg,msgobj] = ConstructErrorObj('signal:psdoptions:ComplexInputDoesNotHaveOnesidedPSD');
                       options1 = options;
                       return
                   end
               end
           case {5,6,7}
               % Only PMTM has the field options.MTMethod
               if ~isfield(options,'MTMethod')
                   [msg,msgobj] = ConstructErrorObj('signal:psdoptions:UnrecognizedString');
                   options1 = options;
                   return
               else
                   [err,visitedOpts,index] = checkUniqueOpts(visitedOpts,i,index);
                   if err
                       [msg,msgobj] = ConstructErrorObj(ExclusiveMsgStr);
                       options1 = options;
                       return
                   end
                   options.MTMethod = strOpts{i};
               end
           case 8
               % Only PMUSIC has the field options.CorrFlag
               if ~isfield(options,'CorrFlag')
                   % A string particular to pmusic is not supported here
                   [msg,msgobj] = ConstructErrorObj('signal:psdoptions:UnrecognizedString');
                   options1 = options;
                   return
               else
                   [err,visitedOpts,index] = checkUniqueOpts(visitedOpts,i,index);
                   if err
                       [msg,msgobj] = ConstructErrorObj(ExclusiveMsgStr);
                       options1 = options;
                       return
                   end
                   options.CorrFlag = 1;
               end
           case 9
               if ~isfield(options,'EVFlag')
                   % A string particular to pmusic is not supported here
                   [msg,msgobj] = ConstructErrorObj('signal:psdoptions:UnrecognizedString');
                   options1 = options;
                   return
               else
                   [err,visitedOpts,index] = checkUniqueOpts(visitedOpts,i,index);
                   if err
                       [msg,msgobj] = ConstructErrorObj(ExclusiveMsgStr);
                       options1 = options;
                       return
                   end
                   options.EVFlag = 1;
               end
           case 10
               [err,visitedOpts,index] = checkUniqueOpts(visitedOpts,i,index);
               if err
                    [msg,msgobj] = ConstructErrorObj(ExclusiveMsgStr);
                    options1 = options;
                    return
               end
               options.centerdc = true;
           case {11,12,13,14,16,17,18,19}
                % These options correspond to esttype, reassigned flag and
                % trace which have been parsed earlier. Do Nothing
               
           case 15
               [err,visitedOpts,index] = checkUniqueOpts(visitedOpts,i,index);
               if err
                    [msg,msgobj] = ConstructErrorObj(ExclusiveMsgStr);
                    options1 = options;
                    return
               end
               
               if argnum == numel(inputArgs)
                   [msg,msgobj] = ConstructErrorObj('signal:psdoptions:MissingConfLevelValue');
                   options1 = options;
                   return
               end
               confLevel = inputArgs{argnum+1};
               if ~ischar(confLevel) && ~isempty(confLevel) && isfield(options,'conflevel')
                   %conflevel will never be a character, adding guard for coder type inference
                   if isscalar(confLevel) && isreal(confLevel) && 0<confLevel && confLevel<1 
                       options.conflevel = confLevel;
                   else
                       [msg,msgobj] = ConstructErrorObj('signal:psdoptions:InvalidConfLevelValue');
                       options1 = options;
                       return
                   end
               end
               confLevelFlag = true;
           otherwise
               [msg,msgobj] = ConstructErrorObj('signal:psdoptions:IdxOutOfBound');
               options1 = options;
               return
       end
    
   else
       arg = arg1;
       numReals = numReals + 1;
       switch numReals
           case 1
               if isfield(options,'nfft')
                   if ~isempty(arg)
                    arg2 = reshapeInputArg(arg,size(options.nfft));
                    options.nfft = cast(arg2,'double');
                    if isfield(options,'isNFFTSingle')
                        options.isNFFTSingle = isa(arg2,'single');
                    end
                   end
               end
           case 2
               if length(arg1) >1
                   [msg,msgobj] = ConstructErrorObj('signal:psdoptions:FsMustBeScalar');
                   options1 = options;
                   return
               end
               if isfield(options,'Fs')
                   if length(arg)<=1
                       if isempty(arg)
                           options.Fs = 1;  % If Fs specified as [], use 1 Hz as default
                       else
                           arg2 = reshapeInputArg(arg,size(options.Fs));
                           validateattributes(arg2,{'numeric'},{'scalar','positive'},'psdoptions','fs');
                           % Cast to enforce precision rules
                           options.Fs = double(arg2(1));
                       end
                   end
               end
           case 3
               if isfield(options,'Fs')
                   if ~isempty(arg)
                       if isfield(options,'ConfInt')
                           % Only PMTM has the field options.ConfInt;
                           arg2 = reshapeInputArg(arg,size(options.ConfInt));
                           options.ConfInt = arg2;
                       elseif isfield(options,'nw')
                           % Only PMUSIC has the field options.nw;
                           arg2 = reshapeInputArg(arg,size(options.nw));
                           nw = arg2;
                           options.nw= nw;
                           if ~any(size(nw)==1)
                               [msg,msgobj] = ConstructErrorObj('signal:psdoptions:MustBeScalarOrVector','NW');
                               options1 = options;
                               return
                           elseif length(nw) > 1
                               options.window = nw;
                               options.nw = length(nw);
                           end
                       else
                            [msg,msgobj] = ConstructErrorObj('signal:psdoptions:TooManyNumericOptions');
                            options1 = options;
                            return
                       end
                   end
               end
           case 4
               % Only PMUSIC has the field options.noverlap; 
               if isfield(options,'noverlap')
                   if length(arg)<=1
                       if ~isempty(arg)
                           arg2 = reshapeInputArg(arg,size(options.noverlap));
                           options.noverlap = arg2;
                           noverlapFlag = false;
                       end
                   else
                      [msg,msgobj] = ConstructErrorObj('signal:psdoptions:OverlapMustBeScalar');
                      options1 = options;
                       return
                   end   
               end
    
           otherwise
               [msg,msgobj] = ConstructErrorObj('signal:psdoptions:TooManyNumericOptions');
               options1 = options;
               return
       end
       
   end
    
end

if noverlapFlag && isfield(options,'noverlap') && isfield(options,'nw')
    options.noverlap = options.nw - 1;
end


if isfield(options,'nfft') && isfield(options,'centerdc')
    nfft = options.nfft;
    centerdc = options.centerdc;
    if  centerdc && isnumeric(nfft) && numel(nfft)>1
        [msg,msgobj] = ConstructErrorObj('signal:psdoptions:CannotCenterFrequencyVector');
        options1 = options;
        return
    end
end

options1 = options;
msg = '';
msgobj = [];

end

%--------------------------------------------------------------------------------
function y=RemoveSpecialChar(x)
% RemoveSpecialChar
%   Remove one space of hyphen from 4th position, but
%   only if first 3 chars are 'one' or 'two'

y1 = lower(x);

% If string is less than 4 chars, do nothing:
if length(y1)<=3
    y=y1;
    return; 
end

% If first 3 chars are not 'one' or 'two', do nothing:
if ~strncmp(y1,'one',3) && ~strncmp(y1,'two',3)
    y=y1;
    return; 
end

% If 4th char is space or hyphen, remove it
if y1(4)==' ' || y1(4) == '-'
    y= [y1(1:3) y1(5:end)];
else
    y = y1;
end

end

%--------------------------------------------------------------------------------

function [msg,msgobj] = ConstructErrorObj(varargin)

if coder.target('MATLAB')
    msgobj = message(varargin{:});
    msg = getString(msgobj);
else
    msgobj = [];
    msg = '';
    coder.internal.error(varargin{:});
    return
end

end

%--------------------------------------------------------------------------------

function arg1 = reshapeInputArg(arg,siz)

if ~coder.target('MATLAB') && all(siz)
    arg1 = reshape(arg,siz);
else
    arg1 = arg;
end

end

%--------------------------------------------------------------------------------

function [err,visitedOpts,index] = checkUniqueOpts(visitedOpts,arg,index)
% Verify that no other options from (exclusive) set have
% already been parsed:

%visitedOpts : array containing indices of arguments in strOpts cellarray which we already parsed
%arg: index of current argument being parsed in strOpts
%index: current index of visitedOpts

if ismember(arg,visitedOpts)
    % if the argument has already been parsed, error out
    err = true;
else
    % push the arg into visitedOpts
    if arg == 1 | arg == 2 | arg == 3 | arg == 4
        % handling a special case for {'half','onesided','whole','twosided'}
        % When any of these is encountered, push all these into visitedOpts
        % since these all correspond to Range parameter
        arg1 = 1;
        for j = index:index+3
            visitedOpts(j)= arg1;
            arg1 = arg1 + 1;
        end
        index = index +3;
    elseif arg == 5 | arg == 6 | arg == 7 %#ok<*OR2>
        % handling a special case for {'adapt','unity','eigen'}
        % When any of these is encountered, push all these into visitedOpts
        % since these all correspond to MTMethod parameter
        arg1 = 5;
        for j = index:index+2
            visitedOpts(j)= arg1;
            arg1 = arg1 + 1;
        end
        index = index +2;
    else
        visitedOpts(index) = arg;
        index = index+1;
    end
    err = false;
end
end

% LocalWords:  nfft Fs conflevel Noverlap eigen ev confidencelevel maxhold
% LocalWords:  minhold mimo Unkn esttype fs nw noverlap th
