function [xhat, meas] = filterTemplate(mode,tuningFactor)
% FILTERTEMPLATE  Filter template
%
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
% mode: 1:gyr+acc;2:gyr+mag(m0 fixed);3:gyr+mag(m0
% changing);4:gyr+acc+mag(m0 fixed);5:gyr+acc+mag(m0 changing);6:gyr+mag(m0
% changing)+acc
% tuningFactor 3*1, will be multiplied by Rw,Ra,Rm
%% Setup necessary infrastructure
import('com.liu.sensordata.*');  % Used to receive data.

%% Filter settings
t0 = [];  % Initial time (initialize on first data received)
nx = 4;   % Assuming that you use q as state variable.
% Add your filter settings here.
%load('noiseParameters_with_g0_m0.mat')
load('measured_now_noiseParameters.mat');
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
try
    %% Create data link
    server = StreamSensorDataReader(3400);
    % Makes sure to resources are returned.
    sentinel = onCleanup(@() server.stop());
    
    server.start();  % Start data reception.
    
    % Used for visualization.
    figure(1);
    subplot(1, 2, 1);
    ownView = OrientationView('Own filter', gca);  % Used for visualization.
    googleView = [];
    counter = 0;  % Used to throttle the displayed frame rate.
    
    %% Filter loop
    while server.status()  % Repeat while data is available
        % Get the next measurement set, assume all measurements
        % within the next 5 ms are concurrent (suitable for sampling
        % in 100Hz).
        data = server.getNext(5);
        
        if isnan(data(1))  % No new data received
            continue;        % Skips the rest of the look
        end
        t = data(1)/1000;  % Extract current time
        
        if isempty(t0)  % Initialize t0
            t0 = t;
        end
        if any(isnan(data(1,2:10)))
            continue;
        end
        acc = data(1, 2:4)';
        gyr = data(1, 5:7)';
        mag = data(1, 8:10)';
        orientation = data(1, 18:21)';  % Google's orientation estimate.
        if counter == 0
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
            %assume the prior is exact
            %x = orientation;
            counter = counter+1;
            continue;
        end
        if counter>=1%filtering
            tLast = xhat.t(end);%last time instance when all data is available
            gyr_kmin1 = meas.gyr(:,end);
            T = (t-t0)-tLast;
            Rw = (0.5*Sq(x)) * noiseParameters.gyrCov*(0.5*Sq(x))';
            [xPredict,PPredict] = tu_qw(x,P,tuningFactor(1)*gyr_kmin1,T,Rw);
            [xUpdateAcc, PUpdateAcc] = ...
                mu_g(xPredict, PPredict, acc, tuningFactor(2)*noiseParameters.accCov,noiseParameters.g0);
            switch mode
                case 1
                    x = xUpdateAcc; P=PUpdateAcc;
                case 2
                    [xUpdateMag, PUpdateMag] = ...
                        mu_g(xPredict, PPredict, mag, tuningFactor(3)*noiseParameters.magCov,noiseParameters.m0);
                    x = xUpdateMag; P = PUpdateMag;
                case 3
                    m0 = [0 sqrt(mag(1)^2+mag(2)^2) mag(3)]';
                    [xUpdateMag, PUpdateMag] = ...
                        mu_g(xPredict, PPredict, mag, tuningFactor(3)*noiseParameters.magCov,m0);
                    x = xUpdateMag; P = PUpdateMag;
                case 4
                    [xUpdateMag, PUpdateMag] = ...
                        mu_g(xUpdateAcc, PUpdateAcc, mag, tuningFactor(3)*noiseParameters.magCov,noiseParameters.m0);
                    x = xUpdateMag; P = PUpdateMag;
                case 5
                    m0 = [0 sqrt(mag(1)^2+mag(2)^2) mag(3)]';
                    [xUpdateMag, PUpdateMag] = ...
                        mu_g(xUpdateAcc, PUpdateAcc, mag, tuningFactor(3)*noiseParameters.magCov,m0);
                    x = xUpdateMag; P = PUpdateMag;
                case 6
                    m0 = [0 sqrt(mag(1)^2+mag(2)^2) mag(3)]';
                    [xUpdateMag, PUpdateMag] = ...
                        mu_g(xPredict,PPredict, mag, tuningFactor(3)*noiseParameters.magCov,m0);
                    [xUpdateAcc, PUpdateAcc] = ...
                        mu_g(xUpdateMag, PUpdateMag, acc, tuningFactor(2)*noiseParameters.accCov,noiseParameters.g0);
                    x = xUpdateAcc; P = PUpdateAcc;
                otherwise
                    error('invalid mode')
            end
            %x = xUpdateAcc; P=PUpdateAcc;
            %x = [xUpdateMag(1);xUpdateAcc(2);xUpdateAcc(2);xUpdateMag(1)];
            %P = (PUpdateMag+PUpdateAcc)/2;
            %[x,P] = mu_normalizeQ(x,P);
        end
        % Visualize result
        if rem(counter, 10) == 0
            setOrientation(ownView, x(1:4));
            title(ownView, 'OWN', 'FontSize', 16);
            if ~any(isnan(orientation))
                if isempty(googleView)
                    subplot(1, 2, 2);
                    % Used for visualization.
                    googleView = OrientationView('Google filter', gca);
                end
                setOrientation(googleView, orientation);
                title(googleView, 'GOOGLE', 'FontSize', 16);
            end
        end
        counter = counter + 1;
        
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
catch e
    fprintf(e.message);
    fprintf(['\nUnsuccessful connecting to client!\n' ...
        'Make sure to start streaming from the phone *after*'...
        'running this function!']);
end
end
