clear all
%analysis the sensor noise
%[~,meas] = filterTemplate();
load('initData.mat')
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
    subplot(3,3,1+(i-1)*3);
    histogram(acc(i,:)-accMean(i),'Normalization','pdf')
    title(sprintf('acc_{%d}',i))
    subplot(3,3,2+(i-1)*3);
    histogram(mag(i,:)-mag(i),'Normalization','pdf')
    title(sprintf('mag_{%d}',i))
    subplot(3,3,3+(i-1)*3);
    histogram(gyr(i,:)-gyr(i),'Normalization','pdf')
    title(sprintf('gyr_{%d}',i))
end
noiseParameters = struct('accMean',accMean,'accCov',cov(acc'),...
    'gyrMean',gyrMean,'gyrCov',cov(gyr'),...
    'magMean',magMean,'magCov',cov(mag'));