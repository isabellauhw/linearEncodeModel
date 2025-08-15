function pR=stan_plotFcn_2AFC_CN(B,S,N,CL,CR)
%Parameters must be column vectors, contrast must be row vector

Z = B + S.*CR.^N - S.*CL.^N;
pR = 1./(1+exp(-Z));
end