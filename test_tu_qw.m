%test function tu_qw.m
%loading data
clear
load('rotationData.mat');
load('noiseParameters_10_12_1min.mat');
load('initData.mat');
rotationData = initData;
% parameters
n = 4;
K = length(rotationData.t);
%find the first non-NAN time instant of a data
k_start = findFirstNonNaN(rotationData);
%prior
x0 = rotationData.orient(:,k_start);
P0 = eye(n);
t_kmin1 = rotationData.t(k_start);%start predict here
%start prediction
counter = 1;
for k=k_start+1:K
    if(isDataNaN(rotationData,k))
        continue
    else
        t_k = rotationData.t(k);
        T = t_k - t_kmin1;
        %prediction useing gyroscope measurement at t_kmin1
        Rw = (0.5*Sq(x0)) * noiseParameters.gyrCov*(0.5*Sq(x0))';
        [xPredict(:,counter),PPredict(:,:,counter)] = ...
            tu_qw(x0,P0,rotationData.gyr(:,k),T,Rw);
        x0 = xPredict(:,counter);
        P0 = PPredict(:,:,counter);
        counter = counter + 1;
        t_kmin1 = t_k;
    end
end
%display result
figure(1)
%reference orient
refOrient = removeNaN(rotationData.orient);
for i = 1:4
    subplot(4,1,i);hold on;
    plot(xPredict(i,:))
    plot(refOrient(i,:))
    legend('prediction','ref')
end