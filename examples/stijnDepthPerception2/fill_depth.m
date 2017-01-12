%% A script to fill the bad depth pixels of Kinect data
% Based on the NYU_Depth_V2 toolbox
% Stijn Wellens
% April, 2016

clear;
% setup;
addpath('/users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/toolbox_nyu_depth_v2');
run /users/start2013/r0300219/Documents/Thesis/depth_mapping_with_CNN/toolbox_nyu_depth_v2/compile;

% image_filenames = dir('/home/stijnwellens/Documents/Thesis/Test_images');
% image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_esat');
% image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_01');
image_filenames = dir('/esat/wasat/r0300219/NYUv2/processed/images_test');
all_filenames={};
filename_idx = 1;
for i=1:numel(image_filenames)
    filename_this = image_filenames(i);
    if filename_this.bytes ~= 0
%         all_filenames{filename_idx} = strcat('/home/stijnwellens/Documents/Thesis/Test_images/',filename_this.name);
%         all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images_esat/',filename_this.name);
%         all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images_01/',filename_this.name);
        all_filenames{filename_idx} = strcat('/esat/wasat/r0300219/NYUv2/processed/images_test/',filename_this.name);
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
% labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_01.mat');
labels_fullset = load('/esat/wasat/r0300219/NYUv2/processed/labels/labels_test.mat');

labels = labels_fullset.labels_processed;
labels_denoised = zeros(size(labels,1),size(labels,2),amountOfImages);

for k=1:amountOfImages%nmb_training+1:nmb_training+nmb_results%+1:nmb_images
    
%     fprintf('Loop started \n');
%     image_filename = strcat('/esat/emerald/pchakrav/singleImageDepthDataset/meanSubtractedFlippedRotatedRandomCrop/', num2str(i,'%05d'), '.jpeg');
%     image = im2single(imread(image_filename));
    imgRgb = double(imread(all_filenames{k}));
    imgDepth = double(labels(:,:,k));
    alpha = 1;
 
    imgIsNoise = (imgDepth == 0 | imgDepth == 10);

  maxImgAbsDepth = max(imgDepth(~imgIsNoise));
  imgDepth = imgDepth ./ maxImgAbsDepth;
  imgDepth(imgDepth > 1) = 1;
  
  assert(ndims(imgDepth) == 2);
  [H, W] = size(imgDepth);
  numPix = H * W;
  
  indsM = reshape(1:numPix, H, W);
  
  knownValMask = ~imgIsNoise;
  
  grayImg = rgb2gray(imgRgb);

  winRad = 1;
  
  len = 0;
  absImgNdx = 0;
  cols = zeros(numPix * (2*winRad+1)^2,1);
  rows = zeros(numPix * (2*winRad+1)^2,1);
  vals = zeros(numPix * (2*winRad+1)^2,1);
  gvals = zeros(1, (2*winRad+1)^2);

  for j = 1 : W
    for i = 1 : H
      absImgNdx = absImgNdx + 1;
      
      nWin = 0; % Counts the number of points in the current window.
      for ii = max(1, i-winRad) : min(i+winRad, H)
        for jj = max(1, j-winRad) : min(j+winRad, W)
          if ii == i && jj == j
            continue;
          end

          len = len+1;
          nWin = nWin+1;
          rows(len) = absImgNdx;
          cols(len) = indsM(ii,jj);
          gvals(nWin) = grayImg(ii, jj);
        end
      end

      curVal = grayImg(i, j);
      gvals(nWin+1) = curVal;
      c_var = mean((gvals(1:nWin+1)-mean(gvals(1:nWin+1))).^2);

      csig = c_var*0.6;
      mgv = min((gvals(1:nWin)-curVal).^2);
      if csig < (-mgv/log(0.01))
        csig=-mgv/log(0.01);
      end
      
      if csig < 0.000002
        csig = 0.000002;
      end

      gvals(1:nWin) = exp(-(gvals(1:nWin)-curVal).^2/csig);
      gvals(1:nWin) = gvals(1:nWin) / sum(gvals(1:nWin));
      vals(len-nWin+1 : len) = -gvals(1:nWin);

      % Now the self-reference (along the diagonal).
      len = len + 1;
      rows(len) = absImgNdx;
      cols(len) = absImgNdx;
      vals(len) = 1; %sum(gvals(1:nWin));
    end
  end

  vals = vals(1:len);
  cols = cols(1:len);
  rows = rows(1:len);
  A = sparse(rows, cols, vals, numPix, numPix);
   
  rows = 1:numel(knownValMask);
  cols = 1:numel(knownValMask);
  vals = knownValMask(:) * alpha;
  G = sparse(rows, cols, vals, numPix, numPix);
  
  new_vals = (A + G) \ (vals .* imgDepth(:));
  new_vals = reshape(new_vals, [H, W]);
  
  denoisedDepthImg = new_vals * maxImgAbsDepth;
    
    labels_denoised(:,:,k) = denoisedDepthImg;
    
    k = k
    
end

labels_processed = labels_denoised;
labels_name = labels_fullset.labels_name;

save('/esat/wasat/r0300219/NYUv2/processed/labels/labels_test_denoised.mat', 'labels_processed', 'labels_name');
