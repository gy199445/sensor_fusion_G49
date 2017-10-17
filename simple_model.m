function [x, P] = simple_model(x, P, T, Rq)

A = eye(4);
% F = A*T + eye(1);

x = A*x;
%G = (A*T + eye(1))*T;
P = A*P*A' + Rq;

[x, P] = mu_normalizeQ(x, P);   %normalize
end