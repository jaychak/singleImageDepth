%% Speedtest
% Calculates also a qualitative error  
% Stijn Wellens
% May, 2016

clear;
% setup_nongpu;
% setup_pc;

%% Step 1: Load images and groundtruth directions + depth maps from the ESAT testset (wasat2)

% Load all images from the ESAT testset
all_filenames={};
image_filenames = dir('/esat/wasat/r0300219/ESAT_dataset/testset/');
filename_idx = numel(all_filenames) + 1;
for i=1:numel(image_filenames)
    filename_this = image_filenames(i);
    if filename_this.bytes ~= 0
        all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/ESAT_dataset/testset/',filename_this.name);
        filename_idx = filename_idx + 1;
    end
end

image_idx = 1;
for i=1:numel(all_filenames)
    image_names{image_idx} = all_filenames{i};
    image_idx = image_idx + 1;
    im(:,:,:,i) = double(imread(image_names{i}));  
end

% Load labels
labels = load('/esat/wasat/r0300219/ESAT_dataset/labels_esat_testset.mat');
labels = labels.labels_processed;

% Labels normalized in [0,1]
for i=1:size(labels,3)
%    labels_norm(:,:,i) = (labels(:,:,i) - min(min(labels(:,:,i))))/(max(max(labels(:,:,i))) - min(min(labels(:,:,i)))); 
    labels_min(:,i) = min(min(labels(:,:,i))) ;  
    labels_max(:,i) = max(max(labels(:,:,i)));
end

% scaling_matrix = labels./labels_norm;

%% Step 2: Use trained CNN on ESAT testset

% Load the mean image and the CNN network parameters
imageMean = load('/esat/wasat/r0300219/Thesis/mean_image_esat.mat') ;
image_mean = imageMean.image_mean;

%Trained with NYU Depth v2 labeled dataset
% net = load('/esat/wasat/r0300219/Thesis/original_set_case3/coarsecnn.mat');

%Trained with NYU Depth v2 labeled dataset + data augmentation
% net=load('/esat/wasat/r0300219/Thesis/net-epoch-30.mat');
% net = net.net;
% net.layers(end) = [];

%Trained with NYU Depth v2 raw dataset
net = load('/esat/wasat/r0300219/Thesis/finetuned_depth_08/net-epoch-19.mat');
net = net.net;
net.layers(end) = [];

%Finetuned with ESAT trainingset
% net = load('/esat/wasat/r0300219/Thesis/finetuned_esat_03/coarsecnn.mat');

% Subtract the mean image from each frame of the video
im = im - repmat(image_mean,[1 1 1 size(im,4)]); 

% Find the depth with the CNN for each frame
depth =[];
for k = 1:500
    dzdy = [];
    res=[];
    i=1;
    tic    
    res = vl_simplenn(net, single(im(:,:,:,i)), dzdy, res, ... 
                      'mode', 'test', ...
                      'conserveMemory', true, ...
                      'backPropDepth', +inf, ...
                      'sync', false, ...
                      'cudnn', true) ;
%     depth(:,:,i) = reshape(res(end-1).x(1,1,:),[55 74]);  
    depth(:,:,i) = reshape(res(end).x(1,1,:),[55 74]);
    depth(:,:,i) = exp(depth(:,:,i));
    time(k) = toc;
%     imaged = imagesc(depth(:,:,i));
%     depth(:,:,i) = (imaged.CData);
%     depth(:,:,i) = exp(1.47*depth(:,:,i)-0.1603);
end  

avg_time = mean(time)