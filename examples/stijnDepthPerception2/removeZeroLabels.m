%% Little script to remove the labels with only zeros
% Stijn Wellens
% April, 2016

clear;

labels_previous = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_esat.mat');

labels_prev = labels_previous.labels_processed;
labels_text = labels_previous.labels_name;

labels_processed = zeros(55,74,1);
labels_name = cell(1,1);
img_nmb = 1;
for i=1:size(labels_prev,3)
   if isempty(labels_text{i})
      
   else
       labels_processed(:,:,img_nmb) = labels_prev(:,:,i);
       labels_name{img_nmb} = labels_text{i};
       img_nmb = img_nmb + 1;
   end
end

%     labels = struct('labels',labels_all,'name',labels_text);
%     save('data/processed/labels/labels.mat', 'labels');
%     save('/home/stijnwellens/Documents/Thesis/Test_images/labels/labels_esat.mat', 'labels_processed', 'labels_name');
save('/esat/wasat/r0300219/NYUv2/processed/labels/labels_esat_2.mat', 'labels_processed', 'labels_name');
