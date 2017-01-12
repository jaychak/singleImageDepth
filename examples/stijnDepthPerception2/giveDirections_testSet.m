%% A script to give directions manually to the ESAT testset
% Stijn Wellens
% May, 2016

clear;

%% Step 1: Load images + depth maps from the ESAT testset (wasat2)

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
    im(:,:,:,i) = imread(image_names{i});  
end

% Load labels
labels = load('/esat/wasat/r0300219/ESAT_dataset/labels_esat_testset.mat');
labels = labels.labels_processed;

%% Step 2: Show the directions on a figure and decide the direction

if exist('/esat/wasat/r0300219/ESAT_dataset/directions_esat_testset.mat','file')
     file = load('/esat/wasat/r0300219/ESAT_dataset/directions_esat_testset.mat') ;
     directions = file.directions;
     I1 = find(directions(1,:) == 0, 1, 'last');
     I2 = find(directions(2,:) == 0, 1, 'last');
     I3 = find(directions(3,:) == 0, 1, 'last');
     begin = max([I1 I2 I3]);
     begin = 646;
else
     directions = ones(3,size(labels,3)); 
     begin = 1;
end

for i = begin:size(im,4)
    
   i=i
   
   direction = directions(:,i);
    
    subplot(1,3,1)
%     figure(1)
%     currAxes = axes;
%     image(uint8(video(:,:,:,i)), 'Parent', currAxes);
%     currAxes.Visible = 'off';


    image(uint8(im(48:196,:,:,i)));
    axis equal
    axis tight
    
    subplot(1,3,2)
    imagesc(labels(11:45,:,i));
    axis equal
    axis tight   
    
    subplot(1,3,3)
    imagesc(labels(:,:,i));
    axis equal
    axis tight 
    
    while(true)
        prompt = 'Can we steer to the left? Yes = 1/No = 0';
        x = input(prompt)
        
        if(~isempty(x) && ~ischar(x) && (x == 0 || x == 1))
            directions(1,i) = x;
            break
        end
    end
    
    while(true)
        prompt = 'Can we go straight ahead? Yes = 1/No = 0';
        x = input(prompt)
        
        if(~isempty(x) && ~ischar(x) && (x == 0 || x == 1))
            directions(2,i) = x;
            break
        end
    end
    
    while(true)
        prompt = 'Can we steer to the right? Yes = 1/No = 0';
        x = input(prompt)
        
        if(~isempty(x) && ~ischar(x) && (x == 0 || x == 1))
            directions(3,i) = x;
            break
        end
    end
    
    save('/esat/wasat/r0300219/ESAT_dataset/directions_esat_testset.mat', 'directions') ;
end





