% original_image_filenames = dir('/esat/emerald/pchakrav/singleImageDepthDataset/originalImages1');
% flipped_image_filenames  = dir('/esat/emerald/pchakrav/singleImageDepthDataset/flippedImages1');
% rotated_image_filenames  = dir('/esat/emerald/pchakrav/singleImageDepthDataset/rotatedImages1');
% test_image_filenames  = dir('/esat/emerald/pchakrav/singleImageDepthDataset/testImages');
% 
% all_filenames={};
% filename_idx = 1;
% for i=1:numel(original_image_filenames)
%     filename_this = original_image_filenames(i);
%     if filename_this.bytes ~= 0
%         all_filenames{filename_idx} = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/originalImages1/',filename_this.name);
%         filename_idx = filename_idx + 1;
%     end
% end
clear all;

%% Get train and test image filenames
train_image_filenames = dir('/esat/emerald/pchakrav/singleImageDepthDataset/trainImages');
test_image_filenames  = dir('/esat/emerald/pchakrav/singleImageDepthDataset/testImages');

all_filenames = [train_image_filenames; test_image_filenames];

filename_idx= 1;
for i=1:numel(all_filenames)
    if all_filenames(i).bytes ~= 0
        if filename_idx <= 11520
            all_filenames1{filename_idx} = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/trainImages/',all_filenames(i).name);
        else
            all_filenames1{filename_idx} = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/testImages/',all_filenames(i).name);
        end
        filename_idx = filename_idx + 1; 
    end
end

%% Get mean image
batch_size = 100;
mean_idx = 1;
image_means = zeros(240,320,3,120);
for i=1:batch_size:numel(all_filenames1)
    for j=1:batch_size
        image_names{j} = all_filenames1{i+j-1};
    end
    
    images = vl_imreadjpeg(image_names, 'NumThreads', 8);
    
    for k=1:numel(images)
        im(:,:,:,k) = images{k};
    end
    
    image_means(:,:,:,mean_idx) = mean(im, 4);
%     figure,imshow(uint8(image_mean));
%     pause;
    mean_idx = mean_idx + 1;
end

image_mean_orig = mean(image_means,4);
figure,imshow(uint8(image_mean_orig));
save('/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/data/coarse_depth/mean_image.mat', 'image_mean_orig') ;

%% Save mean-subtracted images
% 
% save_dir_prefix = '/esat/emerald/pchakrav/singleImageDepthDataset/meanSubtracted/';
% %% Subtract mean and save images to file
% image_idx= 1;
% for i=1:batch_size:numel(all_filenames1)
%     for j=1:batch_size
%         image_names{j} = all_filenames1{i+j-1};
%     end
%     
%     images = vl_imreadjpeg(image_names, 'NumThreads', 8);
%     
%     for k=1:numel(images)
%         image_mean_subtracted = images{k} - image_mean_orig;
%         save_image_name = strcat(save_dir_prefix, num2str(image_idx,'%05.f'), '.jpeg');
%         imwrite(uint8(image_mean_subtracted), save_image_name);
%         image_idx = image_idx + 1;
%     end
% end
%  
% 
% filename_idx = numel(all_filenames)+1;
% for i=1:numel(flipped_image_filenames)
%     filename_this = flipped_image_filenames(i);
%     if filename_this.bytes ~= 0
%         all_filenames{filename_idx} = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/flippedImages1/',filename_this.name);
%         filename_idx = filename_idx + 1;
%     end
% end
% 
% filename_idx = numel(all_filenames)+1;
% for i=1:numel(rotated_image_filenames)
%     filename_this = rotated_image_filenames(i);
%     if filename_this.bytes ~= 0
%         all_filenames{filename_idx} = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/rotatedImages1/',filename_this.name);
%         filename_idx = filename_idx + 1;
%     end
% end
% 
% filename_idx = numel(all_filenames)+1;
% for i=1:numel(test_image_filenames)
%     filename_this = test_image_filenames(i);
%     if filename_this.bytes ~= 0
%         all_filenames{filename_idx} = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/testImages/',filename_this.name);
%         filename_idx = filename_idx + 1;
%     end
% end