%test filterTemplate_testing_network.m
% mode: 1:gyr+acc;2:gyr+mag(m0 fixed);3:gyr+acc+mag(m0 fixed);4:gyr only
% tuningFactor 3*1, will be multiplied by Rw,Ra,Rm
mode = 3;
tuningFactor = [1 1 1]';
[xhat,meas] = filterTemplate_network(mode,tuningFactor);
refOrient = meas.orient;
close all
for i = 1:4
    subplot(4,1,i);hold on;
    plot(xhat.t,xhat.x(i,:),'b')
    ylabel(sprintf('q_%d',i-1))
    sigma = sqrt(xhat.P(i,i,:));
    %plot(xhat.t,xhat.x(i,:) + 3 * sigma(:)','r-.')
    %plot(xhat.t,xhat.x(i,:) - 3 * sigma(:)','r-.')
    plot(xhat.t,refOrient(i,:),'k')
    if i == 4
        xlabel('t/s')
        legend('est.','ref.')
    end
end
T = length(meas.t);
m0 = zeros(3,T);
for i=1:T
    m0(:,i) = [0 sqrt(meas.mag(1,i)^2+meas.mag(2,i)^2) meas.mag(3,i)]';
end
figure(3)
for i=1:3
    subplot(3,1,i);hold on;
    plot(xhat.t,m0(i,:),'b')
end
%magnetic outlier detection test
for i = 1:T
    normMagDiff(i) = abs(norm(meas.mag(:,i)-noiseParameters.m0));
end
figure(4)
plot(normMagDiff)
title('normMagDiff')
figure(5)
plot(meas.Lk)
title('Lk')