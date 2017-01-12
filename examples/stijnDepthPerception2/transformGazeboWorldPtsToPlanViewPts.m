%planImage = imread('/users/visics/pchakrav/Documents/confPaperWriteups/ICRA16/images/oa_1.png');
planImage = imread('/users/visics/pchakrav/Documents/confPaperWriteups/ICRA16/images/corridor.png');
figure,imshow(planImage);

%poleWorldPtsDir = '/esat/emerald/tmp/remote_images/depth_estim_expert_poles_2/';
poleWorldPtsDir = '/esat/emerald/tmp/remote_images/depth_estim_expert_corridor_2/';

% H for pole world
%H=[0.0012,0.0000,-0.7434;-0.0000,-0.0012,0.6648;-0.0000,0.0000,-0.0733];
% % H for corridor world
% % H =
% % 
% %    -0.0021   -0.0000    0.7584
% %    -0.0000    0.0021   -0.6501
% %    -0.0000   -0.0000   -0.0468
H = [-0.0021,   -0.0000,    0.7584;-0.0000,    0.0021,   -0.6501;-0.0000,   -0.0000,   -0.0468];
colour_mat = rand(10,3);

figure(1),imshow(planImage);
hold on;
%%plot(500,500,'rx','linewidth', 2);
% for i=1:10
%     fig = gca;
%     fig.ColorOrder = colour_mat;
%     fig.ColorOrderIndex = i;
%     %fig.Colormap = [0.9 0 0];
%     plot(500+(i*2),500,'x','linewidth',3);
%     %hold on;
% end
for dirNum_=1:10
    %dirNum_ = 1;
    switch dirNum_
    case 1
        colour = 'r.';
        colourEnd = 'rx';
        rgb = [1 0 0];
        %pos_array=[0.59,0.15,0.25,0.1];
    case 2
        colour = 'g.';
        colourEnd = 'gx';
        rgb = [0 1 0];
        %pos_array=[0.59,0.25,0.25,0.1];
    case 3
        colour = 'b.';
        colourEnd = 'bx';
        rgb = [0 0 1];
        %pos_array=[0.59,0.35,0.25,0.1];
    case 4
        colour = 'c.';
        colourEnd = 'cx';
        rgb = [0 1 1];
        %pos_array=[0.59,0.45,0.25,0.1];
    case 5
        colour = 'm.';
        colourEnd = 'mx';
        rgb = [1 0 1];
        %pos_array=[0.59,0.55,0.25,0.1];
    case 6
        colour = 'y.';
        colourEnd = 'yx';
        rgb = [1 1 0];
        %pos_array=[0.59,0.65,0.25,0.1];
    case 7
        colour = 'm.';
        colourEnd = 'mx';
        rgb = [0 1 0.5];
        %pos_array=[0.59,0.75,0.25,0.1];
    case 8
        colour = 'g.';
        colourEnd = 'gx';
        rgb = [0 1 0];
    case  9
        colour = 'b.';
        colourEnd = 'bx';
        rgb = [0 0 1];
    case 10
        colour = 'c.';
        colourEnd = 'cx';
        rgb = [0 1 1];
    end

    dirNum = num2str(dirNum_ - 1);
    fileName = strcat(poleWorldPtsDir,dirNum,'/','position.txt');
    poleWorldPts_ = dlmread(fileName);
    poleWorldPts = poleWorldPts_(:,2:3);
    
%     fig = gcf;
%     fig.Colormap = colour_mat(dirNum_,:);
    for i=1:size(poleWorldPts,1)
        poleWorldPt = poleWorldPts(i,:);

        transformedPt = inv(H)*[poleWorldPt(1);poleWorldPt(2);1];
        transformedPtX = transformedPt(1)/transformedPt(3);
        transformedPtY = transformedPt(2)/transformedPt(3);
        %fprintf('Map world coordinates: %f, %f \n', transformedPtX,transformedPtY);
        %plot([transformedPtX],[transformedPtY], colour);
        %[0.9 0 0];
        fig = gca;
        fig.ColorOrder = colour_mat;
        fig.ColorOrderIndex = dirNum_;
        plot([transformedPtX],[transformedPtY],'.','linewidth',0.5);
        %plot([transformedPtX],[transformedPtY],'color',colour_mat(dirNum_,:),'linewidth', 2);%,'MarkerSize',12,'LineWidth',10);
        hold on;
        if i == size(poleWorldPts,1)
            %plot([transformedPtX],[transformedPtY],colourEnd,'MarkerSize',12,'LineWidth',10);
            %plot([transformedPtX],[transformedPtY],'color',colour_mat(dirNum_,:),'MarkerSize',12,'LineWidth',10);
            fig.ColorOrder = colour_mat;
            fig.ColorOrderIndex = dirNum_;
            plot([transformedPtX],[transformedPtY],'x','LineWidth',15);
            
        end
        hold on;
    end
    pause;
end
    
    