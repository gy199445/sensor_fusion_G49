%test function tu_qw.m
%loading data
clear
load('rotationData.mat');
load('noiseParameters_with_g0.mat');
load('initData.mat');
rotationData = initData;
% parameters
n = 4;
%remove NaN
rotationData_clean = removeNaN(rotationData);
K = length(rotationData_clean.t);
x0 = rotationData_clean.orient(:,1);
P0 = eye(n);
for k=1:K-1
    %prediction useing gyroscope measurement
    Rw = (0.5*Sq(x0)) * noiseParameters.gyrCov*(0.5*Sq(x0))';
    T = rotationData_clean.t(k+1) - rotationData_clean.t(k);
    [xPredict(:,k),PPredict(:,:,k)] = ...
        tu_qw(x0,P0,rotationData_clean.gyr(:,k),T,Rw);
    x0 = xPredict(:,k);
    P0 = PPredict(:,:,k);
end
%display result
figure(1)
%reference orient
refOrient = rotationData_clean.orient;
for i = 1:4
    subplot(4,1,i);hold on;
    plot(xPredict(i,:))
    plot(refOrient(i,:))
    legend('prediction','ref')
end