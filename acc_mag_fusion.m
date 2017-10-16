function [x, P] = acc_mag_fusion(x, P, acc, mag, g0, m0, Ra, Rm)
H = [Qq(x);Qq(x)];
[Q0, Q1, Q2, Q3] = dQqdq(x);
H_Jacc = [Q0*g0, Q1*g0, Q2*g0, Q3*g0];
H_Jmag = [Q0*m0, Q1*m0, Q2*m0, Q3*m0];
H_J = [H_Jacc;H_Jmag];    %6x4
R = mdiag(Ra, Rm);
y = [acc; mag];

S = H_J*P*H_J' + R;
K = P*H_J'*S^-1;
x = x + K*(y - H*g0);
P = P - K*S*K';

[x, P] = mu_normalizeQ(x, P);   %normalize
end