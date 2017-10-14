function [x, P] = tu_qw_no_measure(x, P, omega, T, Rw)
% omega : all omega
Sw = Somega (omega);
Gq = Sq(x);
F = 0.5*Sw*T + eye(4);
G = 0.5*Gq*T;

x = F*x;
P = F*P*F' + G*Rw*G';
[x, P] = mu_normalizeQ(x, P);   %normalize
end