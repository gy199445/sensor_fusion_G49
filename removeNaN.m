function [ NaNRemoved ] = removeNaN( meas )
%REMOVENAN Summary of this function goes here
%   Detailed explanation goes here
%   remove NaN from measurement
n = size(meas,1);
K = size(meas,2);
validColIndex = ones(1,K);
for i = 1:n
    validColIndex = validColIndex .* (~isnan(meas(i,:)));
end
NaNRemoved = meas(:,validColIndex==1);
end

