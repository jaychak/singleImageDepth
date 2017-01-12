% Display depth maps on test data using learnt network (initial + flipped
% data)
% Jay Chakravarty
% Jan 2016

%% Load network
clear;
% setup;
setup_nongpu;

% net=load('/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/data/coarse_depth/coarsecnn.mat'); %My network
% net=load('/esat/wasat/r0300219/Thesis/finetuned_depth/finetuned_01.mat');
% net = load('/esat/wasat/r0300219/Thesis/net-epoch-30.mat');
% net = net.net;
% net.layers(end) = [] ;
% net=load('/users/visics/pchakrav/Documents/MATLAB/utils/matconvnet-1.0-beta17/examples/stijnDepthPerception/data/coarse_depth/net-epoch-15.mat');%Stijn
% net=load('/users/start2013/r0300219/Documents/Thesis/data_case11/coarsecnn.mat'); %My network

% % Load data
% nyudepthv2 = matfile('/esat/ophelia/NYUdataset/nyu_depth_v2_labeled.mat');

%% Load labels
nyudepth_augmented_labels = load('/esat/emerald/pchakrav/singleImageDepthDataset/allLabels/labels_flip_rot_rand_crop.mat');
% labels = nyudepth_augmented_labels.labels_orig_flipped_test;
labels_set = nyudepth_augmented_labels.labels_all;

image_filenames = dir('/esat/emerald/pchakrav/singleImageDepthDataset/meanSubtractedFlippedRotatedRandomCrop/');
all_filenames={};
filename_idx = 1;
for i=1:numel(image_filenames)
    filename_this = image_filenames(i);
    if filename_this.bytes ~= 0
        all_filenames{filename_idx} = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/meanSubtractedFlippedRotatedRandomCrop/',filename_this.name);
        filename_idx = filename_idx + 1;
    end
end

amountOfImages = 10;
% image_idx = 1;
% for i=1:amountOfImages
%     image_names{image_idx} = all_filenames{60000-i};
%     image_idx = image_idx + 1;
% end
% 
% im1 = vl_imreadjpeg(image_names, 'NumThreads', 8);
% 
% for i=1:numel(im1)
%     im(:,:,:,i) = im1{i};
% end

% im(:,:,:,1) = imread(all_filenames{1});
% labels(:,:,1) = labels_set(:,:,1);

% Showing data augmentation
% im(:,:,:,2) = imread(all_filenames{1921});
% im(:,:,:,3) = imread(all_filenames{1922});
% im(:,:,:,4) = imread(all_filenames{1923});
% im(:,:,:,5) = imread(all_filenames{1924});
% im(:,:,:,6) = imread(all_filenames{1925});
% im(:,:,:,7) = imread(all_filenames{1926});
% im(:,:,:,8) = imread(all_filenames{1927});
% im(:,:,:,9) = imread(all_filenames{1928});
% im(:,:,:,10) = imread(all_filenames{1929});
% im(:,:,:,1) = imread(all_filenames{1930});
% 
% labels(:,:,2) = labels_set(:,:,1921);
% labels(:,:,3) = labels_set(:,:,1922);
% labels(:,:,4) = labels_set(:,:,1923);
% labels(:,:,5) = labels_set(:,:,1924);
% labels(:,:,6) = labels_set(:,:,1925);
% labels(:,:,7) = labels_set(:,:,1926);
% labels(:,:,8) = labels_set(:,:,1927);
% labels(:,:,9) = labels_set(:,:,1928);
% labels(:,:,10) = labels_set(:,:,1929);
% labels(:,:,1) = labels_set(:,:,1930);


% Dividing training and validation data
nmb_images = 60000; %2400;%12000;%size(dataset.images.data,4);
nmb_training = 59520; %1920;%11520;%ceil(tr*nmb_images);
nmb_results = 10;

mean = load('/esat/wasat/r0300219/Thesis/mean_image_original.mat');
image_mean = mean.image_mean_part1;

figure;
for i=1:amountOfImages%nmb_training+1:nmb_training+nmb_results%+1:nmb_images
    
%     image_filename = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/meanSubtractedFlippedRotatedRandomCrop/', num2str(i,'%05d'), '.jpeg');
%     image = im2single(imread(image_filename));
    image = single(im(:,:,:,i));
    
    
    h =  subplot(5,4,i*2-1);
    imagesc(uint8(image+image_mean));
    %imagesc(im(:,:,:,1));
    axis off;
%     axis equal;
% %     title('RGB');

    h = subplot(5,4,i*2);
    imagesc(labels(:,:,i));
    axis off;
%     axis equal;
% %     title('Depth groundtruth');
    
%     dzdy = [];
%     res=[];
%     res = vl_simplenn(net, image, dzdy, res, ... 
%                       'mode', 'test', ...
%                       'conserveMemory', false, ...
%                       'backPropDepth', +inf, ...
%                       'sync', false, ...
%                       'cudnn', false) ;
%                   
% %     output = reshape(res(end-1).x(1,1,:),[55 74]);
%     
%     output = reshape(res(end).x(1,1,:),[55 74]);
%     
%     
%     subplot(1,3,3);
%     %imagesc(uint8(output));
%     imagesc(output);
%     axis off;
%     axis equal;
%     title('Estimated depth map');
    
%     pause;
end
    
 