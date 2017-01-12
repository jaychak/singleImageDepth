%% Generate a depth map movie from a RGB movie using a CNN
% Stijn Wellens
% March, 2016

clear;
setup_nongpu;

load('data/coarse_depth/mean_image_extra_part1.mat');
% load('data/coarse_depth/mean_image_esat.mat');
net=load('data/coarse_depth/finetuned_01.mat');
% net=load('data/coarse_depth/coarsecnn.mat');

% Location video file
% location = 'data/thuis.mp4';
location = 'data/Training.mov';

% Read video frames from video file
v = VideoReader(location);
v.CurrentTime = 0; % Specify that reading should begin after x seconds

% video = [];
% % currAxes = axes;
% while hasFrame(v)
%    vidFrame = readFrame(v);
%    vidFrame = imresize(vidFrame, [240, 320]);
%    video(:,:,:,end+1) = vidFrame;
% %    image(vidFrame, 'Parent', currAxes);
% %    currAxes.Visible = 'off';
% %    pause(1/v.FrameRate);
% end

video = [];
for i = 1:2000 
hasFrame(v);
% while hasFrame(v)
   vidFrame = readFrame(v);
   vidFrame = imresize(vidFrame, [240, 320]);
   video(:,:,:,end+1) = vidFrame;
end
nmbFrames = size(video,4);

% Subtract the mean image from each frame of the video
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
    
vw2 = VideoWriter('data/ft_case2_01.avi');
vw2.FrameRate = v.FrameRate;
vw2.Quality = 100;
open(vw2)
% Display the actual movie and the depth map movie
% figure
for i = 1:nmbFrames
    subplot(1,2,1)
%     figure(1)
%     currAxes = axes;
%     image(uint8(video(:,:,:,i)), 'Parent', currAxes);
%     currAxes.Visible = 'off';
    image(uint8(video(:,:,:,i)));
    axis equal
    axis tight
    
    subplot(1,2,2)
%     figure(2)
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
