clear all
%analysis the sensor noise
%[~,meas] = filterTemplate();
load('initData.mat')
%remove NAN
% K = size(initData.acc,2);
% n = size(initData.acc,1);
% acc = removeNaN(initData.acc);
% gyr = removeNaN(initData.gyr);
% mag = removeNaN(initData.mag);
% %calculate mean
% accMean = mean(acc,2);
% gyrMean = mean(gyr,2);
% magMean = mean(mag,2);
% %plot hisogram to check the noise
% figure(1)
% for i = 1:n
%     subplot(3,3,1+(i-1)*3);hold on;
%     histogram(acc(i,:),'Normalization','pdf')
%     scatter(accMean(i),0,'ro')
%     title(sprintf('acc_{%d}',i))
%     subplot(3,3,2+(i-1)*3);hold on;
%     histogram(mag(i,:),'Normalization','pdf')
%     scatter(magMean(i),0,'ro')
%     title(sprintf('mag_{%d}',i))
%     subplot(3,3,3+(i-1)*3);hold on;
%     histogram(gyr(i,:),'Normalization','pdf')
%     scatter(gyrMean(i),0,'ro')
%     title(sprintf('gyr_{%d}',i))
% end
% %compute g0
%%
NaNRemovedori = removeNaN(initData.orient);
NaNRemovedacc = removeNaN(initData.acc);
NaNRemovedmag = removeNaN(initData.mag);
NaNRemovedt = removeNaN(initData.t);
counter = length(NaNRemovedt);
%%
for i = 1:counter-30
    g(:,i) = linsolve(transpose(Qq(NaNRemovedori(:,i))),NaNRemovedacc(:,i));
    m(:,i) = linsolve(transpose(Qq(NaNRemovedori(:,i))),NaNRemovedmag(:,i));
end
g0 = mean(g,2);
m0 = mean(m,2);
% noiseParameters = struct('accMean',accMean,'accCov',cov(acc'),...
%     'gyrMean',gyrMean,'gyrCov',cov(gyr'),...
% 'magMean',magMean,'magCov',cov(mag'),'g0',g0);