function [error] = eval_flat2 ( pred, gt, max_num_pred_per_image )
% Evaluate flat error
% predict_file: each line is the predicted labels ( must be positive
% integers, seperated by white spaces ) for one image, sorted by
% confidence in descending order. The number of labels per line can vary, but not
% more than max_num_pred_per_image ( extra labels are ignored ).
% gtruth_file: each line is the ground truth labels, in the same format.

% pred = dlmread(predict_file);
% gt = dlmread(gtruth_file);

if size(pred,2) > max_num_pred_per_image
    pred = pred(:,1:max_num_pred_per_image);
end
 fprintf('\n size(pred,1)=%d', size(pred,1));
 fprintf('\n size(gt,1)=%d', size(gt,1));
whos;

% assert(size(pred,1)==size(gt,1));

pred = [pred, zeros(size(pred,1),1)];

c = zeros(size(pred,1),1);
for j=1:size(gt,2) %for each ground truth label
    x = gt(:,j) * ones(1,size(pred,2));
    c = c + min( x ~= pred, [], 2);
end

n = sum(gt~=0,2);

error = sum(c./n)/size(pred,1);




