
function [VL_AP, M_VL_AP, error_flat, Acc] =  Evaluate(scores_matrix, label_vector )   
% very important : scores_matrix = num_Classes x num_Images;
    if (size(scores_matrix,1) > size(scores_matrix,2))
        scores_matrix = scores_matrix';
    end
    num_Classes = size(scores_matrix,1);
    num_Images  = size(scores_matrix,2);
   fprintf('\n\t\t num_Classes = %d',num_Classes); 
   fprintf('\n\t\t num_Images = %d',num_Images);
   fprintf('\n\t\t length(label_vector) = %d',length(label_vector));
   
    assert(num_Classes>0);
    assert(num_Images == length(label_vector) );
    
    [~,bb] = max(scores_matrix,[],1);
    [Confusion,~] = confusionmat(label_vector,bb);
    n_classes = size(Confusion,1);
    assert(num_Classes==n_classes);
    
    num_predicted_true = sum(diag(Confusion));
    Acc = num_predicted_true / sum(sum(Confusion));

    
    VL_AP   = zeros(num_Classes,1);
    VL_AUC  = zeros(num_Classes,1);
    VL_AP_INTERP_11 = zeros(num_Classes,1);
   
    
    M_VL_AP = 0;    
    
    for ci=1:num_Classes 
    
        label_vector_gt = -ones(length(label_vector),1);
        sortidx = find(label_vector ==ci);
        label_vector_gt(sortidx) = 1;

        scores = scores_matrix(ci,:);

        [rc, pr, info] = vl_pr(label_vector_gt, scores) ;
%         disp(info.auc) ;
%         disp(info.ap) ;
%         disp(info.ap_interp_11) ;

     

        VL_AP(ci) = info.ap;             
        VL_AUC(ci) = info.auc;
        VL_AP_INTERP_11(ci) = info.ap_interp_11;
        M_VL_AP = M_VL_AP +info.ap;
        fprintf('.');
    end
    M_VL_AP = M_VL_AP/num_Classes;
    % Tinh Evaluting flat error ...'
            
    val_label_vector = label_vector';
    num_predictions_per_image =10;
    % predict the top labels
    scores_matrix = scores_matrix';
    [scores,pred_test]=sort(scores_matrix,2,'descend');
    pred_test = pred_test(:,1:num_predictions_per_image);
    scores = pred_test(:,1:num_predictions_per_image);


    %evaluation
    error_flat =zeros(num_predictions_per_image,1);       

%     for ti=1:num_predictions_per_image
%         error_flat(ti) = eval_flat2(pred_test,val_label_vector, ti);   
%     end
 
end