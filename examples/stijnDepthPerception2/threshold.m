function accuracy = threshold(predictions, labels, thr)
%ABSRELATIVEDIFFERENCE Summary of this function goes here
%   Detailed explanation goes here
accuracy = zeros(size(predictions,3),1);
for i=1:size(predictions,3)
    prediction = predictions(:,:,i);
    label = labels(:,:,i);
    
    prediction = reshape(prediction,1,4070);
    label = reshape(label,1,4070);
    
    total = 0;
    for ii=1:size(prediction,2)
        delta = max(prediction(ii)/label(ii),label(ii)/prediction(ii));
        total = total + (delta < thr);
    end
    
    accuracy(i) = total/4070;
end

accuracy = mean(accuracy);

end

