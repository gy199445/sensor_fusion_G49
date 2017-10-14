function [ xPredict,PPredict ] = tu_qw( xPrior,PPrior,omega,T,Rw )
%TU_QW Summary of this function goes here
%   Detailed explanation goes here
%   measurement model given in equation 4.2 (6)
%   xPrior: 4*1 quaternion (\hat{q}_{k-1})
%   PPrior: 4*4
%   omega:  3*1 angular speed measurement \omega_{k-1}
%   T:      1*1 time difference between omega_k and omega_k-1
%   Rw:     4*4 process noise
A = eye(4) + T*Somega(omega);
xPredict = A*xPrior;
PPredict = A*PPrior*A' + Rw;
[xPredict,PPredict] = mu_normalizeQ(xPredict,PPredict);
end

