function [x, P] = tu_qw(x, P, omega, T, Rw)
%   x:prior
%   P:prior conv
%   omega: angular speed measurement
%   T:sample time
%   Rw:process noise

Sw = Somega (omega);
Gq = Sq(x);
F = 0.5*Sw*T + eye(4);
G = 0.5*Gq*T;

x = F*x;
P = F*P*F' + G*Rw*G';

[x, P] = mu_normalizeQ(x, P);   %normalize
end