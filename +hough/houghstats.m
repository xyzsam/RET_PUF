
sum_rows = sum(H,2);
[sorted_sum sorted_indices] = sort(sum_rows./max(sum_rows),'descend');
threshold = 0.9;
sorted_sum_t = sorted_sum(1:find(sorted_sum<0.5,1,'first')-1);
sorted_indices_t = sorted_indices(1:length(sorted_sum_t));
for i=1:length(sorted_indices_t)   
    weights = H(sorted_indices_t(i),:);
    weights_norm = weights./max(weights);
    [sorted_weights_norm sorted_weights_indices] = sort(weights_norm,'descend');
    sorted_weights_t = sorted_weights_norm(1:find(sorted_weights_norm<0.5,1,'first')-1);
    sorted_weights_indices_t = sorted_weights_indices(1:length(sorted_weights_t));
    slopes = tand(90.-T(sorted_weights_indices_t));
    peakLifetimes = (1./(slopes./dx)).*factor;
    lifetime_by_rho(i,1) = sum(peakLifetimes.*sorted_weights_t)/sum(sorted_weights_t); 
end

finalLifetime = sum(lifetime_by_rho.*sorted_sum_t)/sum(sorted_sum_t);