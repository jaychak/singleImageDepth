% clear all;
run('/users/visics/pchakrav/Documents/MATLAB/utils/vlfeat/toolbox/vl_setup');
gt = dlmread('GTICRA/forest/GT1.txt');

algoResults = dlmread('GTICRA/forest/PR1Thresh0P2.txt');


numPosClass1 = 1;
numPosClass2 = 1;
numPosClass3 = 1;

for row_idx = 1:size(gt,1)
    frame_idx = gt(row_idx,1);
    gt_class = gt(row_idx,2);
    %algoClass = algoResults(frame_idx+1, 2);
    algoScoreClass1 = algoResults(frame_idx+1, 2);
    algoScoreClass2 = algoResults(frame_idx+1, 3);
    algoScoreClass3 = algoResults(frame_idx+1, 4);
    
    scoresClass1(row_idx) = algoScoreClass1;
    scoresClass2(row_idx) = algoScoreClass2;
    scoresClass3(row_idx) = algoScoreClass3;
    if gt_class == 1
%         
%         if algoClass == 1
%             scoresClass1(numPosClass1) = algoScore;
%         else
%             scoresClass1(numPosClass1) = 0;
%         end
        labelsClass1(row_idx) = 1;
        labelsClass2(row_idx) = -1;
        labelsClass3(row_idx) = -1;
        numPosClass1 = numPosClass1+1;
    elseif gt_class == 2
%         
%         if algoClass == 2
%             scoresClass2(numPosClass2) = algoScore;
%         else
%             scoresClass2(numPosClass2) = 0;
%         end
         labelsClass1(row_idx) = -1;
         labelsClass2(row_idx) = 1;
         labelsClass3(row_idx) = -1;
         numPosClass2 = numPosClass2+1;
    else
%         
%         if algoClass == 3
%             scoresClass3(numPosClass3) = algoScore;
%         else
%             scoresClass3(numPosClass3) = 0;
%         end
         labelsClass1(row_idx) = -1;
         labelsClass2(row_idx) = -1;
         labelsClass3(row_idx) = 1;
         numPosClass3 = numPosClass3+1;
    end
    
end

figure(1)
vl_roc(labelsClass1, scoresClass1);

figure(2)
vl_roc(labelsClass2, scoresClass2);
figure(3)
vl_roc(labelsClass3, scoresClass3);




