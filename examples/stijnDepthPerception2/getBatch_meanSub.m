function [im, labels] = getBatch_meanSub(imdb, batch)

% % im = single(imdb.images.data(:,:,:,batch)) ;
% im = imdb.images.data(:,:,:,batch) ;
% % im = imresize(im, 0.5); %Downsampling the images
% % im = reshape(im, 32, 32, 1, []) ;
% labels = imdb.images.labels(:,:,batch) ;
% labels = single(imresize(labels,[55 74]));

% Create cell array with all image names in batch
image_idx = 1;

fprintf('numel(batch): %d',numel(batch));
for i=1:numel(batch)
    batch_val = batch(i);
    image_names{image_idx} = imdb.images.data{batch_val};
    image_idx = image_idx + 1;
end

% % Create cell array with all label names in batch
% image_idx = 1;
% for i=1:numel(batch)
%     batch_val = batch(i);
%     label_names{image_idx} = imdb.images.labels{batch_val};
%     label_index(image_idx) = imdb.images.labelindex(batch_val);
%     image_idx = image_idx + 1;
% end
% 
% % Load labels corresponding to batch images
% labels = zeros(55,74,numel(batch));% ,'gpuArray');
% for i=1:numel(batch)
%     all_labels = load(label_names{i});
%     all_labels = all_labels.labels_processed;
%     index = label_index(i);
%     labels(:,:,i) = all_labels(:,:,index);    
% end

% i = i + 1;
% all_labels = load(current_labelfile);
% all_labels = all_labels.labels_processed;
% labels(:,:,start:i-1) = all_labels(:,:,label_index(start):(i-1-start)+label_index(start));

labels = single(imdb.images.labels(:,:,batch)); % Large CNN
% labels = single(imresize(labels,[55 74]));

% labels = imdb.images.labels(:,:,batch);%Jay: Small CNN
% labels = single(imresize(labels,[16 32]));

im1 = vl_imreadjpeg(image_names, 'NumThreads', 8);

% for i=numel(image_names)
%    im1(:,:,:,i) = single(imread(image_names(i))); 
% end

% Load the image mean and subtract
imageMean = imdb.images.image_mean;

for i=1:numel(im1)%size(im1,4)
%     im(:,:,:,i) = imresize(im1{i}, [240, 320]);
%     im(:,:,:,i) = im1(:,:,:,i) - imageMean;
     im(:,:,:,i) = single(im1{i}) - imageMean;
end
fprintf('Size of batch im: %d %d %d %d \n', size(im,1), size(im,2), size(im,3), size(im,4));
fprintf('Size of batch label: %d %d %d %d \n', size(labels,1), size(labels,2), size(labels,3), size(labels,4));

% 
% figure(1);
% % Show the RGB image.
% subplot(1,2,1);
% imagesc(uint8(im(:,:,:,1)));
% axis off;
% axis equal;
% title('RGB');
% 
% % Show the Depth image.
% subplot(1,2,2);
% imagesc(labels(:,:,1));
% axis off;
% axis equal;
% title('Depth');
% pause(0.001);

end
