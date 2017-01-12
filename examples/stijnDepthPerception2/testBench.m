%% Testbench for testing the trained network
clear;
setup_nongpu;

% load('data/coarse_depth/last_it.mat');
net = load('data/coarse_depth/coarsecnn.mat');

% Load specified amount of test images
nmb_test = 10;
% nyudepthv2 = matfile('/esat/snake/pchakrav/datasets/singleImageDepth/NYU2/nyu_depth_v2_labeled.mat');
nyudepthv2 = matfile('data/coarse_depth/nyu_depth_v2_labeled.mat');
dataset.images.data = nyudepthv2.images(:,:,:,end-nmb_test:end);
dataset.images.labels = nyudepthv2.depths(:,:,end-nmb_test:end);

% Load image mean
load('data/coarse_depth/mean_image.mat');

%% Testing the model

for i=1:nmb_test
    
    %Input image
%     image = vl_imreadjpeg(dataset.images.data(:,:,:,i), 'NumThreads', 8);
    image = dataset.images.data(:,:,:,i);
    image_mean_subtracted = image - image_mean_orig;
    im = uint8(image_mean_subtracted);
    
%     im = dataset.images.data(:,:,:,i);
    im = squeeze(im(1:2:end,1:2:end,:));

%     im = im - single(net.imageMean);
%     im = im - single(image_mean_orig);
    
    figure;
    subplot(1,3,1);
    imagesc(im);
    axis off;
    axis equal;
    title('RGB - mean');
    
    %Label
    subplot(1,3,2);
    imagesc(dataset.images.labels(:,:,i));
    axis off;
    axis equal;
    title('Depth groundtruth');
    
    %Estimated depth map
    dzdy = [];
    res=[];
    res = vl_simplenn(net, im, dzdy, res);
    
    output = reshape(res(end-1).x(1,1,:),[55 74]);
    subplot(1,3,3);
    imagesc(output);
    axis off;
    axis equal;
    title('Estimated depth map');
end




%% Look at the validation results of the last iteration

% img_number = 13;
% 
% figure;
% subplot(1,3,1);
% imagesc(im(:,:,:,img_number));
% axis off;
% axis equal;
% title('RGB - mean');
% 
% subplot(1,3,2);
% imagesc(labels(:,:,img_number));
% axis off;
% axis equal;
% title('Depth groundtruth');
% 
% output =reshape(res(end-1).x(1,1,:,img_number),[55 74]);
% subplot(1,3,3);
% % imagesc(exp(output));
% imagesc(output);
% axis off;
% axis equal;
% title('Validation: Depth prediction');