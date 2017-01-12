%% A script to fill the bad depth pixels of Kinect data
% Based on the NYU_Depth_V2 toolbox
% Stijn Wellens
% April, 2016

clear;
% setup;
% addpath('/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/toolbox_nyu_depth_v2');
% run /users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/toolbox_nyu_depth_v2/compile;

% image_filenames = dir('/home/stijnwellens/Documents/Thesis/Test_images');
% image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_esat');
image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_01');
% image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_test');
all_filenames={};
filename_idx = 1;
for i=1:numel(image_filenames)
    filename_this = image_filenames(i);
    if filename_this.bytes ~= 0
%         all_filenames{filename_idx} = strcat('/home/stijnwellens/Documents/Thesis/Test_images/',filename_this.name);
%         all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images_esat/',filename_this.name);
        all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images_01/',filename_this.name);
%         all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images_test/',filename_this.name);
        filename_idx = filename_idx + 1;
    end
end

% amountOfImages = numel(all_filenames);
amountOfImages = 100;
% image_idx = 1;
% for i=1:amountOfImages
%     image_names{image_idx} = all_filenames{i};
%     image_idx = image_idx + 1;
%     im1 = imread(image_names{i});
%     im(:,:,:,i) = im1;
% end

% labels_fullset = load('/home/stijnwellens/Documents/Thesis/Test_images/labels/labels.mat');
% nyudepth_labels2 = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels2.mat');
% labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_esat_2.mat');
labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_01.mat');
% labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_test.mat');

labels = labels_fullset.labels_processed;
labels_denoised = zeros(size(labels,1),size(labels,2),amountOfImages);

for k=1:amountOfImages%nmb_training+1:nmb_training+nmb_results%+1:nmb_images
    
%     fprintf('Loop started \n');
%     image_filename = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/meanSubtractedFlippedRotatedRandomCrop/', num2str(i,'%05d'), '.jpeg');
%     image = im2single(imread(image_filename));
    imgRgb = double(imread(all_filenames{k}));
    imgDepth = double(labels(:,:,k));
    alpha = 1;
 
%     g_name='example.bmp';
%     c_name='example_marked.bmp';
%     out_name='example_res.bmp';

    %set solver=1 to use a multi-grid solver 
    %and solver=2 to use an exact matlab "\" solver
    solver=2; 

%     gI=double(imread(g_name))/255;
%     cI=double(imread(c_name))/255;
%     colorIm=(sum(abs(gI-cI),3)>0.01);
%     colorIm=double(colorIm);
    
    imgRgb = imresize(imgRgb, size(imgDepth));
    imgDepth = repmat(imgDepth,[1,1,3]);
    
    gI=imgRgb/255;
    cI=imgDepth/255;
    colorIm=(sum(abs(gI-cI),3)>0.01);
    colorIm=double(colorIm);

    sgI=rgb2ntsc(gI);
    scI=rgb2ntsc(cI);

    ntscIm(:,:,1)=sgI(:,:,1);
    ntscIm(:,:,2)=scI(:,:,2);
    ntscIm(:,:,3)=scI(:,:,3);


    max_d=floor(log(min(size(ntscIm,1),size(ntscIm,2)))/log(2)-2);
    iu=floor(size(ntscIm,1)/(2^(max_d-1)))*(2^(max_d-1));
    ju=floor(size(ntscIm,2)/(2^(max_d-1)))*(2^(max_d-1));
    id=1; jd=1;
    colorIm=colorIm(id:iu,jd:ju,:);
    ntscIm=ntscIm(id:iu,jd:ju,:);

    if (solver==1)
      nI=getVolColor(colorIm,ntscIm,[],[],[],[],5,1);
      nI=ntsc2rgb(nI);
    else
      nI=getColorExact(colorIm,ntscIm);
    end

    figure, imshow(nI)

    labels_denoised:,:,k) = nI(:,:,1);
%     imwrite(nI,out_name)
       
    k = k
    
end

labels_processed = labels_denoised;
labels_name = labels_fullset.labels_name;

save('/esat/wasat/r0300219/NYUv2/processed/labels/labels_01_denoised.mat', 'labels_processed', 'labels_name');
