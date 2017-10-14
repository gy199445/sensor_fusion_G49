function [ NaNRemoved ] = removeNaN( meas )
%REMOVENAN Summary of this function goes here
%   Detailed explanation goes here
%   remove NaN from measurement
%   if meas is a struct, all the measurements are removed if there is at
%   least one NaN at that time instance, if meas is an array, the
%   measurements are removed if there is at least one NaN elements at that
%   time instance (column).
if isa(meas,'struct')
    fieldNames = {'t','acc','gyr','mag','orient'};
    NaNRemoved = meas;
    K = size(meas,2);
    validColIndex = ones(1,K);
    for i = 1:5
        data = meas.(fieldNames{i});
        n = size(data,1);
        for j=1:n
            validColIndex = validColIndex .* (~isnan(data(j,:)));
        end
    end
    for i = 1:5
        data = meas.(fieldNames{i});
        NaNRemoved.(fieldNames{i}) = data(:,validColIndex==1);
    end
else
    n = size(meas,1);
    K = size(meas,2);
    validColIndex = ones(1,K);
    for i = 1:n
        validColIndex = validColIndex .* (~isnan(meas(i,:)));
    end
    NaNRemoved = meas(:,validColIndex==1);
end
end