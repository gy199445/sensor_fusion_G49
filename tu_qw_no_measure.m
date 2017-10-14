function [x, P] = tu_qw_no_measure(x, P, omega, T, Rw)
% omega : all omega
Sw = Somega (omega(:,size(omega, 2)));
Gq = Sq(x);
F = 0.5*Sw*T + 1;
G = 0.5*Gq*T;

x = F*x;
P = F*P*F' + G*Rw;
end