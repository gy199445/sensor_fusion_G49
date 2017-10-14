meas.acc = initData.acc(:,100:1600);
meas.gyr = initData.gyr(:,100:1600);
meas.mag = initData.mag(:,100:1600);   
nx = 4; 
  x = [1; 0; 0 ;0]; 
  P = eye(nx, nx);

      Rw = 1.0e-05 * [0.2013   -0.0157    0.0220; -0.0157    0.1431   -0.0049; 0.0220   -0.0049    0.1396];           %cov
    Ra =  [0.1349   -0.0585   -0.0774; -0.0585    0.1177    0.0585; -0.0774    0.0585    0.1612];
    Rm = [0.2283    0.1386    0.1489; 0.1386    0.1180    0.1250; 0.1489    0.1250    0.1949];
    
        g0 = [ -0.0019;0.0003;9.6847];                                                             % g0 and m0 should be measured again when environment changes
    m0 = [0;11.8447;-41.0179];                                                                        
    T = 1/100;
    counter = 0;
for i = 1:100
if ~all(isnan(meas.gyr))                                                             %filter begin when gyr data available
      if isnan(meas.gyr(:,counter+1))                                           %no measurement
        [x, P] = tu_qw_no_measure(x, P, meas.gyr, T, Rw);                       
      else
        [x, P] = tu_qw(x, P, meas.gyr(:,counter+1), T, Rw);                       %EKF pred
      end
      
      if  abs(meas.acc(:,counter+1)) < 1.2*abs(g0)                              %if outlier, no update
          accOut = 1;                                                          
      else
          accOut = 0;
          [x, P] = mu_g(x, P, meas.acc(:,counter+1), Ra, g0);                    % update    
      end
%       ownView.setAccDist(accOut)
      counter = counter + 1;
end

end