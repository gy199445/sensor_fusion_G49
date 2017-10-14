function [ output_args ] = isDataNaN( data,t )
%ISDATANAN Summary of this function goes here
%   Detailed explanation goes here
%   return boolean whether or not the data at t contains any NaN
output_args = (any(isnan(data.t(t))) || any(isnan(data.mag(:,t))) || ...
            any(isnan(data.acc(:,t)))||any(isnan(data.gyr(:,t)))||...
            any(isnan(data.orient(:,t))));
end

