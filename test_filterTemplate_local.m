close all
[xhat, meas] = filterTemplate_testing_local();
figure(2)
%reference orient
refOrient = meas.orient;
for i = 1:4
    subplot(4,1,i);hold on;
    plot(xhat.t,xhat.x(i,:),'b')
    sigma = sqrt(xhat.P(i,i,:));
    plot(xhat.t,xhat.x(i,:) + 3 * sigma(:)','r-.')
    plot(xhat.t,xhat.x(i,:) - 3 * sigma(:)','r-.')
    plot(xhat.t,refOrient(i,:),'k')
end