function [im, labels] = getBatch(imdb, batch)

% % im = single(imdb.images.data(:,:,:,batch)) ;
% im = imdb.images.data(:,:,:,batch) ;
% % im = imresize(im, 0.5); %Downsampling the images
% % im = reshape(im, 32, 32, 1, []) ;
% labels = imdb.images.labels(:,:,batch) ;
% labels = single(imresize(labels,[55 74]));

image_idx = 1;
for i=1:numel(batch)
    batch_val = batch(i);
    image_names{image_idx} = imdb.images.data{batch_val};
    image_idx = image_idx + 1;
end


labels = single(imdb.images.labels(:,:,batch)); % Large CNN

% labels = imdb.images.labels(:,:,batch);%Jay: Small CNN
% labels = single(imresize(labels,[16 32]));


im1 = vl_imreadjpeg(image_names, 'NumThreads', 8);

for i=1:numel(im1)
    im(:,:,:,i) = im1{i};
end

end
