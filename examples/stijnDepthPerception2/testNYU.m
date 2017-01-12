%% Test all models on the NYU testset
% Stijn Wellens
% May, 2016

% Select the last 480 images as testset

%% Test the models on the ESAT testset
% Calculates also a qualitative error  
% Stijn Wellens
% May, 2016

clear;
setup_nongpu;

%% Step 1: Load images and groundtruth directions + depth maps from the ESAT testset (wasat2)

% Load all images from the NYU testset
nyudepthv2 = matfile('/esat/snake/pchakrav/datasets/singleImageDepth/NYU2/nyu_depth_v2_labeled.mat');
im = nyudepthv2.images(:,:,:,1440-480:1440); %1440
labels = nyudepthv2.depths(:,:,1440-480:1440);

% Downsampling the input
im = double(im(1:2:end,1:2:end,:,:));
labels = imresize(double(labels),[55 74]);

% Labels normalized in [0,1]
for i=1:size(labels,3)
%    labels_norm(:,:,i) = (labels(:,:,i) - min(min(labels(:,:,i))))/(max(max(labels(:,:,i))) - min(min(labels(:,:,i)))); 
    labels_min(:,i) = min(min(labels(:,:,i))) ;  
    labels_max(:,i) = max(max(labels(:,:,i)));
end

% scaling_matrix = labels./labels_norm;

%% Step 2: Use trained CNN on ESAT testset

% Load the mean image and the CNN network parameters
mean = load('/esat/wasat/r0300219/Thesis/mean_image_original.mat') ;
image_mean = mean.image_mean_part1;

%Trained with NYU Depth v2 labeled dataset
% net = load('/esat/wasat/r0300219/Thesis/original_set_case3/coarsecnn.mat');

%Trained with NYU Depth v2 labeled dataset + data augmentation
% net=load('/esat/wasat/r0300219/Thesis/net-epoch-30.mat');
% net = net.net;
% net.layers(end) = [];

%Trained with NYU Depth v2 raw dataset
% net = load('/esat/wasat/r0300219/Thesis/finetuned_depth_08/net-epoch-19.mat');
% net = net.net;
% net.layers(end) = [];

%Finetuned with ESAT trainingset
net = load('/esat/wasat/r0300219/Thesis/finetuned_esat_03/coarsecnn.mat');

% Subtract the mean image from each frame of the video
im = im - repmat(image_mean,[1 1 1 size(im,4)]); 

% Find the depth with the CNN for each frame
depth =[];
for i = 1:size(im,4)
    dzdy = [];
    res=[];
    res = vl_simplenn(net, single(im(:,:,:,i)), dzdy, res, ... 
                      'mode', 'test', ...
                      'conserveMemory', false, ...
                      'backPropDepth', +inf, ...
                      'sync', false, ...
                      'cudnn', false) ;
%     depth(:,:,i) = reshape(res(end-1).x(1,1,:),[55 74]);  
    depth(:,:,i) = reshape(res(end).x(1,1,:),[55 74]);
    depth(:,:,i) = exp(depth(:,:,i));
%     imaged = imagesc(depth(:,:,i));
%     depth(:,:,i) = (imaged.CData);
%     depth(:,:,i) = exp(1.47*depth(:,:,i)-0.1603);
end    

% Depth normalized in [0,1] and rescaled
for i=1:size(depth,3)
   depth_norm(:,:,i) = (depth(:,:,i) - min(min(depth(:,:,i))))/(max(max(depth(:,:,i))) - min(min(depth(:,:,i)))); 
   depth(:,:,i) = depth_norm(:,:,i)*(labels_max(:,i)-labels_min(:,i)) + labels_min(:,i);
end

%% Step 3: Calculate errors

RMSE = RMSE_linear(depth,labels)
RMSE_scale_inv = RMSE_log_scale_invariant(depth,labels)
abs_rel_diff = abs_rel_diff(depth, labels)
accuracy1 = threshold(depth, labels, 1.25)
accuracy2 = threshold(depth, labels, 1.25^2)
accuracy3 = threshold(depth, labels, 1.25^3)

difference = abs(labels-depth);

mean_difference = (1/55)*sum((1/74)*sum((1/481)*sum(difference,3),2),1)

%% Step 3: Show figures

figure;
for i = 1:size(im,4)
    
%     figure;
%     i=45;
    
    img = uint8(im(:,:,:,i)+image_mean);
    label = labels(:,:,i);
    dep = depth(:,:,i);
    
    bottom = min(min(min(label)),min(min(dep)));
    top = max(max(max(label)),max(max(dep)));
    
    subplot(1,3,1)
    image(img);
    axis equal    
    axis off
        
    subplot(1,3,2)
    imagesc(label);
    axis equal
    axis off 
    caxis manual
    caxis ([bottom top]);
    
    subplot(1,3,3)
    imagesc(dep);
    axis equal
    axis off  
    caxis manual
    caxis ([bottom top]);
 
    pause    
end






