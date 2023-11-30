%
% References:
%
% C. Lu. A Library of ADMM for Sparse and Low-rank Optimization. National University of Singapore, June 2016.
% https://github.com/canyilu/LibADMM.
% C. Lu, J. Feng, S. Yan, Z. Lin. A Unified Alternating Direction Method of Multipliers by Majorization 
% Minimization. IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 40, pp. 527-541, 2018
%

% 1: Tensor RRPCA based on sum of nuclear norm minimization (rpca_snn)

% 2: low-rank tensor completion based on sum of nuclear norm minimization (lrtc_snn) 


% 3: regularized low-rank tensor completion based on sum of nuclear norm minimization (lrtcR_snn)

 
% 4: Tensor RRPCA based on tensor nuclear norm minimization (rpca_tnn)


% 5: low-rank tensor completion based on tensor nuclear norm minimization (lrtc_tnn)

% 6: regularized low-rank tensor completion based on tensor nuclear norm minimization (lrtcR_tnn) 

 
% 7: low-rank tensor recovery from Gaussian measurements based on tensor nuclear norm minimization (lrtr_Gaussian_tnn)
% n1 = 30;
% n2 = n1; 
% n3 = 5;
% r = 0.2*n1; % tubal rank
% X = tprod(randn(n1,r,n3),randn(r,n2,n3)); % size: n1*n2*n3
% 
% m = 3*r*(n1+n2-r)*n3+1; % number of measurements
% n = n1*n2*n3;
% A = randn(m,n)/sqrt(m);
% 
% b = A*X(:);
% Xsize.n1 = n1;
% Xsize.n2 = n2;
% Xsize.n3 = n3;
% 
% opts.DEBUG = 1;
% [Xhat,obj,err,iter]  = lrtr_Gaussian_tnn(A,b,Xsize,opts);
% 
% RSE = norm(Xhat(:)-X(:))/norm(X(:))
% trank = tubalrank(Xhat)

