load('task11_q2eular.mat');
estEuler = q2euler(xhatCropped.x);
refEuler = q2euler(measCropped.orient);
figure(1)
for i =1:3
    subplot(3,1,i);hold on;
    plot(measCropped.t,estEuler(i,:))
    plot(measCropped.t,refEuler(i,:))
    ylabel('rad')
    if(i==1)
        title('gyr+acc+mag with outlier detection')
        legend('est','ref')
    end
    if(i==3)
        xlabel('t/s')
    end
end