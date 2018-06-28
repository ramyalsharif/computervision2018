function [point_view_matrix]=transformPointViewMatrix(indexes_point_view_matrix, frames)
point_view_matrix=[];
for i = 1:length(frames)
    points= frames{i}(1:2,:);
    for j =1:size(indexes_point_view_matrix,2)
        if indexes_point_view_matrix(i,j) == 0
           point_view_matrix(2*i-1:2*i,j)=[0;0];
        else
            
           point_view_matrix(2*i-1:2*i,j)= points(:,indexes_point_view_matrix(i,j));    
        end
    end
end