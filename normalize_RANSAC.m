function [ TransformedPoints,Transform ] = normalize_RANSAC( matchingPoints )
    mean_a = mean(matchingPoints');
    distance = sum(sqrt(((matchingPoints(1,:) - mean_a(1)).^2 + (matchingPoints(2,:) - mean_a(2)).^2))/length(matchingPoints));
    Transform = [sqrt(2)/distance, 0, -mean_a(1)*sqrt(2)/distance; 0 sqrt(2)/distance, -mean_a(2)*sqrt(2)/distance; 0, 0, 1];
    %add row of 1s
    matchingPointsRow = [matchingPoints; ones(1,length(matchingPoints))];
   
    TransformedPoints = (matchingPointsRow' * Transform')';
    TransformedPoints = TransformedPoints(1:2,:);
end