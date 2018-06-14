function [ Best_Fmatrix, inliers_a, inliers_b,indexesOfMatches] = findInliers(matches_a, matches_b)
ptsPerItr = 8;
maxInliers = 0;
errThreshold = 0.05;

Best_Fmatrix = zeros(3,3);
xa = [matches_a ones(size(matches_a,1),1)];
xb = [matches_b ones(size(matches_b,1),1)];

for i = 1:1000
    ind = randi(size(matches_a,1), [ptsPerItr,1]);
    FmatrixEstimate = Normalized_estimate_fundamental_matrix(matches_a(ind,:), matches_b(ind,:));   
    err = sum((xb .* (FmatrixEstimate * xa')'),2);
    currentInliers = size( find(abs(err) <= errThreshold) , 1);
    if (currentInliers > maxInliers)
       Best_Fmatrix = FmatrixEstimate; 
       maxInliers = currentInliers;
    end    
end

maxInliers
err = sum((xb .* (Best_Fmatrix * xa')'),2);
[Y,I]  = sort(abs(err),'ascend');
inliers_a = matches_a(I(1:maxInliers),:);
inliers_b = matches_b(I(1:maxInliers),:);
indexesOfMatches=I(1:maxInliers)


end
