function [X,E,obj,err,iter,errArr,iterArr] = lrtcR_tnn(M,omega,lambda,opts)

% Solve the Noisy Low-Rank Tensor Completion (LRTC) problem by ADMM
%
% min_{X,E} ||X||_*+lambda*loss(E), s.t. P_Omega(X) + E = M.
% loss(E) = ||E||_1 or 0.5*||E||_F^2
%
% ---------------------------------------------
% Input:
%       M       -    d1*d2*d3 tensor
%       omega   -    index of the observed entries
%       lambda  -    >=0, parameter
%       opts    -    Structure value in Matlab. The fields are
%           opts.loss       -   'l1' (default): loss(E) = ||E||_1 
%                               'l2': loss(E) = 0.5*||E||_F^2
%           opts.tol        -   termination tolerance
%           opts.max_iter   -   maximum number of iterations
%           opts.mu         -   stepsize for dual variable updating in ADMM
%           opts.max_mu     -   maximum stepsize
%           opts.rho        -   rho>=1, ratio used to increase mu
%           opts.DEBUG      -   0 or 1
%
% Output:
%       X       -    d1*d2*d3 tensor
%       E       -    d1*d2*d3 tensor
%       obj     -    objective function value
%       err     -    residual
%       iter    -    number of iterations
%
% version 1.0 - 27/06/2016
%
% Written by Canyi Lu (canyilu@gmail.com)
% 

tol = 1e-8; 
max_iter = 500;
rho = 1.1;
mu = 1e-4;
max_mu = 1e10;
DEBUG = 0;
loss = 'l1';

if ~exist('opts', 'var')
    opts = [];
end    
if isfield(opts, 'loss');        loss = opts.loss;            end
if isfield(opts, 'max_iter');    max_iter = opts.max_iter;    end
if isfield(opts, 'rho');         rho = opts.rho;              end
if isfield(opts, 'mu');          mu = opts.mu;                end
if isfield(opts, 'max_mu');      max_mu = opts.max_mu;        end
if isfield(opts, 'DEBUG');       DEBUG = opts.DEBUG;          end


dim = size(M);
X = zeros(dim);
Z = X;
E = X;
Y1 = X;
Y2 = X;
omegac = setdiff(1:prod(dim),omega);
errArr = [];
iterArr = [];

iter = 0;
for iter = 1 : max_iter
    Xk = X;
    Zk = Z;
    Ek = E;
    % first super block {X,E}
    [X,tnnX] = prox_tnn(Z-Y2/mu,1/mu);
    temp = M-Y1/mu;
    temp(omega) = temp(omega)-Z(omega);
    if strcmp(loss,'l1')
        E = prox_l1(temp,lambda/mu);
    elseif strcmp(loss,'l2')
        E = temp*(mu/(lambda+mu));
    else
        error('not supported loss function');
    end
    
    % second super block {Z}
    Z(omega) = (-E(omega)+M(omega)-(Y1(omega)-Y2(omega))/mu+X(omega))/2;
    Z(omegac) = X(omegac)+Y2(omegac)/mu;
    
    dY1 = E-M;
    dY1(omega) = dY1(omega)+Z(omega);
    dY2 = X-Z;   
    chgX = max(abs(Xk(:)-X(:)));
    chgE = max(abs(Ek(:)-E(:)));
    chgZ = max(abs(Zk(:)-Z(:)));
    chg = max([chgX chgE chgZ max(abs(dY1(:))) max(abs(dY2(:)))]);
    if DEBUG
        if iter == 1 || mod(iter, 10) == 0
            obj = tnnX+lambda*comp_loss(E,loss);
            err = sqrt(norm(dY1(:))^2+norm(dY2(:))^2);
            disp(['iter ' num2str(iter) ', mu=' num2str(mu) ...
                    ', obj=' num2str(obj) ', err=' num2str(err)]); 
            errArr = [errArr, err];
            iterArr = [iterArr, iter];
        end
    end
    
    if chg < tol
        break;
    end 
    Y1 = Y1 + mu*dY1;
    Y2 = Y2 + mu*dY2;
    mu = min(rho*mu,max_mu);    
end
obj = tnnX+lambda*comp_loss(E,loss);
err = sqrt(norm(dY1(:))^2+norm(dY2(:))^2);