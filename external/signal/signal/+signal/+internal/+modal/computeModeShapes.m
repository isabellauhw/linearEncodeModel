function ms = computeModeShapes(Res,di)
%COMPUTEMODESHAPES Compute mode shape vectors, scaled to unity modal A.
%   This function is for internal use only. It may be removed. 

%   Copyright 2016-2017 The MathWorks, Inc.

if size(Res,2) >= size(Res,3)
  % Compute mode shapes from columns of FRF matrix
  Res = permute(Res,[2 1 3]);
  ms = Res(:,:,di(2));
  sc = sqrt(Res(di(1),:,di(2)));
  sc(sc==0) = 1; % do not scale if a mode is missing at drive index 
  sc = repmat(sc,size(Res,1),1);
  ms = ms./sc; 
else
  % Compute mode shapes from rows of FRF matrix
  Res = permute(Res,[3 1 2]);
  ms = Res(:,:,di(1));
  sc = sqrt(Res(di(2),:,di(1)));
  sc(sc==0) = 1; % do not scale if a mode is missing at drive index 
  sc = repmat(sc,size(Res,1),1);
  ms = ms./sc; 
end
