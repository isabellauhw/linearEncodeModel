function Res = computeResidues(FRF,f,poles,fm)
%COMPUTERESIDUES Compute residues from measured FRFs and estimated poles.
%   This function is for internal use only. It may be removed.

%   Copyright 2016-2017 The MathWorks, Inc.

% Compute the residues, one for each FRF, using a frequency-domain
% least-squares approach with residuals.
Res = nan(size(poles,1)*2+2,size(FRF,2),size(FRF,3),'like',FRF);

om = 2*pi*f;
switch lower(fm)
   case 'pp' % SISO case - each FRF has unique poles
      for j = 1:size(FRF,2)
         for i = 1:size(FRF,3)
            % Form pole matrix P
            ipoles = ~isnan(poles(:,j,i));
            p = [poles(ipoles,j,i); conj(poles(ipoles,j,i))];
            P = [1./(1i*om - p.') ones(size(f)) -1./(om).^2];
            if f(1) < 1e-3
               P(1,end) = P(2,end); %Avoid dividing by zero
            end
            Res([ipoles;ipoles;[true true]'],j,i) = pinv(P)*FRF(:,j,i);
         end
      end
   case {'lsce','lsrf'} % One set of poles for all FRF's
      % Form pole matrix P
      ipoles = ~isnan(poles);
      p = [poles(ipoles); conj(poles(ipoles))];
      P = [1./(1i*om - p.') ones(size(f)) -1./(om).^2];
      if f(1) < 1e-3
         P(1,end) = P(2,end); %Avoid dividing by zero
      end
      for i = 1:size(FRF,3)
         Res([ipoles;ipoles;[true true]'],:,i) = pinv(P)*FRF(:,:,i);
      end
end

% Reduce the residues to the set corresponding to poles.
Res = Res(1:size(poles,1),:,:);
