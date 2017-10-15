function [xhat, meas] = filterTemplate_testing(calAcc, calGyr, calMag)
% COPY OF FILTERTEMPLATE  Filter template
% for testing our filter, use local data
% This is a template function for how to collect and filter data
% sent from a smartphone live.  Calibration data for the
% accelerometer, gyroscope and magnetometer assumed available as
% structs with fields m (mean) and R (variance).
%
% The function returns xhat as an array of structs comprising t
% (timestamp), x (state), and P (state covariance) for each
% timestamp, and meas an array of structs comprising t (timestamp),
% acc (accelerometer measurements), gyr (gyroscope measurements),
% mag (magnetometer measurements), and orint (orientation quaternions
% from the phone).  Measurements not availabe are marked with NaNs.
%
% As you implement your own orientation estimate, it will be
% visualized in a simple illustration.  If the orientation estimate
% is checked in the Sensor Fusion app, it will be displayed in a
% separate view.
%
% Note that it is not necessary to provide inputs (calAcc, calGyr, calMag).

%% Setup necessary infrastructure
import('com.liu.sensordata.*');  % Used to receive data.
%% Filter settings
t0 = [];  % Initial time (initialize on first data received)
nx = 4;   % Assuming that you use q as state variable.
% Add your filter settings here.
load('noiseParameters_with_g0.mat')
load('initData.mat')
dataMatrix = dataStructToMatrix(initData);
totalLength = size(dataMatrix,2);
% Current filter state.
x = [1; 0; 0 ;0];
P = eye(nx, nx);
% Saved filter states.
xhat = struct('t', zeros(1, 0),...
    'x', zeros(nx, 0),...
    'P', zeros(nx, nx, 0));

meas = struct('t', zeros(1, 0),...
    'acc', zeros(3, 0),...
    'gyr', zeros(3, 0),...
    'mag', zeros(3, 0),...
    'orient', zeros(4, 0));
% Used for visualization.
figure(1);
subplot(1, 2, 1);
ownView = OrientationView('Own filter', gca);  % Used for visualization.
googleView = [];
%% Filter loop
for i=27:totalLength % Repeat while data is available
    % Get the next measurement set, assume all measurements
    % within the next 5 ms are concurrent (suitable for sampling
    % in 100Hz).
    data = dataMatrix(:,i);
    if isnan(data(1))  % No new data received
        continue;        % Skips the rest of the loop
    elseif any(isnan(data(2:10))) %data is nan
        continue;   %skip the loop unless full column is received
    end
    t = data(1); % Extract current time
    if isempty(t0)  % Initialize t0
        t0 = 0;
    end
    %extract data
    acc = data(2:4,:);
    gyr = data(5:7,:);
    mag = data(8:10,:);
    orientation = data(11:14,:);  % Google's orientation estimate.
    
    if i == 27
        % intialize filter
        % Save estimates instead of filtering because measurement not
        % available
        xhat.x(:, end+1) = x;
        xhat.P(:, :, end+1) = P;
        xhat.t(end+1) = t - t0;
        meas.t(end+1) = t - t0;
        meas.acc(:, end+1) = acc;
        meas.gyr(:, end+1) = gyr;
        meas.mag(:, end+1) = mag;
        meas.orient(:, end+1) = orientation;
        continue;
    end
    if i>=28 %filtering
        tLast = xhat.t(end);%last time instance when all data is available
        gyr_kmin1 = meas.gyr(:,end);
        T = t-tLast;
        %process noise
        Rw = (0.5*Sq(x)) * noiseParameters.gyrCov*(0.5*Sq(x))';
        [xPredict,PPredict] = tu_qw(x,P,gyr_kmin1,T,Rw);
        [x, P] = ...
            mu_g(xPredict, PPredict, acc, noiseParameters.accCov, noiseParameters.g0);
    end
    
    %     % Visualize result
    %     setOrientation(ownView, x(1:4));
    %     title(ownView, 'OWN', 'FontSize', 16);
    %     if ~any(isnan(orientation))
    %         if isempty(googleView)
    %             subplot(1, 2, 2);
    %             % Used for visualization.
    %             googleView = OrientationView('Google filter', gca);
    %         end
    %         setOrientation(googleView, orientation);
    %         title(googleView, 'GOOGLE', 'FontSize', 16);
    %     end
    
    % Save estimates
    xhat.x(:, end+1) = x;
    xhat.P(:, :, end+1) = P;
    xhat.t(end+1) = t - t0;
    
    meas.t(end+1) = t - t0;
    meas.acc(:, end+1) = acc;
    meas.gyr(:, end+1) = gyr;
    meas.mag(:, end+1) = mag;
    meas.orient(:, end+1) = orientation;
end
end