function [inliers1Best,inliers2Best,indexesBest] = RANSAC(currentMatches, points1, points2, iterations, threshold)

    matchingPoints1 = points1(:,currentMatches(1,:));
    matchingPoints2 = points2(:,currentMatches(2,:));

    [Points1norm, Transform_1] = normalize_RANSAC(matchingPoints1);
    [Points2norm, Transform_2] = normalize_RANSAC(matchingPoints2);
    % add row of 1s
    Points1Hom = [Points1norm; ones(1, length(Points1norm))];
    Points2Hom = [Points2norm; ones(1, length(Points2norm))];

    %8-point-ransac
    maxInlers = 0;
    inliers1Best = [];
    inliers2Best = [];
    indexesBest =[];

    for i=1:iterations
        % Randomize points
        IndicesRandomized = randsample(length(Points1Hom),8);

        EightPoints1 = Points1Hom(:,IndicesRandomized);
        EightPoints2 = Points2Hom(:,IndicesRandomized);
        x1=EightPoints1(1,:);
        x2=EightPoints2(1,:);
        y1=EightPoints1(2,:);
        y2=EightPoints2(2,:);

        % Get A matrix
        A = [];
        for j=1:8
            l = [x1(j)*x2(j) x1(j)*y2(j) x1(j) y1(j)*x2(j) y1(j)*y2(j) y1(j) x2(j) y2(j) 1];
            A = [A;l];
        end

        % Ger F matrix and enforce signularity of F
        [~,~,V] = svd(A);
        F_coordinates = V(:,8);
        F = [F_coordinates(1:3)';F_coordinates(4:6)'; F_coordinates(7:9)'].';
        [UofF,SofF,VofF] = svd(F);
        SofF(3,3) = 0;
        F = UofF .* SofF .* VofF.';
        %denormalize F
        F_denormalized = Transform_2.'*F*Transform_1;

        currentInliers = 0;

        inliers1 = [];
        inliers2 = [];
        indexes=[];
        
        for j=1:length(Points1Hom)

            FPoints = F_denormalized * Points1Hom(:,j);
            FTransformedPoints = F_denormalized.' * Points1Hom(:,j);

            currentResult = (Points2Hom(:,j).'*F_denormalized*Points1Hom(:,j))^2 /(FPoints(1)^2 + FPoints(2)^2 + FTransformedPoints(1)^2 + FTransformedPoints(2)^2);

            if currentResult < threshold 
                currentInliers = currentInliers + 1;
                inliers1 = [inliers1,[matchingPoints1(1,j); matchingPoints1(2,j)]];
                inliers2 = [inliers2,[matchingPoints2(1,j); matchingPoints2(2,j)]];
                indexes=[indexes,[currentMatches(1,j); currentMatches(2,j)]];
            end
        end
        if currentInliers > maxInlers
            maxInlers = currentInliers;
            inliers1Best = inliers1;
            inliers2Best = inliers2;
            indexesBest =indexes;
        end  
    end
%  maxInlers
%  figure
%  plot(inliers1Best(1,:),inliers1Best(2,:),'r.');
%  hold on
%  plot(inliers2Best(1,:),inliers2Best(2,:),'b.')
%  
%  for i=1:length(inliers1Best)
%      plot([inliers1Best(1,i);inliers2Best(1,i)],[inliers1Best(2,i);inliers2Best(2,i)],'r');
%  end
end

