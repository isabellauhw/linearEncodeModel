function fo= preprocessCAP(f)
% PREPROCESSCAP - Preprocess the dfilt coupled allpass for sysobj conversion
%   The dfilt structure that implements a coupled allpass filter can have
%   several levels of hierarchy (dfilt.cascade, dfilt.cascadeallpass, etc)
%   and some delays implemented as dfilt.allpass(0). This function 
%   flattens all the cascades and folds them into single
%   dfilt.cascadeallpass or dfilt.cascadewdfallpass as much as possible. It
%   converts dfilt.allpass(0) and dfilt.delay(1) to the appropriate allpass
%   structure (dfilt.allpass(0) or dfilt.wdfallpass(0)) before cascading.
%       f is the original dfilt structure
%       fo is the processed dfilt structure.
%

%   Copyright 2016 The MathWorks, Inc.


    %Flatten cascades and convert dfilt.allpass(0) to dfilt.delay(1);
    fflat = flattenCascades(f);

    % If fflat is non scalar it started out as a cascade (and we flattened
    % it). Repackage it as a cascade.
    if numel(fflat) > 1 %it was a cascade and needs repackaging
        fflat = cascade(fflat{:});
    end

    % Figure out if we are using WDF or Min Mult allpasses and convert all
    % dfilt.delay(1) to an allpass structure.
    if isWDF(fflat)
        fo = convertDelays(fflat, dfilt.wdfallpass(0));
    else
        fo = convertDelays(fflat, dfilt.allpass(0));
    end

    %Combine all dfilt.allpass to dfilt.cascadeallpass or 
    %dfilt.wdfallpass to dfilt.cascadewdfallpass.
    fo =combineAllpasses(fo);
end

function fo = convertDelays(f, rep)
%CONVERTDELAYS - convert delays to filters
%   rep is a dfilt.allpass(0) or dfilt.wdfallpass(0)
%   Put rep in place of any dfilt.delay(1)
%
    switch(class(f))
        case {'dfilt.parallel', 'dfilt.cascade'}
            fo = f;
            for ii=1:numel(f.Stage)
                fo.Stage(ii) = convertDelays(f.Stage(ii), rep);
            end
        case 'dfilt.delay'
            if f.Latency == 1
                fo = copy(rep);
            else
                fo = f;
            end
        otherwise
            fo = f;
    end 
end

function tf = isWDF(f)
% Traverse the hierarchy and see if there are any WDF filters.
% tf = true for a WDF style filter, false for Min Mult. If we find at least
% one WDF along the way, declare the whole thing WDF.
% f is input filter
    tf = false;
    switch(class(f))
        case {'dfilt.parallel', 'dfilt.cascade'}
            for ii=1:numel(f.Stage)
                tf = tf | isWDF(f.Stage(ii));
            end
        case 'dfilt.wdfallpass'
            tf = true;
        otherwise
            tf = false;
    end
end

