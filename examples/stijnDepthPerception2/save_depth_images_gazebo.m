function save_depth_images_gazebo()

%% Load network and data

% Jay trained with 1400 images
% net = load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth1/coarsecnn.mat');

% Stij trained
% net1 = load('/esat/wasat/r0300219/Thesis/net-epoch-30.mat');
% net = net1.net;

% Jay fine-tuned above Stijnnet with 10k more images.
net =  load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth2/coarsecnn.mat');
% Jay fine-tuned on Gazebo sim data (2500 images).
%net1 = load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth3/coarsecnn.mat');


set_number = 'set_7';
rgb_dir = strcat('/esat/qayd/tmp/remote_images/',set_number,'/RGB/');
output_dir = strcat('/esat/qayd/tmp/remote_images/',set_number,'/cnn_features/');

rgb_filenames = dir(rgb_dir);

features=[];
for i=3:numel(rgb_filenames)
    rgb_filename = rgb_filenames(i).name;
    im = imread(fullfile(rgb_dir,rgb_filename));
    im_ = imresize(im, [240,320]);
    subplot(1,2,1);
    imagesc(im_);
    
 
    dzdy = [];
    res = [];
   
    res = vl_simplenn(net, single(im_), dzdy, res, ... 
                      'mode', 'test', ...
                      'conserveMemory', false, ...
                      'backPropDepth', +inf, ...
                      'sync', false, ...
                      'cudnn', false) ;%);

                      
    %output = reshape(res(end-1).x(1,1,:,1),[55 74]);
    output = reshape(res(end).x(1,1,:,1),[55 74]);
    
    depth_this = reshape(res(end).x(1,1,:,1),[1 4070]);
    features = cat(1,features,depth_this);
    subplot(1,2,2);
    imagesc(output);
                      
                  
    pause(0.005);
    
end
save(strcat(output_dir,'stijn_depth_image_',set_number,'.mat'),'features');

