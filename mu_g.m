function [x, P] = mu_g(x, P, yacc, Ra, g0)
%   yacc: measurement
%   Ra: measurement noise conv
H = Qq(x)';
[Q0, Q1, Q2, Q3] = dQqdq(x);
H_J = [Q0'*g0, Q1'*g0, Q2'*g0, Q3'*g0];

S = H_J*P*H_J' + Ra;
K = P*H_J'*S^-1;
x = x + K*(yacc - H*g0);
P = P - K*S*K';

[x, P] = mu_normalizeQ(x, P);   %normalize    
%% for simple motion model


end