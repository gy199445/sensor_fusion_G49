clear
clc
%%
load('initData.mat')
load('noiseParameters.mat')

meas.acc = initData.acc(:,100:6000);
meas.gyr = initData.gyr(:,100:6000);
meas.mag = initData.mag(:,100:6000);   
meas.acc(:,find(isnan(meas.acc(1,:)))) = meas.acc(:,find(isnan(meas.acc(1,:)))-1);
meas.gyr(:,find(isnan(meas.gyr(1,:)))) = meas.gyr(:,find(isnan(meas.gyr(1,:)))-1);
meas.mag(:,find(isnan(meas.mag(1,:)))) = meas.mag(:,find(isnan(meas.mag(1,:)))-1);
nx = 4; 
  x = [1; 0; 0 ;0]; 
  P = 0.5*eye(nx, nx);


    Rw = 1 * [0.2013   -0.0157    0.0220; -0.0157    0.1431   -0.0049; 0.0220   -0.0049    0.1396];           %cov
    Ra =  1*[0.1349   -0.0585   -0.0774; -0.0585    0.1177    0.0585; -0.0774    0.0585    0.1612];
    Rm = 1*[0.2283    0.1386    0.1489; 0.1386    0.1180    0.1250; 0.1489    0.1250    0.1949];
    Ralpha = 2*eye(3);
    Rq = 0.1*eye(4);
% Rw = 1*noiseParameters.gyrCov;
% Ra = 1*noiseParameters.accCov;
% Rm = 1*noiseParameters.magCov;
    
%       Rw = 1.0e-06 * diag([1.9974,1.6409,1.5017]);           %cov
%     Ra =  1.0e-06 * diag([1.1440,0.76292,1.2071]);
%     Rm = diag([0.0403, 0.0147,0.1039]);
    
         g0 = [ 0;0;9.7]; 
    m0 = [0;11.8447;-41.0179];     
    
    T = 1/100;
    counter = 0;
    x_p = zeros(4,5900);
    x_f = zeros(4,5900);
      x_1 = zeros(4,5900);
        x_2 = zeros(4,5900);
        x_3 = zeros(4,5900);

%%
for i = 1:5900
if ~all(isnan(meas.gyr))                                                             %filter begin when gyr data available
      if isnan(meas.gyr(:,counter+1))                                           %no measurement
        [x, P] = tu_qw_no_measure(x, P, meas.gyr, T, Rw);
        x_1(:,counter+1) = x;
      else
        [x, P] = tu_qw(x, P, meas.gyr(:,counter+1), T, Rw);                       %EKF pred
%          [x, P] = tu_qw_no_measure(x, P, meas.gyr, T, Rw);
%          [x, P] = simple_model(x, P, T, Rq);
        x_1(:,counter+1) = x;
      end
      
      if  abs(meas.acc(:,counter+1)) < 1.2*abs(g0)                              %if outlier, no update
          accOut = 1;                                                          
      else
          accOut = 0;
          [x, P] = mu_g(x, P, meas.acc(:,counter+1), Ra, g0);                    % update    
          [x, P] = mu_m(x, P, meas.mag(:,counter+1), m0, Rm); 
          x_1(:,counter+1) = x;
      end
%       ownView.setAccDist(accOut)
      counter = counter + 1;
end

