function [points] = SfM(matrix)
    Points = matrix;
    %Normalize
    shifted_points= Points-repmat(mean(Points,2),1,size(Points,2));

    % SVD
    [U,W,V] = svd(shifted_points);

    U = U(:,1:3);
    W = W(1:3,1:3);
    V = V(:,1:3);

    M = U*sqrt(W);
    points = sqrt(W)*V';
end