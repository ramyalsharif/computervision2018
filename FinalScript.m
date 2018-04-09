files=dir(fullfile('model_castle','*.jpg'));
%% Load data
print('Loading the data')
images={};
for i=1:length(files)
    images{i}=single(rgb2gray(imread(files(i).name)));
end

%% Extract SIFT descriptors
print('Extracting SIFT descriptors')
siftDescriptors={}

for i=1:length(images)
    print('Image No. '+i)
    [frames, desc]=sift(images{i});
    siftDescriptors{i,1}=frames;
    siftDescriptors{i,2}=desc;
end
