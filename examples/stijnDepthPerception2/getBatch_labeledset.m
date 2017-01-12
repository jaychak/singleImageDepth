function [im, labels] = getBatch_labeledset(imdb, batch)

% im = single(imdb.images.data(:,:,:,batch)) ;
im = imdb.images.data(:,:,:,batch) ;
% im = imresize(im, 0.5); %Downsampling the images
% im = reshape(im, 32, 32, 1, []) ;
labels = imdb.images.labels(:,:,batch) ;
labels = single(imresize(labels,[55 74]));


end
