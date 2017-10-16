%clear all
%analysis the sensor noise
[~,initData] = filterTemplate();
%load('initData.mat')
%remove NAN
K = size(initData.acc,2);
n = size(initData.acc,1);
acc = removeNaN(initData.acc);
gyr = removeNaN(initData.gyr);
mag = removeNaN(initData.mag);
%calculate mean
accMean = mean(acc,2);
gyrMean = mean(gyr,2);
magMean = mean(mag,2);
%plot hisogram to check the noise
figure(1)
for i = 1:n
    subplot(3,3,1+(i-1)*3);hold on;
    histogram(acc(i,:),'Normalization','pdf')
    scatter(accMean(i),0,'ro')
    title(sprintf('acc_{%d}',i))
    subplot(3,3,2+(i-1)*3);hold on;
    histogram(mag(i,:),'Normalization','pdf')
    scatter(magMean(i),0,'ro')
    title(sprintf('mag_{%d}',i))
    subplot(3,3,3+(i-1)*3);hold on;
    histogram(gyr(i,:),'Normalization','pdf')
    scatter(gyrMean(i),0,'ro')
    title(sprintf('gyr_{%d}',i))
end
%compute g0
NaNRemoved = removeNaN(initData);
T = length(NaNRemoved.t);
for i = 1:T
    g(:,i) = linsolve(transpose(Qq(NaNRemoved.orient(:,i))),NaNRemoved.acc(:,i));
end
g0 = mean(g,2);
%compute m0 (earth magnetic field)
m0 = zeros(3,T);
for i=1:T
    m0(:,i) = [0 sqrt(NaNRemoved.mag(1,i)^2+NaNRemoved.mag(2,i)^2) NaNRemoved.mag(3,i)]';
end
figure(3)
for i=1:3
    subplot(3,1,i);hold on;
    plot(NaNRemoved.t,m0(i,:),'b')
end
m0_averaged = [0;sum(sqrt(NaNRemoved.mag(1,:).^2+NaNRemoved.mag(2,:).^2))/T;sum(NaNRemoved.mag(3,:))/T];
noiseParameters = struct('accMean',accMean,'accCov',cov(acc'),...
    'gyrMean',gyrMean,'gyrCov',cov(gyr'),...
    'magMean',magMean,'magCov',cov(mag'),'g0',g0,...
    'm0',m0_averaged);