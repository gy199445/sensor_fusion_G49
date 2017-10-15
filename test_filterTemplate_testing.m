[xhat, meas] = filterTemplate_testing();
figure(1)
%reference orient
refOrient = meas.orient;
for i = 1:4
    subplot(4,1,i);hold on;
    plot(xhat.t,xhat.x(i,:))
    plot(xhat.t,refOrient(i,:))
    legend('estimation','ref')
end