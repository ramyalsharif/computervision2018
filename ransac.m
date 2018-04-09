function [bestX,maxInliers] = ransac( matches,frames1,desc1,frames2,desc2,Ntimes,threshold)
    maxInliers=0;
    bestX=[];
    for i=1:Ntimes
        %get permutation
        perm = randperm(length(matches));
        seed = perm(1:3);

        currentMatches=matches(:,seed);
        A=[];
        b=[];
        for j=1:size(currentMatches,2)
            coords1=frames1(1:2,currentMatches(1,j));
            coords2=frames2(1:2,currentMatches(2,j));
            currentA=[coords1(1),coords1(2),0,0,1,0;0,0,coords1(1),coords1(2),0,1];
            currentB=[coords2(1);coords2(2)];
            A=[A;currentA];
            b=[b;currentB];
        end

        x = pinv(A)* b;%didnt include the ' , might be a mistake
        A=[];
        b=[];
        for j=1:size(matches,2)
            coords1=frames1(1:2,matches(1,j));
            coords2=frames2(1:2,matches(2,j));
            currentA=[coords1(1),coords1(2),0,0,1,0;0,0,coords1(1),coords1(2),0,1];
            currentB=[coords2(1);coords2(2)];
            A=[A;currentA];
            b=[b;currentB];
        end

        bTransformed=A*x;
        inliers=0;
        for j=1:length(b)/2
           c11=b(j*2-1);
           c12=b(j*2);
           c21=bTransformed(j*2-1);
           c22=bTransformed(j*2);
           dist=sqrt((c11-c21)^2+(c12-c22)^2);
           if dist<threshold
                inliers=inliers+1;
           end
        end
        if inliers>maxInliers
            maxInliers=inliers;
            bestX=x;
        end    
    end
end

