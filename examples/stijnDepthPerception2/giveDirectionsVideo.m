%% A script that gives the directions on a video where a drone should fly to
% Stijn Wellens
% 22 March, 2016

clear;
setup_nongpu;

%% Step 1: Make depth maps from a video

% Load the mean image and the CNN network parameters
load('data/coarse_depth/mean_image_esat.mat');
% load('/esat/wasat/r0300219/Thesis/mean_image_esat.mat');
% net=load('data/coarse_depth/coarsecnn.mat');
% net=load('data/coarse_depth/net-epoch-5.mat');
net=load('data/coarse_depth/net-epoch-19.mat');
net = net.net;
net.layers(end) = [];
% net = load('/esat/wasat/r0300219/Thesis/finetuned_esat_01/coarsecnn.mat');

% Location video file
% location = 'data/thuis.mp4';
location = 'data/Training.mov';
% location = '/esat/wasat/r0300219/Thesis/Test.mov';

% Read video frames from video file
v = VideoReader(location);
v.CurrentTime = 0; % Specify that reading should begin after x seconds

video = [];
for i = 1:1999 
hasFrame(v);
% while hasFrame(v)
   vidFrame = readFrame(v);
   vidFrame = imresize(vidFrame, [240, 320]);
   video(:,:,:,end+1) = vidFrame;
end

% Calculate the amount of frames
nmbFrames = size(video,4);

% Subtract the mean image from each frame of the video
% video2 = video - repmat(image_mean_orig,[1 1 1 nmbFrames]); 
video2 = video - repmat(image_mean,[1 1 1 nmbFrames]); 

% Find the depth with the CNN for each frame
depth =[];
for i = 1:nmbFrames
    display(['Frame ',int2str(i)]);
    dzdy = [];
    res=[];
    res = vl_simplenn(net, single(video2(:,:,:,i)), dzdy, res, ... 
                      'mode', 'test', ...
                      'conserveMemory', false, ...
                      'backPropDepth', +inf, ...
                      'sync', false, ...
                      'cudnn', false) ;
%     depth(:,:,i) = reshape(res(end-1).x(1,1,:),[55 74]);  
    depth(:,:,i) = reshape(res(end).x(1,1,:),[55 74]);  
end    

%% Step 2: Calculate the direction arrows

% % Choose the time window length = nmb of frames took together
% windowLength = 10;
% columnWidth = 5;
% nmbDirections = 3;
% 
% windowNmb = 1;
% directions = []; % 8 possible directions on one plane (from left to right, not up or down)
% for i=1:windowLength:nmbFrames
% 
%     % The depth images are 74 pixels wide
%     windowDepth = mean(depth(:,:,i:i+windowLength-1),3);
% 
%     depthColumns = [];
%     for ii = 1:74-columnWidth
%         depthColumns(:,ii) = mean(windowDepth(:,ii:ii+columnWidth),2);
%     end
%     depthColumns = sum(depthColumns,1);
%     [M, I] = max(depthColumns); % The direction where obstacles are the furthest away
% 
%     nmbColumns = size(depthColumns,2);
%     factor = nmbColumns/nmbDirections;
%     directions(windowNmb) = round((I-1)/factor);
% 
%     windowNmb = windowNmb +1;
% end

%% Step 3: Make the actual movie with the depth maps and the direction arrows

vw2 = VideoWriter('data/fine01_nyu_esat.avi');
% vw2 = VideoWriter('/esat/wasat/r0300219/Thesis/case_finetune_esat01.avi');
vw2.FrameRate = v.FrameRate;
vw2.Quality = 100;
open(vw2)
% Display the actual movie and the depth map movie
% figure
for i = 1:nmbFrames
    
    delete(findall(gcf,'Tag','arr'))    
    
%     I = ceil(i/windowLength);
%     direction = directions(I);
%     
%     x = [0.5 (1/nmbDirections)*direction];
%     y = [0 (1/nmbDirections)*direction];
    
    subplot(1,2,1)
%     figure(1)
%     currAxes = axes;
%     image(uint8(video(:,:,:,i)), 'Parent', currAxes);
%     currAxes.Visible = 'off';
%     annotation('arrow',x,y, 'Tag', 'arr');
    image(uint8(video(:,:,:,i)));
    axis equal
    axis tight
    
    subplot(1,2,2)
%     figure(2)
%     annotation('arrow',x,y);
    imagesc(depth(:,:,i));
    axis equal
    axis tight
    
    writeVideo(vw2,getframe(gcf))
%     pause(1/v.FrameRate);    
end
close(vw2)

% currAxes = axes;
% while hasFrame(v)
%     vidFrame = readFrame(v);
%     image(vidFrame, 'Parent', currAxes);
%     currAxes.Visible = 'off';
%     pause(1/v.FrameRate);
% end
