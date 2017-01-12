function error = abs_rel_diff(predictions, labels)
%ABSRELATIVEDIFFERENCE Summary of this function goes here
%   Detailed explanation goes here
error = zeros(size(predictions,3),1);
for i=1:size(predictions,3)
    prediction = predictions(:,:,i);
    label = labels(:,:,i);
    
    prediction = reshape(prediction,1,4070);
    label = reshape(label,1,4070);
    
    error(i) = mean(abs(prediction-label)./label);
end

error = mean(error);

end

