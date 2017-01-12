clear;
% setup_nongpu;
%setup;
% addpath('toolbox_nyu_depth_v2');
% run toolbox_nyu_depth_v2/compile;

%% GET THE DATA

% Load NYUdepth dataset
% dataset = load('data/nyu_depth_v2_labeled.mat','images','depths') ;
% nyudepthv2 = matfile('data/nyu_depth_v2_labeled.mat');
nyudepthv2 = matfile('/esat/snake/pchakrav/datasets/singleImageDepth/NYU2/nyu_depth_v2_labeled.mat');
dataset.images.data = single(nyudepthv2.images(:,:,:,1:1344)); %1440
dataset.images.labels = nyudepthv2.depths(:,:,1:1344);

% % Choose a training image
% imageID = 1;
% 
% % Visualize an image
% imgRGB = dataset.images.data(:,:,:,imageID);
% imgDepth = dataset.images.labels(:,:,imageID);

% figure(1);
% % Show the RGB image.
% subplot(1,2,1);
% imagesc(imgRGB);
% axis off;
% axis equal;
% title('RGB');
% 
% % Show the Depth image.
% subplot(1,2,2);
% imagesc(imgDepth);
% axis off;
% axis equal;
% title('Depth');

% % Choose a training image
% imageID = 51;
% 
% % Visualize an image
% imgRGB = dataset.images.data(:,:,:,imageID);
% imgDepth = dataset.images.labels(:,:,imageID);
% 
% figure(2);
% % Show the RGB image.
% subplot(1,2,1);
% imagesc(imgRGB);
% axis off;
% axis equal;
% title('RGB');
% 
% % Show the Depth image.
% subplot(1,2,2);
% imagesc(imgDepth);
% axis off;
% axis equal;
% title('Depth');

%% INITIALIZE CNN ARCHITECTURE

net = initializeCoarseCNN();
% net = dagnn.DagNN.fromSimpleNN(net);

%% TRAIN CNN

varargin = struct();

opts.continue = false ;
opts.learningRate = 0.01; % Will be multiplied with learning rate of each layer
opts.batchSize = 32; % Amount of images selected from the whole set
% opts.numEpochs = 15 ; % Amount of iterations
opts.numEpochs = 10 ; % Amount of iterations
opts.weightDecay = 0.01;
% opts.weightDecay = 0.01; % regularization, the larger the more emphasis on minimizing the weights (less chance on overfitting, but underfitting!) 
opts.momentum = 0.65;
opts.gpus = 1; %[] ;
% opts.gpus = [];
opts.errorFunction = 'RMSE_linear';
opts.conserveMemory = false ;

opts.expDir = 'data/coarse_depth' ;
opts = vl_argparse(opts, varargin);

% Downsampling the input
dataset.images.data = dataset.images.data(1:2:end,1:2:end,:,:);
% dataset.images.labels = single(dataset.images.labels(1:2:end,1:2:end,:,:));

% Dividing training and validation data
tr = 2/3; 
% tr = 4/5;
nmb_images = size(dataset.images.data,4);
nmb_training = ceil(tr*nmb_images);
dataset.images.set = [ones(nmb_training,1); 2*ones(nmb_images-nmb_training,1)];

% Image-Preprocessing: take the average image out
imageMean = single(mean(dataset.images.data, 4));
% pixelMean = [sum(sum(imageMean(:,:,1),1),2) sum(sum(imageMean(:,:,2),1),2) sum(sum(imageMean(:,:,3),1),2)]/(size(imageMean,1)*size(imageMean,2))
dataset.images.data = dataset.images.data - repmat(imageMean,[ 1 1 1 size(dataset.images.data,4) ]) ;
dataset.images.image_mean = imageMean;
% % Normalization
% stdev = std2(dataset.images.data);
% dataset.images.data = dataset.images.data./stdev;
% for i=1:size(dataset.images.data,4)
%    dataset.images.data(:,:,:,i) = dataset.images.data(:,:,:,i)./norm_matrix; 
% end
% dataset.images.data = vl_imsmooth(dataset.images.data,3);
% for i=1:size(dataset.images.data,4)
%    dataset.images.data(:,:,:,i) = vl_imsmooth(dataset.images.data(:,:,:,i),3); 
% end

% Call training function in MatConvNet
[net,info] = cnn_train(net, dataset, @getBatch_labeledset, opts) ;

% Save the result for later use
net.layers(end) = [] ;
net.imageMean = imageMean ;
save('data/coarse_depth/coarsecnn.mat', '-struct', 'net') ;

