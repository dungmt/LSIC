function theNode = load_models(theNode, label_parent, conf)
    if ~isfield(theNode,'children')       
        theNode.model=[];
        return;
    end
    if ~isfield(theNode,'leaf_indx')
        error('isfield(theNode,leaf_indx)');
    end
    num_leaf_indx =length(theNode.leaf_indx);    
    if num_leaf_indx < 2  
         theNode.model=[];
        return;
    end
    
    filename_model = [label_parent,'.',theNode.label, '.model.mat'];
    pathToSaveModel = fullfile(conf.experiment.pathToHIC ,filename_model);
    if ~exist(pathToSaveModel,'file')
        error('File model not found %s',pathToSaveModel);
    end
    
    load(pathToSaveModel); %, 'model','train_label_vector','-v7.3'); 
    theNode.model = model;    
    numChildren = length(theNode.children);
    for child_id=1:numChildren
        Node = load_models(theNode.children(child_id),theNode.label,conf);
        theNode.children(child_id).model = Node.model;
        if isfield(Node,'children')
            theNode.children(child_id).children = Node.children;
        end
        
    end
end