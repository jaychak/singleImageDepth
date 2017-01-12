% clear;

addpath('/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/matconvnet-1.0-beta19/');
addpath(genpath('/usr/local/cuda-7.5')); % cuda 7.5
addpath(genpath('/users/start2013/r0300219/Documents/Thesis/cuda')); %cuDNN genpath = to add subfolders

% setup; %Stijn: setup should be done before compiling this with mcc
% setup_nongpu;

%% GET THE DATA

% Load all images from the ESAT testset
all_filenames={};
image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_esat_filled/');
filename_idx = numel(all_filenames) + 1;
for i=1:numel(image_filenames)
    filename_this = image_filenames(i);
    if filename_this.bytes ~= 0
        all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images_esat_filled/',filename_this.name);
        filename_idx = filename_idx + 1;
    end
end

% Load label files out order
all_labeldirs = dir('/esat/wasat/r0300219/NYUv2/processed/labels_filled_proc/');
label_filenames={};
filename_idx = 1;
for i=1:numel(all_labeldirs)
    filename_this = all_labeldirs(i);
    if (filename_this.bytes ~= 0 && ~isempty(strfind(filename_this.name,'esat')))
        label_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/labels_filled_proc/',filename_this.name);
        C = strsplit(filename_this.name,'_');
        D = strsplit(C{3},'.');
%         label_dirs(filename_idx) = str2num(C{2}); % folder number
        label_numbers(filename_idx) = str2num(D{1}); % number of all labels till that file
        filename_idx = filename_idx + 1;
    end
end

% Sort all label files of the same directory
start = 1;
label_imgnumbers(1) = 0;

[label_numbers, index] = sort(label_numbers,'ascend');
label_filenames = label_filenames(index);


numel(label_filenames)
numel(all_filenames)
% Load all labels at once -- fast alternative/lots of memory needed
tic
labels = zeros(55,74,numel(all_filenames));
lastl= 0;
for i=1:numel(label_filenames)
    all_labels = load(label_filenames{i});
    all_labels = all_labels.labels_processed;
    labels(:,:,lastl+1:lastl+size(all_labels,3)) = all_labels;
    lastl = lastl+size(all_labels,3)
end
toc

%% INITIALIZE CNN ARCHITECTURE

% net = initializeCoarseCNN();
% net = vl_simplenn_tidy(net);

% net = load('/esat/wasat/r0300219/Thesis/net-epoch-30.mat');
net = load('/esat/wasat/r0300219/Thesis/finetuned_depth_08/net-epoch-19.mat');
net = net.net;

% net.layers{end+1} = struct('type', 'lossEigen');
                       
%% TRAIN CNN

varargin = struct();

opts.continue = true ;
opts.learningRate = 0.00001; % Will be multiplied with learning rate of each layer
opts.batchSize = 32 ; % Amount of images selected from the whole set
opts.numEpochs = 20; % Amount of iterations
% opts.weightDecay = 0.0007;
% opts.weightDecay = 0.007; % regularization, the larger the more emphasis on minimizing the weights (less chance on overfitting, but underfitting!) 
opts.weightDecay = 0.05;
% opts.weightDecay = 0.005;
opts.momentum = 0.9; % The lower, the higher the chance on being stuck in a local minima
opts.gpus = 1; %[] ;
% opts.gpus = [];
opts.errorFunction = 'RMSE_linear';
opts.conserveMemory = true ;

% opts.expDir = '/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/data/coarse_depth' ;
opts.expDir = '/esat/wasat/r0300219/Thesis/finetuned_esat_03';

opts = vl_argparse(opts, varargin);

nmb_images = 22080;
nmb_training = 14720;

% Remove testset ESAT wasat2
all_filenames(17911:18582) = [];
labels(:,:,17911:18582) = [];

shuffle_index = randperm(numel(all_filenames));
all_filenames = all_filenames(shuffle_index);
labels = labels(:,:,shuffle_index);

dataset.images.data   = all_filenames(1:nmb_images);
dataset.images.labels = labels(:,:,1:nmb_images);

dataset.images.set = [ones(nmb_training,1); 2*ones(nmb_images-nmb_training,1)];

% imageMean = load('/esat/wasat/r0300219/Thesis/mean_image_01.mat') ;
imageMean = load('/esat/wasat/r0300219/Thesis/mean_image_esat.mat') ;
dataset.images.image_mean = imageMean.image_mean;

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

%
% % Choose a training image
% imageID = 999;
% 
% image_names{1} = dataset.images.data{imageID};
% 
% % Visualize an image
% imgRGB = vl_imreadjpeg(image_names, 'NumThreads', 8);
% imgDepth = dataset.images.labels(:,:,imageID);
% 
% figure(1);
% % Show the RGB image.
% subplot(1,2,1);
% imagesc(uint8(imgRGB{1}));
% axis off;
% axis equal;
% title('RGB');
% 
% % Show the Depth image.
% subplot(1,2,2);
% imagesc(single(imgDepth));
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

% Call training function in MatConvNet
[net,info] = cnn_train(net, dataset, @getBatch_meanSub, opts) ;

% Save the result for later use
net.layers(end) = [] ;
% net.imageMean = imageMean ;

save('/esat/wasat/r0300219/Thesis/finetuned_esat_03/coarsecnn.mat', '-struct', 'net') ;
fprintf('Finished!');


