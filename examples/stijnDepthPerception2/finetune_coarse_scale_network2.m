function finetune_coarse_scale_network2()

%% Fine tunes network trained in finetune_coarse_scale_network1
%% with Gazebo sim images


%% Load data

gazebo_sim_data_ = load('/esat/emerald/pchakrav/singleImageDepthDataset/trainingImagesGazebo/gazebo_sim_training1.mat');

gazebo_sim_data = gazebo_sim_data_.gazebo_sim_dataset;

%dataset.images.data = single(gazebo_sim_data.images);
dataset1.images.labels = (double(gazebo_sim_data.labels)./80) + 0.4;
%dataset1.images.labels(:,:,:) = dataset1.images.labels(:,:,:)./80; %Normalize to between 0 and 4 m - max range of kinect

all_filenames={};


output_dir = '/esat/emerald/pchakrav/singleImageDepthDataset/trainingImagesGazebo/set1/rgb/';
for i = 1:size(gazebo_sim_data.images,4)
    %image = gazebo_sim_data.images(:,:,:,i);
    image_file_name = strcat(output_dir,'im_',sprintf('%010d',i),'.jpeg');
    %imwrite(image, image_file_name);
    all_filenames{i} = image_file_name;
end

dataset1.images.data = all_filenames;


% Subtract mean image from the dataset
imageMean = mean(gazebo_sim_data.images, 4);
%dataset.images.data = dataset.images.data - repmat(imageMean,[ 1 1 1 size(dataset.images.data,4) ]) ;
dataset1.images.image_mean = imageMean;

% Load pre-trained network
%net = load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth2/coarsecnn.mat');

net = load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/extHardDriveModel/coarsecnn.mat');
% net = net.net;

% net = load('/esat/wasat/r0300219/Thesis/net-epoch-30.mat');
% net = net.net;

varargin = struct();

opts.continue = true ;
opts.learningRate = 0.0001; % Will be multiplied with learning rate of each layer
opts.batchSize = 32 ; % Amount of images selected from the whole set
opts.numEpochs = 20; % Amount of iterations
% opts.weightDecay = 0.0007;
% opts.weightDecay = 0.007; % regularization, the larger the more emphasis on minimizing the weights (less chance on overfitting, but underfitting!) 
opts.weightDecay = 0.1;
% opts.weightDecay = 0.005;
opts.momentum = 0.9; % The lower, the higher the chance on being stuck in a local minima
opts.gpus = 1; %[] ;
% opts.gpus = [];
opts.errorFunction = 'RMSE_linear';
opts.conserveMemory = true ;

opts.expDir = 'data/coarse_depth' ;% '/esat/wasat/r0300219/Thesis/finetuned_depth_10';

opts = vl_argparse(opts, varargin);

nmb_images = numel(dataset1.images.data);
nmb_training = nmb_images; 

dataset1.images.set = [ones(nmb_training,1); 2*ones(nmb_images-nmb_training,1)];



%% Fine-tune network
[net,info] = cnn_train(net, dataset1, @getBatch_meanSub, opts);
%[net,info] = cnn_train(net, dataset, @getBatch_labeledset1, opts);

% Save the result for later use
net.layers(end) = [] ;
% net.imageMean = imageMean ;

save('/users/visics/pchakrav/Documents/MATLAB/utils/matconvnet-1.0-beta19/examples/stijnDepthPerception2/data/coarsecnn.mat', '-struct', 'net') ;
fprintf('Finished!');


