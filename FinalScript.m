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

indexes=[5,6,7,8];

chainMatches=chain(siftDescriptors,indexes);
measurement_matrix=extract_measurement_matrix( siftDescriptors,chainMatches,indexes,images);

%means=mean(measurement_matrix);
%meansNorm=repmat(means,size(measurement_matrix,1),1);

%[U,W,V] = svds(measurement_matrix-meansNorm,3)
%Shape=(W*V')';
%scatter3(Shape(:,1),Shape(:,2),Shape(:,3))
% 2m number of images, n number of sift features


[U,W,V] = svds(measurement_matrix,3)
Shape=(W*V')';
scatter3(Shape(:,1),Shape(:,2),Shape(:,3))
% 2m number of images, n number of sift features



