planImage = imread('/users/visics/pchakrav/Documents/confPaperWriteups/ICRA16/images/oa_points.png');
figure,imshow(planImage);

[x,y] = ginput(4);

im1Pts = cat(2,x,y);

%im2Pts = [-9.58871, 10; 30, 9.48649; -8, -12.5818; 29.4858, -21]; % corridor world
im2Pts = [7, -7; -4, -7; 7,3.59667;-5, 4];%pole world

H = computeHomography(im1Pts, im2Pts)


% H for corridor world
% H =
% 
%    -0.0021   -0.0000    0.7584
%    -0.0000    0.0021   -0.6501
%    -0.0000   -0.0000   -0.0468

% H for pole world
% H =
% 
%     0.0012    0.0000   -0.7434
%    -0.0000   -0.0012    0.6648
%    -0.0000    0.0000   -0.0733
   
figure,imshow(planImage);
hold on;
for i=1:10
    [x,y] = ginput(1);
    transformedPt = H*[x;y;1];
    transformedPtX = transformedPt(1)/transformedPt(3);
    transformedPtY = transformedPt(2)/transformedPt(3);
    fprintf('Real world coordinates: %f, %f \n', transformedPtX,transformedPtY);
    %plot([transformedPt(1)],[transformedPt(2)],'r.');
end
    





