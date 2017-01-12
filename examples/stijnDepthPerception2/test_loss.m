%% A script to test the functioning of the loss calculation

clear;

% Load NYUdepth dataset
% dataset = load('data/nyu_depth_v2_labeled.mat','images','depths') ;
nyudepthv2 = matfile('data/nyu_depth_v2_labeled.mat');
dataset.images = nyudepthv2.images(:,:,:,1:3);
dataset.depths = nyudepthv2.depths(:,:,1:3);

% Choose a training image
imageID = 1;

% Visualize an image
imgRGB = dataset.images(:,:,:,imageID);
imgDepth = dataset.depths(:,:,imageID);

img = single(rgb2gray(imgRGB));

% Factor for adding wgn
f = 2;

imgD_error = imgDepth + f*randn(size(img,1),size(img,2));

L = loss_layer(imgDepth,imgD_error);
fprintf('The calculated loss in the loss layer is: %d\n',L);