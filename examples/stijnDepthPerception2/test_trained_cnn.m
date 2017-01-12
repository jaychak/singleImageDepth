function test_trained_cnn()

%% Load network and data

% Jay trained with 1400 images
% net = load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth1/coarsecnn.mat');

% Stij trained
% net1 = load('/esat/wasat/r0300219/Thesis/net-epoch-30.mat');
% net = net1.net;

% Jay fine-tuned above Stijnnet with 10k more images.
%net = load('/users/visics/pchakrav/Documents/MATLAB/utils/matconvnet-1.0-beta19/examples/stijnDepthPerception2/data/coarsecnn.mat');
net = load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth2/coarsecnn.mat');
nyudepthv2 = matfile('/esat/snake/pchakrav/datasets/singleImageDepth/NYU2/nyu_depth_v2_labeled.mat');

num_images = 100;
dataset.images.data = single(nyudepthv2.images(:,:,:,1:num_images)); %1440
dataset.images.labels = nyudepthv2.depths(:,:,1:num_images);

dataset.images.data = dataset.images.data(1:2:end,1:2:end,:,:);


opts.conserveMemory = true ;
opts.backPropDepth = +inf ;

opts.sync = false ;
opts.cudnn = true ;


for i=1:num_images
    
    im = dataset.images.data(:,:,:,i);
    subplot(1,3,1);
    imagesc(uint8(im));
    
    labels = dataset.images.labels(:,:,i);
    labels = single(imresize(labels,[55 74]));
    
    subplot(1,3,2);
    imagesc(labels);
    
    dzdy = [] ;
    evalMode = 'test' ;
    res = [] ;
    %res = vl_simplenn(net, im);
    
    res = vl_simplenn(net, im, dzdy, res, ... 
                      'mode', 'test', ...
                      'conserveMemory', false, ...
                      'backPropDepth', +inf, ...
                      'sync', false, ...
                      'cudnn', false) ;%);

                      
    %output = reshape(res(end-1).x(1,1,:,1),[55 74]);
    output = reshape(res(end).x(1,1,:,1),[55 74]);
    subplot(1,3,3);
    imagesc(output);
    axis off;
    axis equal;
    title('Validation: Depth prediction');
    
    pause();
                      
                      
end
