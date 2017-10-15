function [xUpdate, PUpdate] = mu_g(xPredict, PPredict, yacc, Ra, g0)
%   copied from branch xt with modification
%   yacc: measurement
%   Ra: measurement noise conv
H = Qq(xPredict);
[Q0, Q1, Q2, Q3] = dQqdq(xPredict);
H_J = [Q0*g0, Q1*g0, Q2*g0, Q3*g0];
S = H_J*PPredict*H_J' + Ra;
K = PPredict*H_J'*inv(S);
xUpdate = xPredict + K*(yacc - H*g0);
PUpdate = PPredict - K*S*K';
[xUpdate, PUpdate] = mu_normalizeQ(xUpdate, PUpdate);   %normalize                                
end