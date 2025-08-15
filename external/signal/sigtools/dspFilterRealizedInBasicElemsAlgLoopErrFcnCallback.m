function newException = dspFilterRealizedInBasicElemsAlgLoopErrFcnCallback(blockHandle, errorID, originalException)
%dspFilterRealizedInBasicElemsAlgLoopErrFcnCallback - used by REALIZEMDL
%             to replace the (more confusing) algebraic loop error which
%             can result from algebraic loop presence in recursive filters
%             realized using basic elements when the input signal is frame-
%             based.  This function should be used as the ErrorFcn callback
%             for a subsystem realized using basic elements via REALIZEMDL.

%   Copyright 1995-2014 The MathWorks, Inc.

switch (errorID)
  case {'Simulink:Engine:BlkInAlgLoopErrWithInfo','Simulink:Engine:AlgLoopTrouble'}
    msg = message('signal:sigtools:SampleBasedIORequiredforRecursiveFilterSubsystem');
    newException = MSLException(blockHandle, msg);
  otherwise
    newException = originalException;
end

end % function