%%
% if ~all(isnan(meas.gyr)) 
%       if isnan(meas.gyr(:,counter+1))                                           %no measurement
%         [x, P] = tu_qw_no_measure(x, P, gyr_last_value, T, Rw);
%       else
%         [x, P] = tu_qw(x, P, meas.gyr(:,counter+1), T, Rw);                       %EKF pred
%         x_p(:,counter+1) = x;
%           gyr_last_value = meas.gyr(:,counter+1);
%       end
%       
%       if  abs(meas.mag(:,counter+1)) < 1.2*abs(m0)                               %if outlier, no update
%           accOut = 1;                                                          
%       else
%           accOut = 0; 
%         [x, P] = mu_g(x, P, meas.mag(:,counter+1), Rm, m0);                     %update
%         x_f(:,counter+1) = x;
%       end
% %       ownView.setMagDist(accOut)
%   counter = counter + 1;
% end
%%
%  if ~all(isnan(meas.gyr))                                                             %filter begin when gyr data available
%       if isnan(meas.gyr(:,counter+1))                                           %no measurement
%         [x, P] = tu_qw_no_measure(x, P, gyr_last_value, T, Rw);                       
%       else
%         [x, P] = tu_qw(x, P, meas.gyr(:,counter+1), T, Rw);                       %EKF pred
%         gyr_last_value = meas.gyr(:,counter+1);
%         x_p(:,counter+1) = x;
%       end
%       
%       if  abs(meas.acc(:,counter+1)) < 1.2*abs(g0) 
%           accOut = 1;    
%       elseif abs(meas.mag(:,counter+1)) < 1.2*abs(m0)           %if outlier, no update
%           accOut = 1;                                                          
%       else
%           accOut = 0;                
%           [x, P] = acc_mag_fusion(x, P, meas.acc(:,counter+1), meas.mag(:,counter+1), g0, m0, Ra, Rm);        % update  
%           x_f(:,counter+1) = x;
%       end
% %       ownView.setAccDist(accOut)
%         counter = counter + 1;
% end
        %%
      
% if ~all(isnan(meas.gyr))                                                             %filter begin when gyr data available
%       
%       if isnan(meas.gyr(:,counter+1))                                           %no gyro  measurement
%         [x, P] = tu_qw_no_measure(x, P, meas.gyr, T, Rw);
%         x_p(:,counter+1) = x;
%             else
%         [x, P] = tu_qw(x, P, meas.gyr(:,counter+1), T, Rw);                       %gyro
%         x_2(:,counter+1) = x;
%       end
%           
%       if  abs(meas.acc(:,counter+1)) < 1.2*abs(g0)                              %if outlier, no update
%           accOut = 1;                                                          
%       else
%           accOut = 0;
%           [x, P] = mu_g(x, P, meas.acc(:,counter+1), Ra, g0);                    % acc  
%           x_1(:,counter+1) = x;
%           
%           [x, P] = mu_m(x, P, meas.mag(:,counter+1), m0, Rm);                     %mag
%           x_3(:,counter+1) = x;
%      end
% %       ownView.setAccDist(accOut)
%       counter = counter + 1;
% end
end


%%
% figure(1)
% subplot(4, 1, 1) 
% hold on;
% plot(x_1(1,:));
% plot(x_2(1,:));
% plot(x_3(1,:));
% plot(initData.orient(1,100:5900));
% legend('1','2','3','ref')
% subplot(4, 1, 2) 
% hold on;
% plot(x_1(2,:))
% plot(x_2(2,:))
% plot(x_3(2,:))
% plot(initData.orient(2,100:5900));
% legend('1','2','3','ref')
% subplot(4, 1, 3) 
% hold on;
% plot(x_1(3,:))
% plot(x_2(3,:))
% plot(x_3(3,:))
% plot(initData.orient(3,100:5900));
% legend('1','2','3','ref')
% subplot(4, 1, 4) 
% hold on;
% plot(x_1(4,:),'r')
% plot(x_2(4,:),'b')
% plot(x_3(4,:),'g')
% plot(initData.orient(4,100:5900),'k');
% legend('1','2','3','ref')
%%
figure(2)
subplot(4, 1, 1) 
hold on;
plot(x_1(1,:));

plot(initData.orient(1,100:5900));
legend('1','ref')
subplot(4, 1, 2) 
hold on;
plot(x_1(2,:))

plot(initData.orient(2,100:5900));
legend('1','ref')
subplot(4, 1, 3) 
hold on;
plot(x_1(3,:))

plot(initData.orient(3,100:5900));
legend('1','ref')
subplot(4, 1, 4) 
hold on;
plot(x_1(4,:),'r')

plot(initData.orient(4,100:5900),'k');
legend('1','ref')