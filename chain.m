function [FinalMatches] = chain( siftDescriptors, indexes )
    MatchesChain=0;
    for i=1:length(indexes)-1
        [matches] = vl_ubcmatch(siftDescriptors{indexes(i),2},siftDescriptors{indexes(i+1),2});
        if MatchesChain==0
            MatchesChain=zeros(length(indexes),size(matches,2));
            MatchesChain(1:2,:)=matches(:,:);
        end
        for j=1:size(MatchesChain,2)
            if MatchesChain(i,j)~=0
                indexOfMatch=find(matches(1,:)==MatchesChain(i,j));
                if length(indexOfMatch)==1 
                    MatchesChain(i+1,j)=matches(2,indexOfMatch);
                end
            end
        end
    end
    FinalMatches=zeros(size(MatchesChain,1),0);
    for j=1:size(MatchesChain,2)
        if MatchesChain(size(MatchesChain,1),j)~=0
            FinalMatches(1:size(MatchesChain,1),size(FinalMatches,2)+1)=MatchesChain(:,j);
        end
    end
    
end

