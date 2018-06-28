function [Matches] = FindTrackablePoints(M,beginframe,endframe)
% input the point view matrix startframe and endframe
%   Find points which are present in consecutive images
Matches=[];

for i=1:length(M)
    if any(M(beginframe:endframe,i),2) == ones(length(beginframe:endframe),1);
        Matches=[Matches M(beginframe:endframe,i)];
    end 
end
end

