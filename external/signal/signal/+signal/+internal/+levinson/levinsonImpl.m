function [A,E,K] = levinsonImpl(r,N,cols)
% levinsonImpl is used in the code generation path by callLevinson

%   Copyright 2019-2020 The MathWorks, Inc.

%#codegen
coder.varsize('E');
if N == 0

    E = real(r(1,:).');
    K = zeros(0,length(E),'like',r);
    A = ones(size(E),'like',r);

elseif isscalar(r)

    K = zeros(0,1,'like',r);
    A = ones(1,1,'like',r);
    E = real(r(1).');

else

    k = zeros(N+1,cols,'like', r);
    temp_a = zeros(1,N,'like', r);
    temp_E = zeros(1,cols, 'like', r);
    temp_A = zeros(N,cols,'like', r);
    temp_auf = zeros(1,N,'like', r);

    for i = 1:cols

        temp_r = r(2:N+1,i);
        temp_a(1) = -r(1,i);
        temp_k = -r(1,i);
        k(1,i) = temp_k;
        temp_J = cast(real(r(1,i)),'like',r);

        for l = 1:N
            temp_kprod = zeros(1,1,'like',r);
            for j = 1:l-1
                temp_auf(j) = temp_a(j);
                temp_kprod = temp_kprod + temp_a(j) * temp_r(l-j);
            end
            temp_k =  -(temp_r(l)+temp_kprod)./temp_J;
            temp_J = (1-(temp_k.*conj(temp_k))).*temp_J;
            if isempty(coder.target)
                temp_a(1:l-1) = temp_auf + (temp_k.*conj(flip(temp_auf,2)));
            else
                for idx = 1:l-1
                    temp_a(idx) = temp_auf(idx) + (temp_k.*conj(temp_auf(l-idx)));
                end
            end
            temp_a(l) = temp_k;
            k(l+1,i) = temp_k;
        end

        temp_E(i) = temp_J;
        temp_A(:,i) = temp_a;
    end

    K = k(2:end,:);
    A = [ones(1,cols,'like',temp_a);temp_A(1:end,:)].';
    E = real(temp_E.');
end