function fo = combineAllpassesOnCascade(f)
% Find strings of allpasses and combine them into
% dfilt.cascade(wdf)allpass.  dfilt.parallel structures are early endpoints
% in the combining - we don't combine across dfilt.parallel structures.
% dfilt.parallel in between two allpasses should not come up from an
% fdesign produced filter and would not result in a coupled allpass design.
% 

    ap = {};    %allpasses we've found
    other = {}; %other filters we've found
    numStages = numel(f.Stage);
    for ii=1:numStages
        stg = f.Stage(ii);
        switch class(stg)
            case {'dfilt.allpass', 'dfilt.wdfallpass'}
                ap{end+1} = stg;
            case 'dfilt.parallel'
                newstg = {};
                for jj = 1:numel(stg.Stage)
                    newstg{jj} = combineAllpasses(stg.Stage(jj));
                end
                other{end+1} = dfilt.parallel(newstg{:});
                
                %dfilt.parallel is an early endpoint to the combining. So
                %we shoudl break. But we still need to combine everything
                %after it. That combination would be considered an "other"
                %at this level of recursion.
                if ii < numStages %any stages left?
                    if ii == numStages -1
                        other{end+1} = f.Stage(numStages); %no combining.
                    else
                        other{end+1} = combineAllpassesOnCascade( ...
                            cascade(f.Stage((ii+1):numStages)));
                    end
                end
                break;
            otherwise
                other{end+1} = stg;
        end
    end

    %All strings of (wdf)allpass have been found. Convert them to
    %cascade(wdf)allpass.

    ccoeff = arrayfun(@(x)x.AllpassCoefficients, [ap{:}], 'UniformOutput', false);
    
    nap = numel(ap);
    noth = numel(other);
    if nap == 1 && noth == 0
        fo = ap{1};
    elseif noth ==1 && nap == 0
        fo = other{1};
    elseif nap > 0
        if isa(ap{1}, 'dfilt.wdfallpass') %if the first is WDF, they are all WDF.
            fo = cascade( other{:}, dfilt.cascadewdfallpass(ccoeff{:}));
        else
            fo = cascade( other{:}, dfilt.cascadeallpass(ccoeff{:}));
        end
    else
        %There were no allpasses. Just cascade the other filters
        fo = cascade(other{:});
    end

end

function fo = combineAllpasses(f)
%Traverse the heirarchy trying to combine allpass filters.
    switch class(f)
        case 'dfilt.cascade'
            fo = combineAllpassesOnCascade(f);
            if numel(fo.Stage) == 1
                fo = fo.Stage; %no cascades of single stages 
            end
        case 'dfilt.parallel'
            %Go into each branch and combine allpasses. Put back together
            %as a new dfilt.parallel (if there is more than 1 branch).
            sout = {};
            for ii=1:numel(f.Stage)
                sout{ii} = combineAllpasses(f.Stage(ii));
            end
            if numel(sout) > 1
                fo = dfilt.parallel(sout{:});
            else
                fo = sout{1};
            end
        otherwise
            fo =f;
            
    end            
end

function cellfilt = flattenCascades(f)
% Find all cascades and flatten them so we can combine allpasses more
% easily. cellfilt is a cell array of all the filters in each cascade.
     cellfilt = {};
      switch class(f)
        case 'dfilt.cascade'
            parts = {};
            ss = f.Stage;
            for ii=1:numel(ss)
               v = flattenCascades(ss(ii)); 
               parts = vertcat(parts, v);
            end
            cellfilt = parts;
        case 'dfilt.parallel'
            fo = foreachstage(f, @flattenCascades);
            cellfilt = {fo};
        case 'dfilt.cascadeallpass'
            %Convert to a cell array of dfilt.allpasses
            co = f.AllpassCoefficients;
            sout = structfun(@(x)dfilt.allpass(x), co, 'UniformOutput', false);
            cellfilt = struct2cell(sout);
        case 'dfilt.cascadewdfallpass'
            %Convert to a cell array of dfilt.wdfallpasses
            co = f.AllpassCoefficients;
            sout = structfun(@(x)dfilt.wdfallpass(x), co, 'UniformOutput', false);
            cellfilt = struct2cell(sout);
        case 'dfilt.allpass'
            %Sometimes dfilt.allpass(0) sneaks in. Replace with a delay.
            if isscalar(f.AllpassCoefficients) && (f.AllpassCoefficients == 0)
                cellfilt = {dfilt.delay};
            else
                cellfilt{1} = f;
            end
            
        otherwise
            %nothing. leave the filter unchanged
            cellfilt{1} = f;
      end
    
      
end

function fo = foreachstage(f, fh)
%Apply a function handle fh to each stage
    ss = f.Stage;
    parts = {};
    for ii=1:numel(ss)
        p = fh(ss(ii));
        if numel(p) > 1
            parts{ii} = cascade(p{:});
        else
            parts{ii} = p{1};
        end
    end
    fo = dfilt.parallel(parts{:});
end
