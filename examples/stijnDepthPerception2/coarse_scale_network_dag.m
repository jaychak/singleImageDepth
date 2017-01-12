clear;
setup;
% addpath('toolbox_nyu_depth_v2');
run toolbox_nyu_depth_v2/compile;

%% GET THE DATA

% Load NYUdepth dataset
% dataset = load('data/nyu_depth_v2_labeled.mat','images','depths') ;
nyudepthv2 = matfile('data/nyu_depth_v2_labeled.mat');
dataset.images.data = nyudepthv2.images(:,:,:,1:75);
dataset.images.labels = nyudepthv2.depths(:,:,1:75);

% Choose a training image
imageID = 1;

% Visualize an image
imgRGB = dataset.images.data(:,:,:,imageID);
imgDepth = dataset.images.labels(:,:,imageID);

figure(1);
% Show the RGB image.
subplot(1,2,1);
imagesc(imgRGB);
axis off;
axis equal;
title('RGB');

% Show the Depth image.
subplot(1,2,2);
imagesc(imgDepth);
axis off;
axis equal;
title('Depth');

% Choose a training image
imageID = 51;

% Visualize an image
imgRGB = dataset.images.data(:,:,:,imageID);
imgDepth = dataset.images.labels(:,:,imageID);

figure(2);
% Show the RGB image.
subplot(1,2,1);
imagesc(imgRGB);
axis off;
axis equal;
title('RGB');

% Show the Depth image.
subplot(1,2,2);
imagesc(imgDepth);
axis off;
axis equal;
title('Depth');

%% INITIALIZE CNN ARCHITECTURE

net = initializeCoarseCNN();

%% TRAIN CNN

varargin = struct();

% opts.continue = true ;
opts.learningRate = 0.001 ;
opts.batchSize = 20 ; % Amount of images selected from the whole set
opts.numEpochs = 15 ; % Amount of iterations
opts.gpus = [] ;
opts.errorFunction = 'none';

opts.expDir = 'data/coarse_depth' ;
opts = vl_argparse(opts, varargin);

% Downsampling the input
dataset.images.data = dataset.images.data(1:2:end,1:2:end,:,:);

% Dividing training and validation data
tr = 2/3;
nmb_images = size(dataset.images.data,4);
nmb_training = ceil(tr*nmb_images);
dataset.images.set = [ones(nmb_training,1); 2*ones(nmb_images-nmb_training,1)];

% Image-Preprocessing: take the average image out
imageMean = uint8(mean(dataset.images.data, 4) );
% pixelMean = [sum(sum(imageMean(:,:,1),1),2) sum(sum(imageMean(:,:,2),1),2) sum(sum(imageMean(:,:,3),1),2)]/(size(imageMean,1)*size(imageMean,2))
dataset.images.data = dataset.images.data - repmat(imageMean,[ 1 1 1 size(dataset.images.data,4) ]) ;

% Call training function in MatConvNet
[net,info] = cnn_train(net, dataset, @getBatch, opts) ;

% Save the result for later use
net.layers(end) = [] ;
net.imageMean = imageMean ;
save('data/coarse_depth/coarsecnn.mat', '-struct', 'net') ;

