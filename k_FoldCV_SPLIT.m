function [traindat,validation]=k_FoldCV_SPLIT(data,k_fold,fold_num)
%-------------------------------------------------------------------
%--- K Fold Cross Validation----------------------------------------
%----------------------------------------------------------------------
% OUTPUT
% train:Train data for the fold number
% validation: Validation data for the fold number
%-------------------------------------------------------------------------
% INPUT
% data: The array of dataset(with the last value as the class 
%labels)
% k_fold: Number of Folds
% fold_num: The fold number
%--------------------------------------------------------------------------
n_samples=size(data,1);
fold_length=k_fold;
fold_index_max=ceil(n_samples/k_fold);
for fold_index=1:fold_index_max
 fold_start(fold_index)=(fold_index-1)*fold_length+1;
end
index=fold_start+fold_num-1;
index=index(find(index<=n_samples)); % Check if the Index Bound Exceeds
% traindat=[];
% validation=[];
fprintf('\n n_samples:%d',n_samples);
traindat   =zeros(length(index),size(data,2));
validation =zeros(n_samples - length(index),size(data,2));
vv=1;
tt=1;
% whos;
% pause;
% validation(:,:) = data(index(1,:),:);
% traindat(:,:) = data(setdiff((1:n_samples),index),:);
% whos;
% pause;
for i=1:n_samples
    fprintf('.');
    if any(index==i)
        %validation=[validation;data(i,:)];
        validation(vv,:)=data(i,:);
        vv =  vv+1;
    else
       % traindat=[traindat;data(i,:)];
        traindat(tt,:)=data(i,:);
        tt = tt+1;
    end
end
