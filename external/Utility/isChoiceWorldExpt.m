function isCW = isChoiceWorldExpt(expRef)
%This function returns true/false for whether the block file for the expRef
%is from an older choiceworld experiment

b = dat.loadBlock(expRef);
if isempty(b)
    isCW = NaN;
else
    isCW = isfield(b,'trial');
end

end
