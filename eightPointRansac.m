function [ inliers_a, inliers_b,indexesOfInliers] = eightPointRansac(p1, p2, matches, iter, thresh)

%matching points
p1_m = p1(matches(1,:),:)';
p2_m = p2(matches(2,:),:)';

%normalize points
[p1_m_norm,T_1]=normalizePoints( p1_m );
[p2_m_norm,T_2]=normalizePoints( p2_m );

%homogeneous points
p1_m_hom = [p1_m(1,:);p1_m(2,:); ones(1, length(p1_m))];
p2_m_hom = [p2_m(1,:);p2_m(2,:); ones(1, length(p2_m))];

%8-point-ransac
num_inliers_best = 0;

p1_8pr = [];
p2_8pr = [];

for i=1:iter
    
    %construct the A matrix, build_A selects 8 random matches
    A_norm_i = build_A(p1_m_norm,p2_m_norm);
    F_norm_i = get_F(A_norm_i);

    %denormalize
    F_denorm_i = T_2.'*F_norm_i*T_1;
    
    %find number of inliers with this F
    num_inliers_i = 0;
    
    p1_8pr_i = [];
    p2_8pr_i = [];
    
    for s=1:length(p1_m_hom)
        
        F_ps = F_denorm_i * p1_m_hom(:,s);
        F_T_ps = F_denorm_i.' * p1_m_hom(:,s);
        
        d_s = (p2_m_hom(:,s).'*F_denorm_i*p1_m_hom(:,s))^2 / ...
            (F_ps(1)^2 + F_ps(2)^2 + F_T_ps(1)^2 + F_T_ps(2)^2);
        
        if d_s < thresh 
            num_inliers_i = num_inliers_i + 1;
%            if sqrt((p1_m(1,s)-p2_m(1,s))^2+(p1_m(2,s)-p2_m(2,s))^2)<100
                %also collect the final matches 
            p1_8pr_i = [[p1_m(1,s); p1_m(2,s); s], p1_8pr_i];
            p2_8pr_i = [[p2_m(1,s); p2_m(2,s); s], p2_8pr_i];
%            end
        end
        
    end
    
    %if the number of inliers is greater than the number of inliers of the
    %best F found before, we save this F as the new best one
    if num_inliers_i > num_inliers_best
        num_inliers_best = num_inliers_i;
        p1_8pr = p1_8pr_i;
        p2_8pr = p2_8pr_i;
    end
     
    
end
inliers_a=p1_8pr(1:2,:);
inliers_b=p2_8pr(1:2,:);
indexesOfInliers=p1_8pr(3,:);

figure
plot(p1_8pr(1,:),p1_8pr(2,:),'r.');
hold on
plot(p2_8pr(1,:),p2_8pr(2,:),'b.')

for i=1:length(p1_8pr)
    plot([p1_8pr(1,i);p2_8pr(1,i)],[p1_8pr(2,i);p2_8pr(2,i)],'r');
end

end
