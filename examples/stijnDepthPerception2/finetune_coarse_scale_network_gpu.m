% clear;

addpath('/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/matconvnet-1.0-beta19/');
addpath(genpath('/usr/local/cuda-7.5')); % cuda 7.5
addpath(genpath('/users/start2013/r0300219/Documents/Thesis/cuda')); %cuDNN genpath = to add subfolders

% setup; %Stijn: setup should be done before compiling this with mcc
% setup_nongpu;

%% GET THE DATA

% labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_esat_2.mat');
% labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_01.mat');
% labels = labels_fullset.labels_processed;

% nyudepth_labels = cat(3, nyudepth_labels, nyudepth_labels2);

% Find all directories with images in one directory
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
wanted_dirs = [1,2,3,4,6,7,8,9,10,11,12,13,14,16,17,18,19];
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

% % Now, assign a label to each image
% index_labelnumber = 1;
% all_labelnames = {};
%     % all_labelnumbers_dir gives the index of the label in a certain label
%     % file per image
% k = 0;
% for i=1:numel(all_filenames)
%     if i <= label_imgnumbers(index_labelnumber)
%         k = k + 1; 
%         all_labelnames{i} = label_filenames2{index_labelnumber};
%         all_labelnumbers_dir(i) = k;               
%     else
%        k = 1; 
%        index_labelnumber = index_labelnumber + 1;
%        all_labelnames{i} = label_filenames2{index_labelnumber};
%        all_labelnumbers_dir(i) = k;       
%     end
% end

% image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_esat');
% all_filenames={};
% filename_idx = 1;
% for i=1:numel(image_filenames)
%     filename_this = image_filenames(i);
%     if filename_this.bytes ~= 0
%         all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images_esat/',filename_this.name);
%         filename_idx = filename_idx + 1;
%     end
% end

%% INITIALIZE CNN ARCHITECTURE

% net = initializeCoarseCNN();
% net = vl_simplenn_tidy(net);

net = load('/esat/wasat/r0300219/Thesis/net-epoch-30.mat');
net = net.net;

% net.layers{end+1} = struct('type', 'lossEigen');
                       
%% TRAIN CNN

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
opts.expDir = '/esat/wasat/r0300219/Thesis/finetuned_depth_10';

opts = vl_argparse(opts, varargin);

% Downsampling the input
% dataset.images.data = dataset.images.data(1:2:end,1:2:end,:,:);
% dataset.images.labels = single(dataset.images.labels(1:2:end,1:2:end,:,:));

% Dividing training and validation data
% tr = 2/3; 
% tr = 4/5;
% nmb_images = size(dataset.images.data,4);
% nmb_training = ceil(tr*nmb_images);
% dataset.images.set = [ones(nmb_training,1); 2*ones(nmb_images-nmb_training,1)];

nmb_images = 314432; %43648; %314432; %217664; %231072; %43648; %18272;%size(dataset.images.data,4);
nmb_training = 314432; %201088; %42048; %209600; %201088; %42048; %17312;%ceil(tr*nmb_images);

shuffle_index = randperm(numel(all_filenames));
all_filenames = all_filenames(shuffle_index);
labels = labels(:,:,shuffle_index);


dataset.images.data   = all_filenames(1:nmb_images);%images_resized; % TAKES VERY LONG!!!
%dataset.images.labels = labels_resized;
dataset.images.labels = labels(:,:,1:nmb_images);
% dataset.images.labels = all_labelnames(1:nmb_images);
% dataset.images.labelindex = all_labelnumbers_dir(1:nmb_images);

% Divide the set of images in training images and validation images in a
% 'random way'
dataset.images.set = [ones(nmb_training,1); 2*ones(nmb_images-nmb_training,1)];

% imageMean = load('/esat/wasat/r0300219/Thesis/mean_image_01.mat') ;
imageMean = load('/esat/wasat/r0300219/Thesis/mean_image_NYUv2.mat') ;
dataset.images.image_mean = imageMean.image_mean;

% Image-Preprocessing: take the average image out
% imageMean = single(mean(dataset.images.data, 4));
% pixelMean = [sum(sum(imageMean(:,:,1),1),2) sum(sum(imageMean(:,:,2),1),2) sum(sum(imageMean(:,:,3),1),2)]/(size(imageMean,1)*size(imageMean,2))
% dataset.images.data = dataset.images.data - repmat(imageMean,[ 1 1 1 size(dataset.images.data,4) ]) ;

% Normalization
% stdev = std2(dataset.images.data);
% dataset.images.data = dataset.images.data./stdev;
% for i=1:size(dataset.images.data,4)
%    dataset.images.data(:,:,:,i) = dataset.images.data(:,:,:,i)./norm_matrix; 
% end
% dataset.images.data = vl_imsmooth(dataset.images.data,3);
% for i=1:size(dataset.images.data,4)
%    dataset.images.data(:,:,:,i) = vl_imsmooth(dataset.images.data(:,:,:,i),3); 
% end

%% SHOW SOME IMAGES

%
% % Choose a training image
% imageID = 999;
% 
% image_names{1} = dataset.images.data{imageID};
% 
% % Visualize an image
% imgRGB = vl_imreadjpeg(image_names, 'NumThreads', 8);
% imgDepth = dataset.images.labels(:,:,imageID);
% 
% figure(1);
% % Show the RGB image.
% subplot(1,2,1);
% imagesc(uint8(imgRGB{1}));
% axis off;
% axis equal;
% title('RGB');
% 
% % Show the Depth image.
% subplot(1,2,2);
% imagesc(single(imgDepth));
% axis off;
% axis equal;
% title('Depth');

% % Choose a training image
% imageID = 51;
% 
% % Visualize an image
% imgRGB = dataset.images.data(:,:,:,imageID);
% imgDepth = dataset.images.labels(:,:,imageID);
% 
% figure(2);
% % Show the RGB image.
% subplot(1,2,1);
% imagesc(imgRGB);
% axis off;
% axis equal;
% title('RGB');
% 
% % Show the Depth image.
% subplot(1,2,2);
% imagesc(imgDepth);
% axis off;
% axis equal;
% title('Depth');

% Call training function in MatConvNet
[net,info] = cnn_train(net, dataset, @getBatch_meanSub, opts) ;

% Save the result for later use
net.layers(end) = [] ;
% net.imageMean = imageMean ;

save('/esat/wasat/r0300219/Thesis/finetuned_depth_10/coarsecnn.mat', '-struct', 'net') ;
fprintf('Finished!');


