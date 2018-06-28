function [matrix, columns] = FindPartsOfPVM(point_view_matrix,indexes,numOfCoordsPerIndex)
    columns = [];
    indexesXY=[];
    for i=1:length(indexes)
        indexesXY(numOfCoordsPerIndex*i-numOfCoordsPerIndex+1:numOfCoordsPerIndex*i)=[indexes(i)*numOfCoordsPerIndex-numOfCoordsPerIndex+1:indexes(i)*numOfCoordsPerIndex];
    end
    matrix=point_view_matrix(indexesXY,:);

    for i=size(matrix,2):-1:1
        if sum(matrix(:,i)==0)==0
            columns = [i,columns];
        end 
    end
    matrix=matrix(:,columns);
end