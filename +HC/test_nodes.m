
function [leaf_indx,level] = test_nodes(theNode, level, test_label_vector, test_instance_matrix)
    leaf_indx =0;  
    if ~isfield(theNode,'model')  
        return;
    end
    [predicted_label, accuracy, decision_values] = predict(test_label_vector, test_instance_matrix, theNode.model, '-b 1'); 
%     predicted_label
    if isfield(theNode,'children') && ~isempty(theNode.children(predicted_label).model)
        level = level+1;
        [leaf_indx,level] = test_nodes(theNode.children(predicted_label), level, test_label_vector, test_instance_matrix);
    else
        leaf_indx = theNode.leaf_indx(predicted_label); %predicted_label;
        fprintf('Nhan du doan la: %d',leaf_indx );
        fprintf('\nGia tri level: %d',level );
%         theNode.leaf_indx
    end
end