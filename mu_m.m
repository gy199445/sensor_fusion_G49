function [x, P] = mu_m(x, P, mag, m0, Rm)
H = Qq(x);
[Q0, Q1, Q2, Q3] = dQqdq(q);
H_J = [Q0*m0, Q1*m0, Q2*m0, Q3*m0];

S = H_J*P*H_J' + Rm;
K = P*H_J'*S^-1;
x = x + K*(mag - H*m0);
P = P - K*S*K';

[x, P] = mu_normalizeQ(x, P);   %normalize 
end