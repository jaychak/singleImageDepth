function load_many_worlds_gazebo_data()
 %% Many worlds data
 %% Jay Chakravarty 
 %% Aug 2016

root_dir = '/esat/emerald/tmp/remote_images/continuous_expert/';

dir_files = dir(root_dir);

all_filenames = {};
all_labels    = [];

data_idx=1;
for i=3:4%numel(dir_files)
    this_dir_name = dir_files(i).name;
    if numel(strfind(this_dir_name,'.txt')) == 0
        
        control_info_file_name = fullfile(root_dir,this_dir_name,'control_info.txt');
        control_info_this      = dlmread(control_info_file_name);
        for j=1:size(control_info_this,1)
            file_name = fullfile(root_dir,this_dir_name,'RGB',strcat(sprintf('%010d',control_info_this(j,1)),'..jpg'));
            if exist(file_name) ~= 0
                all_filenames{data_idx} = file_name;
                all_labels(1,data_idx) = control_info_this(j,4);
                all_labels(2,data_idx) = control_info_this(j,7);
                data_idx = data_idx + 1;
            end
        end
    end
end
dataset.images.data   = all_filenames;
dataset.images.labels = all_labels;
dataset.images.image_mean = 127*ones(360,640,3);% Change later, get real mean of data.

%% Load network (Jay fine-tuned above Stijnnet with 10k more images.) and modify last fully connected
%% layer to be a control output (2 outputs)
net =  load('/esat/emerald/pchakrav/singleImageDepthDataset/models/10Aug/coarse_depth2/coarsecnn.mat');
%% Control output
num_control_outputs = 2;
f=0.005; % Initialiaze filters on random values times f
lr = ones(2,1); % Give learning rate of filters
c2 = 0.1;
layer = struct('type', 'conv', ...
                           'weights', {{f*randn(1,1,4096,num_control_outputs, 'single'),zeros(1,num_control_outputs,'single')}},... 
                           'learningRate', c2*lr, ...
                           'stride', 1, ...
                           'pad', 0, ...
                           'rememberOutput', 1) ;
            
net.layers = horzcat(net.layers(1:21), layer) ;

layer = struct('type', 'bnorm', ...
               'weights', {{ones(num_control_outputs, 1, 'single'), zeros(num_control_outputs, 1, 'single')}}, ...
               'learningRate', [1 1 0.05], ...
               'weightDecay', [0 0], ...
                'rememberOutput', 1) ;%Layer 17

net.layers = horzcat(net.layers, layer) ;

net.layers{end+1} = struct('type', 'euclidean', ...
                           'rememberOutput', 1);
                       



%% Setup CNN parameters
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

nmb_images = numel(dataset.images.data);
nmb_training = nmb_images; 

dataset.images.set = [ones(nmb_training,1); 2*ones(nmb_images-nmb_training,1)];



%% Fine-tune network
%[net,info] = cnn_train(net, dataset, @getBatch_meanSub, opts);

[net,info] = cnn_train_control_output(net, dataset, @get_batch_continuous_output, opts);


