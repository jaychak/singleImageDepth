%% Test the models on the ESAT testset
% Calculates also a qualitative error  
% Stijn Wellens
% May, 2016

clear;
setup_nongpu;

%% Step 1: Load images and groundtruth directions + depth maps from the ESAT testset (wasat2)

% Load all images from the ESAT testset
all_filenames={};
image_filenames = dir('/esat/wasat/r0300219/ESAT_dataset/testset/');
filename_idx = numel(all_filenames) + 1;
for i=1:numel(image_filenames)
    filename_this = image_filenames(i);
    if filename_this.bytes ~= 0
        all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/ESAT_dataset/testset/',filename_this.name);
        filename_idx = filename_idx + 1;
    end
end

image_idx = 1;
for i=1:numel(all_filenames)
    image_names{image_idx} = all_filenames{i};
    image_idx = image_idx + 1;
    im(:,:,:,i) = double(imread(image_names{i}));  
end

% Load labels
labels = load('/esat/wasat/r0300219/ESAT_dataset/labels_esat_testset.mat');
labels = labels.labels_processed;

% Labels normalized in [0,1]
for i=1:size(labels,3)
%    labels_norm(:,:,i) = (labels(:,:,i) - min(min(labels(:,:,i))))/(max(max(labels(:,:,i))) - min(min(labels(:,:,i)))); 
    labels_min(:,i) = min(min(labels(:,:,i))) ;  
    labels_max(:,i) = max(max(labels(:,:,i)));
end

% scaling_matrix = labels./labels_norm;

%% Step 2: Use trained CNN on ESAT testset

% Load the mean image and the CNN network parameters
imageMean = load('/esat/wasat/r0300219/Thesis/mean_image_esat.mat') ;
image_mean = imageMean.image_mean;

%Trained with NYU Depth v2 labeled dataset
% net = load('/esat/wasat/r0300219/Thesis/original_set_case3/coarsecnn.mat');

%Trained with NYU Depth v2 labeled dataset + data augmentation
% net=load('/esat/wasat/r0300219/Thesis/net-epoch-30.mat');
% net = net.net;
% net.layers(end) = [];

%Trained with NYU Depth v2 raw dataset
net = load('/esat/wasat/r0300219/Thesis/finetuned_depth_08/net-epoch-19.mat');
net = net.net;
net.layers(end) = [];

%Finetuned with ESAT trainingset
% net = load('/esat/wasat/r0300219/Thesis/finetuned_esat_03/coarsecnn.mat');

% Subtract the mean image from each frame of the video
im = im - repmat(image_mean,[1 1 1 size(im,4)]); 

% Find the depth with the CNN for each frame
depth =[];
for i = 1:size(im,4)
    dzdy = [];
    res=[];
    tic
    i=1
    res = vl_simplenn(net, single(im(:,:,:,i)), dzdy, res, ... 
                      'mode', 'test', ...
                      'conserveMemory', false, ...
                      'backPropDepth', +inf, ...
                      'sync', false, ...
                      'cudnn', false) ;
%     depth(:,:,i) = reshape(res(end-1).x(1,1,:),[55 74]);  
    depth(:,:,i) = reshape(res(end).x(1,1,:),[55 74]);
    depth(:,:,i) = exp(depth(:,:,i));
    toc
%     imaged = imagesc(depth(:,:,i));
%     depth(:,:,i) = (imaged.CData);
%     depth(:,:,i) = exp(1.47*depth(:,:,i)-0.1603);
end    

% Depth normalized in [0,1]
for i=1:size(depth,3)
   depth_norm(:,:,i) = (depth(:,:,i) - min(min(depth(:,:,i))))/(max(max(depth(:,:,i))) - min(min(depth(:,:,i)))); 
   depth(:,:,i) = depth_norm(:,:,i)*(labels_max(:,i)-labels_min(:,i)) + labels_min(:,i);
end

% depth = depth_norm.*scaling_matrix;

%% Step 3: Calculate errors

RMSE = RMSE_linear(depth,labels)
RMSE_scale_inv = RMSE_log_scale_invariant(depth,labels)
abs_rel_diff = abs_rel_diff(depth, labels)
accuracy1 = threshold(depth, labels, 1.25)
accuracy2 = threshold(depth, labels, 1.25^2)
accuracy3 = threshold(depth, labels, 1.25^3)

difference = mean(abs(labels-depth),3);

mean_difference = mean(mean(difference,2),1)
std_difference = mean(std(difference))


%% Step 3: Calculate the allowed directions and find the percentage of right decisions

directions = getDirections(depth,4);

file = load('/esat/wasat/r0300219/ESAT_dataset/directions_esat_testset.mat') ;
directions_gndtrth = file.directions;

% diff_directions = directions_gndtrth - directions;
% nmb_diff_directions = sum(sum(abs(diff_directions),2),1);

nmb_diff_directions = 0;
for i=1:size(directions,2)
    for j = 1:size(directions,1)
         if(directions_gndtrth(j,i) ~= directions(j,i))
             nmb_diff_directions = nmb_diff_directions +1;
         end
    end      
end

nmb_directions = size(directions_gndtrth,1)*size(directions_gndtrth,2);
percentage_correct_decisions = (nmb_directions - nmb_diff_directions)/nmb_directions *100

%% Step 4: Show the directions on a figure

for i = 549:size(im,4)
    
    i = i
    
    delete(findall(gcf,'Tag','arr'))    
    
    direction = directions(:,i);
    
    subplot(1,2,1)
%     figure(1)
%     currAxes = axes;
%     image(uint8(video(:,:,:,i)), 'Parent', currAxes);
%     currAxes.Visible = 'off';

    if direction(1) ~= 0
        x = [0.5 0];
        y = [0.1 0.1];
        annotation('arrow',x,y, 'Tag', 'arr');
    end

    if direction(2) ~= 0
        x = [0.5 0.5];
        y = [0.1 0.5];
        annotation('arrow',x,y, 'Tag', 'arr');
    end
    
    if direction(3) ~= 0
        x = [0.5 1];
        y = [0.1 0.1];
        annotation('arrow',x,y, 'Tag', 'arr');
    end

    image(uint8(im(:,:,:,i)+image_mean));
    axis equal
    axis tight
    axis off
    
    subplot(1,2,2)
%     figure(2)
%     annotation('arrow',x,y);
    imagesc(depth(:,:,i));

    axis equal
    axis tight  
    axis off
 
    pause    
end

%% Step 5: Show figures

figure;
for i = 521:size(im,4)
    
%     figure;
%     i=45;
    i = i
    
    img = uint8(im(:,:,:,i)+image_mean);
    label = labels(:,:,i);
    dep = depth(:,:,i);
    
    bottom = min(min(min(label)),min(min(dep)));
    top = max(max(max(label)),max(max(dep)));
    
    subplot(1,3,1)
    image(img);
    axis equal    
    axis off
        
    subplot(1,3,2)
    imagesc(label);
    axis equal
    axis off 
    caxis manual
    caxis ([bottom top]);
    
    subplot(1,3,3)
    imagesc(dep);
    axis equal
    axis off  
    caxis manual
    caxis ([bottom top]);
 
    pause    
end






