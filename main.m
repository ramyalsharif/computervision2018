%Load images and features 
files=dir(fullfile('modelcastle_features','*.png'));
images=[];
for i=1:length(files)
    images{i}=single(rgb2gray(imread(files(i).name)));
end

files=dir(fullfile('modelcastle_features','*.sift'));
frames=[];
descr=[];
for i=1:length(files)
    if mod(i,2)==1
        feat=loadFeatures(files(i).name);
        frames{(i+1)/2}=feat(1:5,:);
        descr{(i+1)/2}=feat(6:size(feat,1),:);
    else
        continue
    end
end


%% matching between the consecutive images

matches=[];
for i=1:length(descr)
    image1Index=i;
    image2Index=i+1;
    if image2Index>length(descr)
        image2Index=1;
    end
    matches{i} = vl_ubcmatch(descr{image1Index},descr{image2Index});
end

%% Find inlier matches eight-point RANSAC
iterations = 500;
threshold = 30000;
matches8Point=[];

for i=1:length(descr)
    image1Index=i;
    image2Index=i+1;
    if image2Index>length(descr)
        image2Index=1;
    end
    
    points1 = frames{image1Index}(1:2,:);
    points2 = frames{image2Index}(1:2,:);
    
    currentMatches = matches{i};    
    [points1_ransac,points2_ransac,indexes] = ransac(currentMatches, points1, points2, iterations, threshold);
    matches8Point{i} = [points1_ransac;indexes(1,:); points2_ransac;indexes(2,:)];  
end

%% Chaining Build the point view matrix
indexes_point_view_matrix = buildPVmatrix(matches8Point);
point_view_matrix = transformPointViewMatrix(indexes_point_view_matrix, frames);

%% Apply SFM on series of images
seriesLength=3;
pointViews = zeros(length(descr)*seriesLength, size(point_view_matrix,2));

for i=1:length(descr)
    indexes=mod(i:i+seriesLength-1,length(descr))+1

    [submatrix, columnInexes] = FindPartsOfPVM(point_view_matrix,indexes,2);
    
    points = SfM(submatrix)';
        
    start = i + (2*(i-1));
    
    %put the points in the point_viewset matrix
    for m=1:length(columnInexes)
        pointViews(start:start+2,columnInexes(m)) = points(m,:)';
    end
%    figure;
%    plot3(points(:, 1), points(:,2), points(:,3),'b.');     
end
    

%% use procrustes to transform all 3D points to 1 coord system
mainView= pointViews(1:3,:);
for i=2:length(descr)-1
    indexes=[i-1,i];
    nextView = pointViews((i+(i-1)*2):(i*3),:);
    
    %Find overlapping 3d points  between view 1 and any other and find transformation
    block = [mainView; nextView];
    [pointsForProc, ~] = FindPartsOfPVM(block,[1,2],3);
    [~,~,transform] = procrustes(pointsForProc(4:6,:).',pointsForProc(1:3,:).');
    
    %Get translation matrix 
    translation = mean(transform.c);
    translationMatrix = zeros(3,length(mainView));
    [~, columnsIndexes] = FindPartsOfPVM(mainView,1,3);
    for j=1:length(columnsIndexes)   
        translationMatrix(:,columnsIndexes(j)) = translation.';   
    end
    
    %transform the points from the main view
    mainView = (transform.b*mainView.'*transform.T + translationMatrix.').';
    
    %insert points from next view
    [pointsToAdd, columnsIndexesToAdd] = FindPartsOfPVM(nextView,1,3);
    for j=1:length(columnsIndexesToAdd)   
        mainView(:,columnsIndexesToAdd(j)) = pointsToAdd(:,j);   
    end
end

%% Get 3d points

[finalPoints, ~] = FindPartsOfPVM(mainView,1,3);
%plot3(finalPoints(1,:),finalPoints(2,:),finalPoints(3,:),'b*')
% Get rid of noise- any point with z<0
DenoisedFinalPoints=finalPoints;
for i=size(DenoisedFinalPoints,2):-1:1
    if DenoisedFinalPoints(3,i)<0
        DenoisedFinalPoints(:,i)=[];
    end
end
figure
surf(DenoisedFinalPoints(1,:), DenoisedFinalPoints(2,:), diag(DenoisedFinalPoints(3,:)))