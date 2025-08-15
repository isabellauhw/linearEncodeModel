function y_out = upfirdn(x,h,varargin)
%MATLAB Code Generation Library Function

% Copyright 2009-2019 The MathWorks, Inc.
%#codegen

% Validate number of I/O args.
narginchk(2,4);

if nargin >= 3
    p = varargin{1};
else
    p = 1;
end

if nargin == 4
    q = varargin{2};
else
    q = 1;
end

% Validate input arguments
validateattributes(x,{'double'},{'nonempty','2d','nonsparse'},'upfirdn','X');
validateattributes(h,{'double'},{'nonempty','2d','nonsparse','finite'},'upfirdn','H');
validateattributes(p,{'double'},{'scalar','nonsparse','finite','real','positive','integer'},'upfirdn','P');
validateattributes(q,{'double'},{'scalar','nonsparse','finite','real','positive','integer'},'upfirdn','Q');

% Force to be a column if input is a vector
if isrow(x) || iscolumn(x)
    xCol = x(:); % columnize it.
else
    xCol = x;
end

% Force to be a column if filter is a vector
if isrow(h) || iscolumn(h)
    hCl = h(:); % columnize it.
else
    hCl = h;
end

[Lx,nChans] = size(xCol);
[Lh,hCols] = size(hCl);

% Determining complex attributes
if ~isreal(x) || ~isreal(h)
    cflg = 1i;
else
    cflg = 1;
end

% Check if x and h are matrices with the same number of columns.
coder.internal.errorIf((nChans > 1) && (hCols > 1) && (hCols ~= nChans),'signal:upfirdn:xNhSizemismatch', 'X', 'H');

% Scalar lockdown
p = p(1);
q = q(1);
Lx = Lx(1);
Lh = Lh(1);
hCols = hCols(1);
nChans = nChans(1);

% Check maximum size for upsample downsample product 
pq = p*q;
coder.internal.errorIf(pq(1) > intmax('int32'),'signal:upfirdn:ProdPNQTooLarge', 'Q', 'P');

% Calculating required output size
Lxup = p*(Lx - 1) + Lh;
if sign(Lxup)
    m = mod(Lxup,q);
else
    m = mod(Lxup,q) - q;
end

if m
    Ly = floor(Lxup/q + 1);
else
    Ly = floor(Lxup/q);
end
Ly = Ly(1);

% Deciding parameter to use for loop iteration
kmax = max(hCols,nChans);
kmax = kmax(1);

% Output size allocation
y = zeros(Ly,kmax,'like',cflg);

% Initializations
i = 1;
j = 1;
accumInit = zeros(1,1,'like',cflg); 

% Loop over either the number of channels or number of columns of the filter
for k = 1:kmax
    inpEnd_idx = Lx+1;
    filtEnd_idx = Lh+1;
    
    for r = 0:p-1
        out_idx = 1+r;
        filt_idx = 1 + mod((r*q),p);
        rpq_offset_idx = floor((r*q)/p);
        inp_idx = 1 + rpq_offset_idx;
        
        % Region 1 (running onto the data):
        filtlo_idx = filt_idx;
        filthi_idx = filt_idx + p*rpq_offset_idx;
        inplo_idx = 1;        
        inphi_idx = inp_idx;
                
        Lg = filtEnd_idx - filt_idx;        
        if mod(Lg,p)
            Lg = floor(Lg/p + 1);
        else
            Lg = floor(Lg/p);
        end
               
        while ((inphi_idx < inpEnd_idx) && (filthi_idx < filtEnd_idx))
            accum = accumInit;
            tmp_inphi_idx = inphi_idx;
            tmp_filtlo_idx = filtlo_idx;
            
            % Convolve input with required filter coefficients
            while (tmp_filtlo_idx <= filthi_idx)
                accum = accum + (hCl(tmp_filtlo_idx,i) * xCol(tmp_inphi_idx,j));
                tmp_inphi_idx = tmp_inphi_idx - 1;
                tmp_filtlo_idx = tmp_filtlo_idx + p;
            end            
            y(out_idx,k) = y(out_idx,k) + accum;
            out_idx = out_idx + p;
            inphi_idx = inphi_idx + q;
            % Increment by p*q
            filthi_idx = filthi_idx + pq;
        end
        
        % Do we need to drain rest of the signal?       
        if (inphi_idx < inpEnd_idx)
            
            % Region 2 (complete overlap):            
            while(filthi_idx >= filtEnd_idx)
                filthi_idx = filthi_idx - p;
            end
            
            while(inphi_idx < inpEnd_idx)
                accum = accumInit;
                tmp_inphi_idx = inphi_idx;
                tmp_filtlo_idx = filtlo_idx;
                
                % Convolve input with required filter coefficients
                while(tmp_filtlo_idx <= filthi_idx)
                    accum = accum + (hCl(tmp_filtlo_idx,i) * xCol(tmp_inphi_idx,j));
                    tmp_inphi_idx = tmp_inphi_idx - 1;
                    tmp_filtlo_idx = tmp_filtlo_idx + p;
                end
                
                % Adjust values for short input signal. Eg: upfirdn(1:2,1,500)
                if (out_idx < Ly+1)
                    y(out_idx,k) = y(out_idx,k) + accum;
                end
                out_idx = out_idx + p;
                inphi_idx = inphi_idx + q;
            end
            
        elseif (filthi_idx < filtEnd_idx)

            % Region 2a (drain out the filter):            
            while (filthi_idx < filtEnd_idx)
                accum = accumInit;
                tmp_inplo_idx = inplo_idx; 
                tmp_filthi_idx = filthi_idx;
                
                % Convolve input with required filter coefficients
                while (tmp_inplo_idx < inpEnd_idx)
                    accum = accum + (hCl(tmp_filthi_idx,i) * xCol(tmp_inplo_idx,j));
                    tmp_inplo_idx = tmp_inplo_idx + 1;
                    tmp_filthi_idx = tmp_filthi_idx - p;
                end                
                y(out_idx,k) = y(out_idx,k) + accum;
                out_idx = out_idx + p;
                inphi_idx = inphi_idx + q;
                % Increment by p*q
                filthi_idx = filthi_idx + pq;
            end
        end
        
        while (filthi_idx >= filtEnd_idx)
            filthi_idx = filthi_idx - p;
        end
        inplo_idx = inphi_idx - Lg + 1;

        while (inplo_idx < inpEnd_idx)
            
            % Region 3 (running off the data):
            accum = accumInit;
            tmp_inplo_idx = inplo_idx;
            tmp_filthi_idx = filthi_idx;
            
            % Convolve input with required filter coefficients
            while(tmp_inplo_idx < inpEnd_idx)
                accum = accum + (hCl(tmp_filthi_idx,i) * xCol(tmp_inplo_idx,j));
                tmp_inplo_idx = tmp_inplo_idx + 1;
                tmp_filthi_idx = tmp_filthi_idx - p;
            end            
            y(out_idx,k) = y(out_idx,k) + accum;
            out_idx = out_idx + p;
            inplo_idx = inplo_idx + q;
        end        
    end
    % End of r loop
    
    % Prepare for next channel: increment i or j.
    if i ~= hCols
        i = i+1;
    end
    
    if j ~= nChans
        j = j+1;
    end
    
end

% Convert output to be a row vector (if x was a row and H is NOT a matrix)
if isrow(x) && hCols == 1
    y_out = y(:).';
else
    y_out = y;
end

end

% LocalWords:  nonsparse columnize Nh Sizemismatch lockdown PNQ seg Eg
