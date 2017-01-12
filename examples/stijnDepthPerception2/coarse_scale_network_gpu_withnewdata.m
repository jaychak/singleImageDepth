clear;

addpath('/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/matconvnet-1.0-beta18/');
addpath(genpath('/usr/local/cuda-7.5/lib64')); % cuda 7.5
addpath(genpath('/users/start2013/r0300219/Documents/Thesis/cuda/lib64')); %cuDNN genpath = to add subfolders
% setup; %Stijn: setup should be done before compiling this with mcc
% addpath('toolbox_nyu_depth_v2');
% run toolbox_nyu_depth_v2/compile;
% setup_nongpu;
setup;

%% GET THE DATA

% Load NYUdepth dataset
% dataset = load('data/nyu_depth_v2_labeled.mat','images','depths') ;
% nyudepthv2 = matfile('data/nyu_depth_v2_labeled.mat');
% nyudepthv2 = matfile('/esat/snake/pchakrav/datasets/singleImageDepth/NYU2/nyu_depth_v2_labeled.mat');
% nyudepthv2 = matfile('/esat/snake/pchakrav/datasets/singleImageDepth/NYU2/nyu_depth_v2_labeled.mat');
% 
% dataset.images.data = single(nyudepthv2.images(:,:,:,1:144)); %1440
% dataset.images.labels = nyudepthv2.depths(:,:,1:144);

%% Data original
% nyudepth_augmented_labels = load('/esat/emerald/pchakrav/singleImageDepthDataset/allLabels/labels_flip_rot_rand_crop.mat');
% 
% image_filenames = dir('/esat/emerald/pchakrav/singleImageDepthDataset/meanSubtractedFlippedRotatedRandomCrop/');
% all_filenames={};
% filename_idx = 1;
% for i=1:numel(image_filenames)
%     filename_this = image_filenames(i);
%     if filename_this.bytes ~= 0
%         all_filenames{filename_idx} = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/meanSubtractedFlippedRotatedRandomCrop/',filename_this.name);
%         filename_idx = filename_idx + 1;
%     end
% end



%% Data new
nyudepth_labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_test.mat');
% nyudepth_labels2 = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels2.mat');

nyudepth_labels = nyudepth_labels_fullset.labels_processed;
% nyudepth_labels2 = nyudepth_labels2.labels;

% nyudepth_labels = cat(3, nyudepth_labels, nyudepth_labels2);

image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_test/');
all_filenames={};
filename_idx = 1;
for i=1:numel(image_filenames)
    filename_this = image_filenames(i);
    if filename_this.bytes ~= 0
        all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images_test/',filename_this.name);
        filename_idx = filename_idx + 1;
    end
end

%%
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
%% TRAIN CNN

varargin = struct();

opts.continue = false ;
opts.learningRate = 0.01; % Will be multiplied with learning rate of each layer
opts.batchSize = 32 ; % Amount of images selected from the whole set
opts.numEpochs = 30 ; % Amount of iterations
% opts.weightDecay = 0.0007;
% opts.weightDecay = 0.007; % regularization, the larger the more emphasis on minimizing the weights (less chance on overfitting, but underfitting!) 
opts.weightDecay = 0.01;
opts.momentum = 0.9; % The lower, the higher the chance on overfitting?? (Stijn: to check)
opts.gpus = 1; %[] ;
% opts.gpus = [];
opts.errorFunction = 'RMSE_linear';
opts.conserveMemory = false ;

opts.expDir = '/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/data/coarse_depth' ;
opts = vl_argparse(opts, varargin);

% Downsampling the input
% dataset.images.data = dataset.images.data(1:2:end,1:2:end,:,:);
% dataset.images.labels = single(dataset.images.labels(1:2:end,1:2:end,:,:));

% Dividing training and validation data
% tr = 2/3; 
% tr = 4/5;
% nmb_images = size(dataset.images.data,4);
% nmb_training = ceil(tr*nmb_images);
% dataset.images.set = [ones(nmb_training,1); 2*ones(nmb_images-nmb_training,1)];

% nmb_images = 60000;%size(dataset.images.data,4);
% nmb_training = 59520;%ceil(tr*nmb_images);
nmb_images = 64;%size(dataset.images.data,4);
nmb_training = 32;%ceil(tr*nmb_images);

% dataset.images.data   = all_filenames(183:end);%images_resized;
% dataset.images.labels = nyudepth_labels;

dataset.images.data   = all_filenames(1:64);%images_resized;
%dataset.images.labels = labels_resized;
% dataset.images.labels = nyudepth_labels(:,:,1:60000);
dataset.images.labels = nyudepth_labels(:,:,1:64);
dataset.images.set = [ones(nmb_training,1); 2*ones(nmb_images-nmb_training,1)];


% Image-Preprocessing: take the average image out
% imageMean = single(mean(dataset.images.data, 4));
% pixelMean = [sum(sum(imageMean(:,:,1),1),2) sum(sum(imageMean(:,:,2),1),2) sum(sum(imageMean(:,:,3),1),2)]/(size(imageMean,1)*size(imageMean,2))
% dataset.images.data = dataset.images.data - repmat(imageMean,[ 1 1 1 size(dataset.images.data,4) ]) ;

% Normalization
% stdev = std2(dataset.images.data);
% dataset.images.data = dataset.images.data./stdev;
% for i=1:size(dataset.images.data,4)
%    dataset.images.data(:,:,:,i) = dataset.images.data(:,:,:,i)./norm_matrix; 
% end
% dataset.images.data = vl_imsmooth(dataset.images.data,3);
% for i=1:size(dataset.images.data,4)
%    dataset.images.data(:,:,:,i) = vl_imsmooth(dataset.images.data(:,:,:,i),3); 
% end

%% SHOW SOME IMAGES


% Choose a training image
imageID = 20;

image_names{1} = dataset.images.data{imageID};

% Visualize an image
imgRGB = vl_imreadjpeg(image_names, 'NumThreads', 8);
imgDepth = dataset.images.labels(:,:,imageID);

figure(1);
% Show the RGB image.
subplot(1,2,1);
imagesc(uint8(imgRGB{1}));
axis off;
axis equal;
title('RGB');

% Show the Depth image.
subplot(1,2,2);
imagesc(single(imgDepth));
axis off;
axis equal;
title('Depth');


% Call training function in MatConvNet
[net,info] = cnn_train(net, dataset, @getBatch_meanSub, opts) ;

% Save the result for later use
net.layers(end) = [] ;
% net.imageMean = imageMean ;
save('/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/data/coarse_depth/coarsecnn.mat', '-struct', 'net') ;

