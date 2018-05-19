function [ measurement_matrix ] = extract_measurement_matrix( siftDescriptors,chainMatches,indexes,images )
measurement_matrix=zeros(2*size(chainMatches,1),size(chainMatches,2));

for i=1:size(chainMatches,1)
    center1=size(images{indexes(i)},2)/2;
    center2=size(images{indexes(i)},1)/2;
    for j=1:size(chainMatches,2)
        measurement_matrix((i-1)*2+1,j)=siftDescriptors{indexes(i),1}(1,chainMatches(i,j))-center1;
        measurement_matrix((i-1)*2+2,j)=siftDescriptors{indexes(i),1}(2,chainMatches(i,j))-center2;
    end
end


end

