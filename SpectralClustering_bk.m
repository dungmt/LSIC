function [C, L, U] = SpectralClustering(W, k, Type, Q, H)
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
[U, ~] = eigs(L, k, diff);

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

    data_vl_kmeans = U';
    [centers, assignments] = vl_kmeans(data_vl_kmeans, k,'Initialization', 'plusplus') ;      
    label = unique(assignments);
    bincounts = histc(assignments,label);

    % Nhung nhom da du thi minh khong xet nua
    num_class = size(W,1);
    num_child = num_class/Q;
    max_label_new = max(label)+1;
  
%% =========================================================================
    label_greater = find(bincounts>num_child);
    label_lesser = find(bincounts<num_child);
    centers_lesser = centers(:,label_lesser);

    %cac anh co label lon
    num_items_du = sum(bincounts(label_greater)) - num_child* length(label_greater);

    items_du = zeros(size(data_vl_kmeans,1), num_items_du);
    idx_item_du = zeros(num_items_du,1);
    idx=1;

    assignments_new =assignments;
    bincounts_new =bincounts;
    
    bincounts_new(max_label_new)=0;
    for i = 1: length(label_greater)
        idx_items_in_assignments = find(assignments==label_greater(i));
        items_in_assignments= data_vl_kmeans(:,idx_items_in_assignments);
        
        khoangcach_selft = vl_alldist(items_in_assignments, centers(:,label_greater(i)));
        [sx,ix] = sort(khoangcach_selft);    
        idx_giulai_in_items_in_assignments = ix(1:num_child);
        idx_condu_in_items_in_assignments = ix(num_child+1:length(ix));
        assignments_new(idx_items_in_assignments(idx_condu_in_items_in_assignments)) = max_label_new;       
        
        for k=num_child+1: length(ix)
             items_du( :, idx) = items_in_assignments(:, ix(k));
             idx_item_du(idx) = idx_items_in_assignments(ix(k));             
             idx = idx +1;
        end
        
        bincounts_new(label_greater(i))=num_child;
        bincounts_new(max_label_new)=bincounts_new(max_label_new) + length(idx_condu_in_items_in_assignments);
        
        bincounts(label_greater(i)) = bincounts(label_greater(i))- num_child;
    end
       
    
    
    khoangcach_less = vl_alldist(items_du, centers_lesser);
    [c_min, i_min] = min(khoangcach_less,[],2);
    
    i_min_u = unique(i_min);
    bincounts_i_min = histc(i_min,i_min_u);
    % uu tien cac gia tri nho dua vao cluster tuong ung
    [ss,is] = sort(bincounts_i_min);
    
    for idxis =1: length(is)

        label_assignment=i_min_u(is(idxis));
        idx_items_du_selected = find(i_min == label_assignment);

        idx_assignment = idx_item_du(idx_items_du_selected);
        label_assignment=i_min_u(is(idxis));

        num_items_du_selected = length(idx_items_du_selected);
        num_item_assigned = bincounts(label_assignment);
        num_items_available = num_child - num_item_assigned;
        if num_items_du_selected <= num_items_available
            assignments(idx_assignment) = label_assignment;
            bincounts(label_assignment)= bincounts(label_assignment)+ num_items_du_selected;
            % update center lai
            item_selected= find(assignments==label_assignment);
            centers_recomputed = sum(data_vl_kmeans(:,item_selected),2)/ length(item_selected);            
            centers(label_assignment) = centers_recomputed;
        else
            khoangcach_less_items_du_selected = khoangcach_less(idx_items_du_selected);
            [sss,iss] = sort(khoangcach_less_items_du_selected);
            idx_assignment_selected = iss(1:num_items_available);        
            assignments(idx_assignment(idx_assignment_selected)) = label_assignment;            

            % Cap nhat so luong phan tu, gia tri khoangcach,...
            bincounts(label_assignment)= bincounts(label_assignment)+ num_items_available;

        end
    
    end
    



% Lay cac phan tu tu nhieu cho vao it.


 
 
 [~, k] = min(vl_alldist(U', centers)) ;
 
% now convert C to a n-by-k matrix containing the k indicator
% vectors as columns
C = sparse(1:size(D, 1), C, 1);

%% Edit by mtdung

% num_class = size(W,1);
% K = power(Q,H);
% if(K < num_class)
%     error('K<num_class');
% end
% Cluster cac leaf nodes
% Gom cac node la thanh cac cluster, moi cluster co <=Q leaf, 


end