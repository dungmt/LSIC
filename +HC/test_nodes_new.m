function [leaf_indx,level, num_concept] = test_nodes_new(theNode, synsets, level,num_concept, test_label_vector, test_instance_matrix)
    leaf_indx =0;  
    if ~isfield(theNode,'model')  
        return;
    end
    [predicted_label, accuracy, decision_values] = predict(test_label_vector, test_instance_matrix, theNode.model, '-b 1');
%      pause
    %[predicted_label, accuracy, decision_values] = predict_node(test_label_vector, test_instance_matrix, theNode.model)
    %num_concept = num_concept + length(theNode.model.Label);
    if ~isempty(theNode.model)
        num_concept = num_concept + theNode.model.nr_class;
    end
    id_predicted_label = theNode.children(predicted_label);
    fprintf('\n predicted_label: %d',predicted_label );
    fprintf('\t id_predicted_label: %d \t',id_predicted_label );
    predicted_Node = synsets(id_predicted_label);
    if ~isempty(theNode.children) && ~isempty(predicted_Node.model)
        level = level+1;
        [leaf_indx,level,num_concept] = HC.test_nodes_new(predicted_Node, synsets, level, num_concept,test_label_vector, test_instance_matrix);
    else
       %% leaf_indx = theNode.leaf_indx(predicted_label); %predicted_label;
       %? leaf_indx = predicted_Node.leaf_indx(predicted_label); %predicted_label;
       leaf_indx =  predicted_Node.leaf_indx;
        fprintf('Nhan du doan la: %d',leaf_indx );
        fprintf('  Gia tri level: %d',level );
%         theNode.leaf_indx
    end
end