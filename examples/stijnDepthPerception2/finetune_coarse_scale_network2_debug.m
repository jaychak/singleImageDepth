function finetune_coarse_scale_network2_debug()

%% GET THE DATA
all_dirs = dir('/esat/wasat/r0300219/NYUv2/processed/');
dir_list={};
for ii=1:numel(all_dirs)
    dir_this = all_dirs(ii);
    if(~isempty(strfind(dir_this.name,'imgs')))
          C = strsplit(dir_this.name,'_');
          nmb = str2num(C{2});
          dir_list{nmb} = strcat('/esat/wasat/r0300219/NYUv2/processed/',dir_this.name,'/');
    end
end

% Use only the directories we want
wanted_dirs = [1,2];%[1,2,3,4,6,7,8,9,10,11,12,13,14,16,17,18,19];
% wanted_dirs = [23];
tmp_dir_list = {};
for ii=1:numel(dir_list)
   if ismember(ii,wanted_dirs)
       tmp_dir_list{end+1} = dir_list{ii};
   end
end

dir_list = tmp_dir_list;

all_filenames={};
for ii=1:numel(dir_list)
    if(~isempty(dir_list{ii}))
        image_filenames = dir(dir_list{ii});
        filename_idx = numel(all_filenames) + 1;
        for i=1:numel(image_filenames)
            filename_this = image_filenames(i);
            if filename_this.bytes ~= 0
                all_filenames{filename_idx} = strcat(dir_list{ii},filename_this.name);
                filename_idx = filename_idx + 1;
            end
        end
    end
end

% Load label files out order
all_labeldirs = dir('/esat/wasat/r0300219/NYUv2/processed/labels_filled_proc/');
label_filenames={};
filename_idx = 1;
for i=1:numel(all_labeldirs)
    filename_this = all_labeldirs(i);
    if (filename_this.bytes ~= 0 && isempty(strfind(filename_this.name,'esat')))
        label_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/labels_filled_proc/',filename_this.name);
        C = strsplit(filename_this.name,'_');
        D = strsplit(C{3},'.');
        label_dirs(filename_idx) = str2num(C{2}); % folder number
        label_numbers(filename_idx) = str2num(D{1}); % number of all labels till that file
        filename_idx = filename_idx + 1;
    end
end

% Select labels from only the wanted directories
for ii=1:numel(label_dirs)
   if ismember(label_dirs(ii),wanted_dirs)
       mask(ii) = 1;
   else
       mask(ii) = 0;
   end
end

label_filenames = label_filenames(mask==1);
label_dirs = label_dirs(mask==1);
label_numbers = label_numbers(mask==1);

% Order label files.
label_dirs2 = label_dirs;
[label_dirs2, index] = sort(label_dirs2,'ascend');
label_filenames2 = label_filenames(index);
label_numbers2 = label_numbers(index);

% Find begin directory and end directory
folder_nmb_min = label_dirs2(1);
folder_nmb_max = label_dirs2(end);

% Sort all label files of the same directory
folder_nmb = folder_nmb_min;
start = 1;
label_imgnumbers(1) = 0;
for i=1:numel(label_filenames2)
   if(folder_nmb == label_dirs2(i))
      
   else
      [label_numbers2(start:(i-1)), index] = sort(label_numbers2(start:(i-1)),'ascend');
      tmp_labels = label_filenames2(start:(i-1));
      label_filenames2(start:(i-1)) = tmp_labels(index);
      
      for ii=start:i-1
          label_imgnumbers(end+1) = label_imgnumbers(start) + label_numbers2(ii) - 1;
      end
      
      folder_nmb = label_dirs2(i);
      start = i;
   end
end

% Do it the last time
i = i +1;

[label_numbers2(start:(i-1)), index] = sort(label_numbers2(start:(i-1)),'ascend');
tmp_labels = label_filenames2(start:(i-1));
label_filenames2(start:(i-1)) = tmp_labels(index);

for ii=start:i-1
  label_imgnumbers(end+1) = label_imgnumbers(start) + label_numbers2(ii) - 1;
end

label_imgnumbers = label_imgnumbers(2:end);

numel(label_filenames2)
numel(all_filenames)

% Load all labels at once -- fast alternative/lots of memory needed
tic
labels = zeros(55,74,numel(all_filenames));
lastl= 0;
for i=1:numel(label_filenames2)
    all_labels = load(label_filenames2{i});
    all_labels = all_labels.labels_processed;
    labels(:,:,lastl+1:lastl+size(all_labels,3)) = all_labels;
    lastl = lastl+size(all_labels,3)
end
toc

% Network trained by Stijn
net = load('/esat/wasat/r0300219/Thesis/net-epoch-30.mat');
net = net.net;
% Network trained by Jay
% net = load('/users/visics/pchakrav/Documents/MATLAB/utils/matconvnet-1.0-beta19/examples/stijnDepthPerception2/data/coarse_depth1/coarsecnn.mat');


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

% opts.expDir = '/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/data/coarse_depth' ;
opts.expDir = 'data/coarse_depth' ;% '/esat/wasat/r0300219/Thesis/finetuned_depth_10';

opts = vl_argparse(opts, varargin);



nmb_images = 100; %10000
nmb_training = 100; %10000

fprintf('Shuffling filenames ... \n');
shuffle_index = randperm(nmb_images);% randperm(numel(all_filenames));
all_filenames = all_filenames(shuffle_index);
labels = labels(:,:,shuffle_index);


fprintf('Loading all images and labels to dataset.images ... \n');
tic
dataset.images.data   = all_filenames(1:nmb_images);%images_resized;
%dataset.images.labels = labels_resized;
dataset.images.labels = labels(:,:,1:nmb_images);
toc
fprintf('Finished loading images and labels. \n');

% Divide the set of images in training images and validation images in a
% 'random way'
dataset.images.set = [ones(nmb_training,1); 2*ones(nmb_images-nmb_training,1)];

imageMean = load('/esat/wasat/r0300219/Thesis/mean_image_NYUv2.mat') ;
dataset.images.image_mean = imageMean.image_mean;


% dataset3.images.data = dataset.images.data(1:100);%rgb from stijn
% dataset3.images.labels=dataset1.images.labels(:,:,1:100);%depth from gazebo
% dataset3.images.image_mean = dataset1.images.image_mean;
% dataset3.images.set = dataset2.images.set;

%[net,info] = cnn_train(net, dataset, @getBatch_meanSub, opts) ;
[net,info] = cnn_train(net, dataset, @getBatch_meanSub, opts) ;

% Save the result for later use
net.layers(end) = [] ;
% net.imageMean = imageMean ;

save('/users/visics/pchakrav/Documents/MATLAB/utils/matconvnet-1.0-beta19/examples/stijnDepthPerception2/data/coarsecnn.mat', '-struct', 'net') ;
fprintf('Finished!');



