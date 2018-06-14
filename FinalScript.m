files=dir(fullfile('model_castle','*.jpg'));
%% Load data
images={};
for i=1:length(files)
    images{i}=single(rgb2gray(imread(files(i).name)));
end

%% Extract SIFT descriptors
siftDescriptors={}

for i=1:length(images)
    [frames, desc]=sift(images{i});
    siftDescriptors{i,1}=frames;
    siftDescriptors{i,2}=desc;
end
%% GetMatches

BestMatches={}
numOfInliers=150
for i =1:length(images)
    if i==length(images)
       j=1 
    else
        j=i+1
    end
    [matches] = vl_ubcmatch(siftDescriptors{i,2},siftDescriptors{j,2});

    pointsCoordinatesI=siftDescriptors{i,1}(1:2,:)';
    pointsCoordinatesJ=siftDescriptors{j,1}(1:2,:)';

    pointsMatchedI=[];
    pointsMatchedJ=[];
    for k=1:size(matches,2)
        pointI=pointsCoordinatesI(matches(1,k),1:2);
        pointJ=pointsCoordinatesJ(matches(2,k),1:2);
        pointsMatchedI=[pointsMatchedI;pointI];
        pointsMatchedJ=[pointsMatchedJ;pointJ];
    end

    [ Best_Fmatrix, inliers_a, inliers_b,indexesOfInliers] =findInliers(pointsMatchedI, pointsMatchedJ);

    BestMatches{i}=matches(1:2,indexesOfInliers);
end

point_view_matrix=zeros(2*length(images),30);
for i=1:length(BestMatches)
    i
    currentIndex1=i;
    currentIndex2=i+1;
    currentMatches=BestMatches{i};
    if i==1
        for j=1:size(currentMatches,2)
            matchedCoordinates1=siftDescriptors{currentIndex1,1}(1:2,currentMatches(1,j));
            matchedCoordinates2=siftDescriptors{currentIndex2,1}(1:2,currentMatches(2,j));
            point_view_matrix(1:4,j)=[matchedCoordinates1;matchedCoordinates2];
        end
    elseif i<length(BestMatches)
        for j=1:size(currentMatches,2)
            matchedCoordinates1=siftDescriptors{currentIndex1,1}(1:2,currentMatches(1,j));
            matchedCoordinates2=siftDescriptors{currentIndex2,1}(1:2,currentMatches(2,j));
            found=0;
            for searchIndex=1:size(point_view_matrix,2)
                if point_view_matrix((currentIndex1-1)*2+1:(currentIndex1-1)*2+2,searchIndex)==matchedCoordinates1;
                   found=1;
                   point_view_matrix((currentIndex1)*2+1:(currentIndex1)*2+2,searchIndex)=matchedCoordinates2;
                   break
                end
            end
            if found==0
                point_view_matrix((currentIndex1-1)*2+1:(currentIndex1)*2+2,searchIndex+1)=[matchedCoordinates1;matchedCoordinates2];
            end        
        end
    else
        currentIndex2=1; 
        for j=1:size(currentMatches,2)
            matchedCoordinates1=siftDescriptors{currentIndex1,1}(1:2,currentMatches(1,j));
            matchedCoordinates2=siftDescriptors{currentIndex2,1}(1:2,currentMatches(2,j));
            found=0;
            for searchIndex=1:size(point_view_matrix,2)
                if point_view_matrix((currentIndex1-1)*2+1:(currentIndex1-1)*2+2,searchIndex)==matchedCoordinates1;
                   found=1;
                   point_view_matrix((currentIndex2-1)*2+1:(currentIndex2-1)*2+2,searchIndex)=matchedCoordinates2;
                   break
                elseif point_view_matrix((currentIndex2-1)*2+1:(currentIndex2-1)*2+2,searchIndex)==matchedCoordinates2
                   found=1;
                   point_view_matrix((currentIndex1-1)*2+1:(currentIndex1-1)*2+2,searchIndex)=matchedCoordinates1;
                   break
                end
            end
            if found==0
                point_view_matrix((currentIndex1-1)*2+1:(currentIndex1-1)*2+2,searchIndex+1)=matchedCoordinates1;
                point_view_matrix((currentIndex2-1)*2+1:(currentIndex2-1)*2+2,searchIndex+1)=matchedCoordinates2;
            end        
        end
    end
end

imshow(point_view_matrix)
%%
%indexes=[5,6,7,8];

%chainMatches=chain(siftDescriptors,indexes);
%measurement_matrix=extract_measurement_matrix( siftDescriptors,chainMatches,indexes,images);

%means=mean(measurement_matrix);
%meansNorm=repmat(means,size(measurement_matrix,1),1);

%[U,W,V] = svds(measurement_matrix-meansNorm,3)
%Shape=(W*V')';
%scatter3(Shape(:,1),Shape(:,2),Shape(:,3))
% 2m number of images, n number of sift features


%[U,W,V] = svds(measurement_matrix,3)
%Shape=(W*V')';
%scatter3(Shape(:,1),Shape(:,2),Shape(:,3))
% 2m number of images, n number of sift features



