function train_nodes(theNode, label_parent, conf)
    fprintf('\n\t Processing node: %s',theNode.label);
    if ~isfield(theNode,'leaf_indx')
        error('isfield(theNode,leaf_indx)');
    end
    num_leaf_indx =length(theNode.leaf_indx);
    fprintf('\n\t\t\t num_leaf_indx: %d',num_leaf_indx);
    if num_leaf_indx < 2       
        return;
    end
    if ~isfield(theNode,'children')        
        return;
    end
    
    filename_model = [label_parent,'.',theNode.label, '.model.mat'];
    pathToSaveModel = fullfile(conf.experiment.pathToHIC ,filename_model);
    if ~exist(pathToSaveModel,'file')
        train_instance_matrix = zeros(num_leaf_indx*30, 32000);
        train_label_vector = zeros(num_leaf_indx*30, 1);

        for leaf_id=1:num_leaf_indx
           tmp_leaf_id = theNode.leaf_indx(leaf_id);
           fprintf('\n Loading data of class %d with leaf_id=%d...',tmp_leaf_id,leaf_id);
           Data = HC.loadData(tmp_leaf_id, conf)   ;    
           train_instance_matrix( (leaf_id-1)*30+1:leaf_id*30,:) = Data.instance_matrix';
           train_label_vector((leaf_id-1)*30+1:leaf_id*30,:) = Data.label_vector';
        end

        if isfield(theNode,'children') 
            numChildren = length(theNode.children);
            fprintf('\n\t\t numChildren: %d',numChildren);
            if numChildren >0
                for child_id=1:numChildren
                    fprintf('\n\t\t\t Children: %d',child_id);                
                    Node = theNode.children(child_id);
                    if isfield(Node,'leaf_indx') 
                        num_child_leaf_indx =length(Node.leaf_indx);
                        fprintf('\n\t\t\t num_child_leaf_indx: %d',num_child_leaf_indx);
                        for child_leaf_id=1:num_child_leaf_indx
                            tmp_id = Node.leaf_indx(child_leaf_id);
                            idx = find(theNode.leaf_indx==tmp_id);
                            train_label_vector((idx-1)*30+1:idx*30,:) = child_id;
                        end
                    else
                        error('isfield(Node,leaf_indx)');
                    end                
                end
            else
                error('numChildren=0');
            end
        end
        fprintf('\n\t\t Training model of node: %s',theNode.label);
        num_classes = length(unique(train_label_vector))    
        model = train(train_label_vector, sparse(train_instance_matrix));    
        save(pathToSaveModel, 'model','train_label_vector','-v7.3');   
    end
    
    numChildren = length(theNode.children);
    for child_id=1:numChildren
        Node = theNode.children(child_id);
        train_nodes(Node, theNode.label, conf);
    end
end