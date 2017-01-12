%% A script to synchronize raw Kinect data and to produce RGB-images en depthmaps from it
% Stijn Wellens
% March, 2016

clear

addpath('/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/toolbox_nyu_depth_v2');
run /users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/toolbox_nyu_depth_v2/compile;

% The directory where you extracted the raw dataset.
% datasetDir = '/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/data/NYU'; %[PATH TO THE NYU DEPTH V2 RAW DATASET]
% datasetDir = '.';
datasetDir = '/esat/wasat/r0300219/NYUv2/raw';
% datasetDir = 'data/NYU';

% Go over all files in the current datasetDir.
files = dir(datasetDir);
% Search for directories.
dirFlags = [files.isdir];
% Only keep the directories
directories = files(dirFlags);

directories = directories(3:end); % Remove . and ..
% sizeD = size(directories,1);
sizeD = 2;

for k = 1:1:sizeD
    % The name of the scene to demo.
    C = strsplit(directories(k).name,'_');
    sceneName = C{1}; %[NAME OF A SCENE YOU WANT TO VIEW]
%     afterName = '_0001a'

    % The absolute directory of the 
%     sceneDir = sprintf('%s/%s', datasetDir, sceneName, afterName);
    sceneDir = sprintf('%s/%s', datasetDir, directories(k).name)

    % Reads the list of frames.
    frameList = get_synched_frames(sceneDir);
    nmbOfImages = numel(frameList);

    % The directory where to save the new synched images and the filled
    % depthmaps
    save_dir_prefix ='/esat/wasat/r0300219/NYUv2/processed/images_test';
    image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_test/');
    
%     save_dir_prefix ='/data/processed/images';
%     image_filenames = dir('/data/processed/images/');
    
    nmbImagesAlreadyProcessed = 0;
    for i=1:numel(image_filenames)
        filename_this = image_filenames(i);
        if filename_this.bytes ~= 0       
            nmbImagesAlreadyProcessed = nmbImagesAlreadyProcessed + 1;
        end
    end

        % Set of labels created
%     labels_processed = zeros(55,74,nmbOfImages);
%     labels_name = cell(nmbOfImages,1);
%     labels_processed = zeros(55,74,1);
    labels_name = cell(1,1);

    im_nmb = 1;

    for ii = 1:nmbOfImages
        % Displays each pair of synchronized RGB and Depth frames.
        % for ii = 1 : 15 : numel(frameList)
        %   imgRgb = imread([sceneDir '/' frameList(ii).rawRgbFilename]);
        %   imgDepthRaw = swapbytes(imread([sceneDir '/' frameList(ii).rawDepthFilename]));
        %   
        %   figure(1);
        %   % Show the RGB image.
        %   subplot(1,3,1);
        %   imagesc(imgRgb);
        %   axis off;
        %   axis equal;
        %   title('RGB');
        %   
        %   % Show the Raw Depth image.
        %   subplot(1,3,2);
        %   imagesc(imgDepthRaw);
        %   axis off;
        %   axis equal;
        %   title('Raw Depth');
        %   caxis([800 1100]);
        %   
        %   % Show the projected depth image.
        %   imgDepthProj = project_depth_map(imgDepthRaw, imgRgb);
        %   subplot(1,3,3);
        %   imagesc(imgDepthProj);
        %   axis off;
        %   axis equal;
        %   title('Projected Depth');
        %   
        %   pause(0.01);
        % end

       try
        %% Load a pair of frames and align them.
        imgRgb = imread([sceneDir '/' frameList(ii).rawRgbFilename]);
        imgDepth = swapbytes(imread([sceneDir '/' frameList(ii).rawDepthFilename]));

        [imgDepth2, imgRgb2] = project_depth_map(imgDepth, imgRgb);

        % %% Now visualize the pair before and after alignment.
        % imgDepthAbsBefore = depth_rel2depth_abs(double(imgDepth));
        % imgOverlayBefore = get_rgb_depth_overlay(imgRgb, imgDepthAbsBefore);
        % 
        % imgOverlayAfter = get_rgb_depth_overlay(imgRgb2, imgDepth2);
        % 
        % figure;
        % subplot(1,2,1);
        % imagesc(crop_image(imgOverlayBefore));
        % title('Before projection');
        % 
        % subplot(1,2,2);
        % imagesc(crop_image(imgOverlayAfter));
        % title('After projection');

        % Crop the images to include the areas where we have depth information.
        imgRgb = crop_image(imgRgb2);
        imgDepthAbs = crop_image(imgDepth2);
        
        % Calculate the number of black points in the depth map
%         nmbBlackPoints = 0;
%         for iii = 1:numel(imgDepthAbs)
%             point = imgDepthAbs(iii);
%             
%             if(point == 150)
%                 nmbBlackPoints = nmbBlackPoints +1;
%             end
%         end
%         
%         % If the number of black points is too high, ignore that image
%         if(nmbBlackPoints < numel(imgDepthAbs)*0.4)
        
%             imgDepthFilled = fill_depth_colorization(double(imgRgb), double(imgDepthAbs));

%             figure;
%             subplot(1,3,1); imagesc(imgRgb);
%             subplot(1,3,2); imagesc(imgDepthAbs);
%             subplot(1,3,3); imagesc(imgDepthFilled);

            imgDepthFilled = imgDepthAbs;

            %% Resize images (downsample input)

%             imgRgb = imresize(imgRgb, [240, 320]);
        %     imgDepthFilled = imresize(imgDepthFilled, [240,320]);
%             labels_processed(:,:,im_nmb) = imresize(imgDepthFilled, [55,74]);
            labels_processed(:,:,im_nmb) = imgDepthFilled;
            labels_name{im_nmb} = strcat(num2str(nmbImagesAlreadyProcessed+im_nmb,'%06.f'),'_',sceneName);

            %% Save images

            save_dir_name = strcat(save_dir_prefix,'/',num2str(nmbImagesAlreadyProcessed+im_nmb,'%06.f'),'_',sceneName,'.jpeg');
            imgRgb = uint8(imgRgb);
            imwrite(imgRgb,save_dir_name);
%         end
            im_nmb = im_nmb + 1;

       catch
           
       end
    end

    %% Save labels for the processed images
    if exist('/esat/wasat/r0300219/NYUv2/processed/labels/labels_test.mat','file')
    labels_previous = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_test.mat');
%     if exist('data/processed/labels/labels.mat','file')
%     labels_previous = load('data/processed/labels/labels.mat');

    labels_prev = labels_previous.labels_processed;
    labels_text = labels_previous.labels_name;
    
    labels_processed = cat(3, labels_prev, labels_processed);
    labels_name = cat(2, labels_text, labels_name);
    
%     labels = struct('labels',labels_all,'name',labels_text);
%     save('data/processed/labels/labels.mat', 'labels');
    save('/esat/wasat/r0300219/NYUv2/processed/labels/labels_test.mat', 'labels_processed', 'labels_name');
    else
%         labels = struct('labels',labels_processed,'name',labels_name);
        save('/esat/wasat/r0300219/NYUv2/processed/labels/labels_test.mat', 'labels_processed', 'labels_name');
%         save('data/processed/labels/labels.mat', 'labels');
    end
    
    %% Remove the directory of the raw files
%     rmdir(sceneDir, 's');
end

fprintf('Function syncKinectImages ended');
