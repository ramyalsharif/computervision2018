function [point_view_matrix]= buildPVmatrix(matches8Point)
point_view_matrix=[];
matchesFirstTwo = matches8Point{1,1};
point_view_matrix(1,:)=matchesFirstTwo(3,:);
point_view_matrix(2,:)=matchesFirstTwo(6,:);

for i=2:length(matches8Point)
    currentImageMatches=matches8Point{i};
    previousImageMatches= point_view_matrix(i,:);

    %Add new row to point view matrix
    point_view_matrix=[point_view_matrix; zeros(1,length(point_view_matrix))];
    for j = 1:length(previousImageMatches)
        for k = 1:length(currentImageMatches(1,:))
            if previousImageMatches(j) == currentImageMatches(3,k)
                point_view_matrix(i+1,j) = currentImageMatches(6,k);
                break
            end
        end
    end
    
    %append those that were not yet in point view matrix
    [difference indexesA] = setdiff(currentImageMatches(3,:),previousImageMatches);
    for j = 1:length(indexesA)
        newColumn=[ zeros(i-1,1);currentImageMatches(3,j);currentImageMatches(6,j)];
        point_view_matrix=[point_view_matrix, newColumn];
    end
    
end
%Make backward pass to connect last row with the first one
    firstRow=point_view_matrix(1,:);
    lastRow=point_view_matrix(size(point_view_matrix,1),:);
    ColumnsToDelete=[];
    for i =1:length(lastRow)
       if lastRow(i)==0
          continue
       else
           for j=1:length(firstRow)
                if firstRow(j)==0
                    point_view_matrix(1,i)=point_view_matrix(size(point_view_matrix,1),i);
                    break
                elseif firstRow(j)==lastRow(i)
                    ColumnsToDelete=[ColumnsToDelete,i];
                    for k=1:size(point_view_matrix,1)-1
                        if point_view_matrix(k,i)~=0
                            point_view_matrix(k,j)=point_view_matrix(k,i);
                        end
                    end
                    break
                end
           end
       end
    end

point_view_matrix(size(point_view_matrix,1),:)=[];
point_view_matrix(:,ColumnsToDelete)=[];
end
        
        
    
    

    
    
    
    
    



