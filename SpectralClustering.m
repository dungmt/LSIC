function [C, L, U] = SpectralClustering(W, nClusters, Type, Q, H)
%SPECTRALCLUSTERING Executes spectral clustering algorithm
%   Executes the spectral clustering algorithm defined by
%   Type on the adjacency matrix W and returns the k cluster
%   indicator vectors as columns in C.
%   If L and U are also called, the (normalized) Laplacian and
%   eigenvectors will also be returned.
%
%   'W' - Adjacency matrix, needs to be square
%   'k' - Number of clusters to look for
%   'Type' - Defines the type of spectral clustering algorithm
%            that should be used. Choices are:
%      1 - Unnormalized
%      2 - Normalized according to Shi and Malik (2000)
%      3 - Normalized according to Jordan and Weiss (2002)
%
%   References:
%   - Ulrike von Luxburg, "A Tutorial on Spectral Clustering", 
%     Statistics and Computing 17 (4), 2007
%
%   Author: Ingo Buerk
%   Year  : 2011/2012
%   Bachelor Thesis

% calculate degree matrix
degs = sum(W, 2);
D    = sparse(1:size(W, 1), 1:size(W, 2), degs);

% compute unnormalized Laplacian
L = D - W;


% compute normalized Laplacian if needed
switch Type
    case 2
        % avoid dividing by zero
        degs(degs == 0) = eps;
        % calculate inverse of D
        D = spdiags(1./degs, 0, size(D, 1), size(D, 2));
        
        % calculate normalized Laplacian
        L = D * L;
    case 3
        % avoid dividing by zero
        degs(degs == 0) = eps;
        % calculate D^(-1/2)
        D = spdiags(1./(degs.^0.5), 0, size(D, 1), size(D, 2));
        
        % calculate normalized Laplacian
        L = D * L * D;
end

% compute the eigenvectors corresponding to the k smallest
% eigenvalues
diff   = eps;
[U, ~] = eigs(L, nClusters, diff);

% in case of the Jordan-Weiss algorithm, we need to normalize
% the eigenvectors row-wise
if Type == 3
    U = bsxfun(@rdivide, U, sqrt(sum(U.^2, 2)));
end

% now use the k-means algorithm to cluster U row-wise
% C will be a n-by-1 matrix containing the cluster number for
% each data point
% [idx,ctrs]  = kmeans(U, k, 'start', 'cluster', ...
%                  'EmptyAction', 'singleton');
% C = kmeans(U, k, 'start', 'cluster', ...
%                  'EmptyAction', 'singleton');
% % [~, k] = min(vl_alldist(U, ctrs)) ;
num_clusters = nClusters;
disp('Performing eigendecomposition...');
OPTS.disp = 0;
[V, val] = eigs(L, num_clusters, 'LM', OPTS);
% V=U;
% U=V;
% 
% % Do k-means
% 
% disp('Performing kmeans...');
% % Normalize each row to be of unit length
 sq_sum = sqrt(sum(V.*V, 2)) + 1e-20;
 U = V ./ repmat(sq_sum, 1, num_clusters);
% clear sq_sum V;
% cluster_labels = k_means(U, [], num_clusters);


    data_vl_kmeans = U';
    data_vl_kmeans(isnan(data_vl_kmeans))=0;
    [centers, assignments] = vl_kmeans(data_vl_kmeans, nClusters,'Initialization', 'plusplus','Algorithm','Elkan') ;   
    
    
    
    label = unique(assignments);
    while length(label)<nClusters
        fprintf('\nLoop: length(label)=%d', length(label));
        U
        pause
        U(isnan(U))=0;
        U
        pause
        
        
        [idx,ctrs]  = kmeans(U, nClusters, 'start', 'cluster', 'EmptyAction', 'singleton','Replicates',5,'Distance','city');
         label_idx = unique(idx);
        if length(label_idx)==nClusters
            assignments = idx;
            centers = ctrs';
            break;
        end
        data_vl_kmeans = data_vl_kmeans + eps
        L = D - W;
        diff   = eps;
        [U, ~] = eigs(L, nClusters, diff);
        data_vl_kmeans = U'
        [centers, assignments] = vl_kmeans(data_vl_kmeans, nClusters,'Algorithm','Elkan') ;      
        label = unique(assignments);
        pause;
    end
    
    bincounts = histc(assignments,label);

    
    
    % Nhung nhom da du thi minh khong xet nua
    num_class = size(W,1);
    QH = power(Q,H);
    if(QH < num_class)
        fprintf('SpectralClustering:power(Q,H)<num_class');
    end
    
    num_child_in_cluster = floor(num_class/Q + 0.5);
    max_label_new = max(label)+1;
    fprintf('\n SpectralClustering:Q=%d',Q);
    fprintf('\n SpectralClustering:num_class=%d',num_class);
    fprintf('\n SpectralClustering:num_child=%d',num_child_in_cluster);
    fprintf('\n SpectralClustering:max_label_new=%d',max_label_new);
    fprintf('\n SpectralClustering:num_child_in_cluster=%d',num_child_in_cluster);
    if (num_child_in_cluster < Q)
        num_child_in_cluster = Q;
    end
