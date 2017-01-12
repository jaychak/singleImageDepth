% Display depth maps on test data using learnt network (initial + flipped
% data)
% Jay Chakravarty
% Jan 2016

%% Load network
clear;
setup_nongpu;

% net=load('/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/data/coarse_depth/coarsecnn.mat'); %My network
net=load('data/coarse_depth/coarsecnn.mat'); %My network
% net = net.net;
% net=load('/users/visics/pchakrav/Documents/MATLAB/utils/matconvnet-1.0-beta17/examples/stijnDepthPerception/data/coarse_depth/net-epoch-15.mat');%Stijn

% % Load data
% nyudepthv2 = matfile('/esat/ophelia/NYUdataset/nyu_depth_v2_labeled.mat');

%% Load labels
% nyudepth_augmented_labels = load('/esat/emerald/pchakrav/singleImageDepthDataset/allLabels/labels_flip_rot_rand_crop.mat');
% labels = nyudepth_augmented_labels.labels_orig_flipped_test;
% labels = nyudepth_augmented_labels.labels_all;

image_filenames = dir('../meanSubtractedFlippedRotatedRandomCrop');
all_filenames={};
filename_idx = 1;
for i=1:numel(image_filenames)
    filename_this = image_filenames(i);
    if filename_this.bytes ~= 0
        all_filenames{filename_idx} = strcat('../meanSubtractedFlippedRotatedRandomCrop/',filename_this.name);
        filename_idx = filename_idx + 1;
    end
end

amountOfImages = 10;
image_idx = 1;
for i=1:amountOfImages
    image_names{image_idx} = all_filenames{i};
    image_idx = image_idx + 1;
end

im1 = vl_imreadjpeg(image_names, 'NumThreads', 8);
im =[];
for i=1:numel(im1)
    im(:,:,:,i) = im1{i};
end

% Dividing training and validation data
nmb_images = 60000; %2400;%12000;%size(dataset.images.data,4);
nmb_training = 59520; %1920;%11520;%ceil(tr*nmb_images);
nmb_results = 10;

for i=1:amountOfImages%nmb_training+1:nmb_training+nmb_results%+1:nmb_images
    
%     image_filename = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/meanSubtractedFlippedRotatedRandomCrop/', num2str(i,'%05d'), '.jpeg');
%     image = im2single(imread(image_filename));
    image = single(im(:,:,:,i));
    
    figure;
    subplot(1,3,1);
    imagesc(uint8(image));
    %imagesc(im(:,:,:,1));
    axis off;
    axis equal;
    title('RGB - mean');

%     subplot(1,3,2);
%     imagesc(labels(:,:,i));
%     axis off;
%     axis equal;
%     title('Depth groundtruth');
    
    dzdy = [];
    res=[];
    res = vl_simplenn(net, image, dzdy, res, ... 
                      'mode', 'test', ...
                      'conserveMemory', false, ...
                      'backPropDepth', +inf, ...
                      'sync', false, ...
                      'cudnn', false) ;%);
    %                       'accumulate', s ~= 1, ...
    
    output = reshape(res(end-1).x(1,1,:),[55 74]);
    
    %output = reshape(res(end).x(1,1,:),[55 74]);
    
    
    subplot(1,3,3);
    %imagesc(uint8(output));
    imagesc(output);
    axis off;
    axis equal;
    title('Depth prediction');
    
%     pause;
end
    
 