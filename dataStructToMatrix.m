function [ dataMatrix ] = dataStructToMatrix( data )
%DATASTRUCTTOMATRIX Summary of this function goes here
%   Detailed explanation goes here
%   transform the data struct to matrix
%   for testing filter
k = length(data.t);
dataMatrix = zeros(14,k);
dataMatrix(1,:) = data.t;
dataMatrix(2:4,:) = data.acc;
dataMatrix(5:7,:) = data.gyr;
dataMatrix(8:10,:) = data.mag;
dataMatrix(11:14,:) = data.orient;
end