%     pause;
   
%% =========================================================================

   for ki =1:size(data_vl_kmeans,1)
            for li =1:size(data_vl_kmeans,2)            
                if imag(data_vl_kmeans(ki,li)) ~=0
                    data_vl_kmeans(ki,li) =  abs(data_vl_kmeans(ki,li));
                end
           
            end
   end
        
    label_greater = find(bincounts>num_child_in_cluster)
    label_lesser = find(bincounts<num_child_in_cluster);
    centers_lesser = centers(:,label_lesser);

    %cac anh co label lon
    num_items_du = sum(bincounts(label_greater)) - num_child_in_cluster* length(label_greater);

    assignments_new =assignments;
    bincounts_new =bincounts;
    
    bincounts_new(max_label_new)=0;
    % Xu ly cac gia tri du class
    for i = 1: length(label_greater)
        idx_items_du_in_assignments = find(assignments==label_greater(i));
        if length(idx_items_du_in_assignments)<1
            continue;
        end
        items_in_assignments = data_vl_kmeans(:,idx_items_du_in_assignments);
        
    
        
        khoangcach_selft = vl_alldist(items_in_assignments, centers(:,label_greater(i)));
        [sx,ix] = sort(khoangcach_selft);    
        idx_giulai_in_items_in_assignments = ix(1:num_child_in_cluster);
        idx_condu_in_items_in_assignments = ix(num_child_in_cluster+1:length(ix));
        assignments_new(idx_items_du_in_assignments(idx_condu_in_items_in_assignments)) = max_label_new;      
        
        bincounts_new(label_greater(i))=num_child_in_cluster;
        bincounts_new(max_label_new)=bincounts_new(max_label_new) + length(idx_condu_in_items_in_assignments);
    end
    
    bincounts = bincounts_new;
    assignments = assignments_new;
    
    %% -----------------------------------
while true    
    assignments_new =assignments;
    bincounts_new =bincounts
%     pause;
    num_items_du = bincounts_new(max_label_new);
     if(num_items_du<1)
        break;
     end
    
    label_lesser = find(bincounts_new(1:max_label_new-1) < num_child_in_cluster);
    centers_lesser = centers(:,label_lesser);
    if(isempty(label_lesser))
        break;
    end
    
    items_du = zeros(size(data_vl_kmeans,1), num_items_du);   
    idx_items_du_in_assignments = find(assignments_new == max_label_new);
    
    items_du = data_vl_kmeans(:, idx_items_du_in_assignments);
    
    khoangcach_less = vl_alldist(items_du, centers_lesser);
    
    [c_min, label_of_classes_lesser] = min(khoangcach_less,[],2);
    
    unique_label_of_classes_lesser = unique(label_of_classes_lesser);
    bincounts_i_min = histc(label_of_classes_lesser,unique_label_of_classes_lesser);
    % uu tien cac gia tri nho dua vao cluster tuong ung
    [ss,is] = sort(bincounts_i_min);
    
    for idxis =1: length(is)

        label_assignment=label_lesser(unique_label_of_classes_lesser(is(idxis)));
        idx_items_du_selected = find(label_of_classes_lesser == unique_label_of_classes_lesser(is(idxis)));
        label_assignment=label_lesser(unique_label_of_classes_lesser(is(idxis)));
        idx_assignment = idx_items_du_in_assignments(idx_items_du_selected);
        

        num_items_du_selected = length(idx_items_du_selected);
        num_item_assigned = bincounts_new(label_assignment);
        num_items_available = num_child_in_cluster - num_item_assigned;
        if num_items_du_selected <= num_items_available
            assignments_new(idx_assignment) = label_assignment;
            bincounts_new(label_assignment)= bincounts_new(label_assignment)+ num_items_du_selected;
            % update center lai
            item_selected= find(assignments_new==label_assignment);
            centers_recomputed = sum(data_vl_kmeans(:,item_selected),2)/ length(item_selected);            
            centers(:,label_assignment) = centers_recomputed;
            bincounts_new(max_label_new) =  bincounts_new(max_label_new) - num_items_du_selected;
        else
            khoangcach_less_items_du_selected = khoangcach_less(idx_items_du_selected);
            [sss,iss] = sort(khoangcach_less_items_du_selected);
            idx_assignment_selected = iss(1:num_items_available);        
            assignments_new(idx_assignment(idx_assignment_selected)) = label_assignment;            

            % Cap nhat so luong phan tu, gia tri khoangcach,...
            bincounts_new(label_assignment)= bincounts_new(label_assignment)+ num_items_available;
            bincounts_new(max_label_new) =  bincounts_new(max_label_new) - num_items_available;

        end
    
    end
    bincounts = bincounts_new;
    assignments = assignments_new;
end

 
% now convert C to a n-by-k matrix containing the k indicator
% vectors as columns
% C = sparse(1:size(D, 1), C, 1);

%% Edit by mtdung

% num_class = size(W,1);
% K = power(Q,H);
% if(K < num_class)
%     error('K<num_class');
% end
% Cluster cac leaf nodes
% Gom cac node la thanh cac cluster, moi cluster co <=Q leaf, 

C = assignments;

end