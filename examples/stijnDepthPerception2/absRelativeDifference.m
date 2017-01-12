function error = absRelativeDifference( predictions, labels)
%ABSRELATIVEDIFFERENCE Summary of this function goes here
%   Detailed explanation goes here
    error = abs(predictions-labels)./labels;
    error = mean(error,3);
end

