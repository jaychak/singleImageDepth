function [im, labels] = getBatch_labeledset1(imdb, batch)

% im = single(imdb.images.data(:,:,:,batch)) ;
im1 = imdb.images.data(:,:,:,batch) ;
% im = imresize(im, 0.5); %Downsampling the images
% im = reshape(im, 32, 32, 1, []) ;
%labels = imdb.images.labels(:,:,batch) ;
%labels = single(imresize(labels,[55 74]));

labels = single(imdb.images.labels(:,:,batch)); % Large CNN


imageMean = imdb.images.image_mean;


for i=1:size(im1,4)
%     im(:,:,:,i) = imresize(im1{i}, [240, 320]);
%     im(:,:,:,i) = im1(:,:,:,i) - imageMean;
     im(:,:,:,i) = single(im1(:,:,:,i)) - imageMean;
end


end
