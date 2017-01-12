function error = RMSE_log_scale_invariant( predictions, labels)
%ABSRELATIVEDIFFERENCE Summary of this function goes here
%   Detailed explanation goes here
error = zeros(size(predictions,3),1);
for i=1:size(predictions,3)
    prediction = predictions(:,:,i);
    label = labels(:,:,i);
    
    prediction = reshape(prediction,1,4070);
    label = reshape(label,1,4070);
    
    d = log(prediction) - log(label);
    alpha = mean(log(label)-log(prediction),'omitnan');
    
    error(i) = sqrt(mean((d + ones(size(d))*alpha).^2,'omitnan'));
end

error = mean(error);

end

