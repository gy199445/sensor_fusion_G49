function [ index ] = findFirstNonNaN( data )
%FINDFIRSTNONNAN Summary of this function goes here
%   Detailed explanation goes here
%   find the index of the first data that are non NaN
K = length(data.t);
for i = 1:K
    %break until find NonNaN
    if ~(any(isnan(data.t(i))) || any(isnan(data.mag(:,i))) || ...
            any(isnan(data.acc(:,i)))||any(isnan(data.gyr(:,i)))||...
            any(isnan(data.orient(:,i))))
        index = i;
        break
    end
end

