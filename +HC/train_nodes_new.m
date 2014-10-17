function [synsets] = train_nodes_new(synsets,conf)
    
    num_sysnset = length(synsets);
%     dim_feature = conf.BOW.pooler.get_output_dim()
   
    if strcmp( conf.datasetName,'Caltech256')  
        RootNode_ID=257;
    elseif strcmp( conf.datasetName,'ILSVRC2010') 
        RootNode_ID=1001;
    elseif strcmp( conf.datasetName,'SUN397')  
        RootNode_ID=398;
     elseif strcmp( conf.datasetName,'ILSVRC65')  
        RootNode_ID=58;
    else
        error('conf.datasetName');
    end
    RootNode = synsets(RootNode_ID);        
    label_parent = RootNode.WNID;
 
 
 %   killed = [1001,1002, 1047,1062,1083,1084,1274];
  %  for i=1000:1274
    for i=1:num_sysnset
       
        theNode = synsets(i);
        names=fieldnames(theNode);
        node_id = getfield(theNode,names{1}) ;
        fprintf('\n\t train_nodes_new: Processing node: %s with ID =%d',theNode.WNID,node_id);
        if ~isfield(theNode,'leaf_indx')
            error('isfield(theNode,leaf_indx)');
        end
        num_leaf_indx =length(theNode.leaf_indx);
        fprintf('\n\t\t\t num_leaf_indx: %d',num_leaf_indx);
        if num_leaf_indx < 2       
            continue;
        end

        if(theNode.num_children>0)
            if theNode.parent_indx>0
                label_parent = synsets(theNode.parent_indx).WNID;
            else
                label_parent = RootNode.WNID;
            end
            filename_model = [label_parent,'.',theNode.WNID, '.model.mat'];  
            pathToSaveModel = fullfile(conf.experiment.pathToHIC ,filename_model);
            if ~exist(pathToSaveModel,'file')
                fprintf('\n Allocating memory for variables ...');
                train_instance_matrix = [];
                train_label_vector = [];

                for leaf_id=1:num_leaf_indx
                   tmp_leaf_id = theNode.leaf_indx(leaf_id);
                   fprintf('\n Loading data of class %d with leaf_id=%d...',tmp_leaf_id,leaf_id);
                   Data = HC.loadData(tmp_leaf_id, conf)       
                   train_instance_matrix = [train_instance_matrix, Data.instance_matrix];
                   train_label_vector = [train_label_vector,Data.label_vector];
                   
                end
                
                %cap nhan label
                length(unique(train_label_vector))
                train_label_vector_new =train_label_vector;
%                  pause
                if isfield(theNode,'children') 
                    numChildren = length(theNode.children);
                    fprintf('\n\t\t numChildren: %d',numChildren);
                    if numChildren >0
                        for child_id=1:numChildren
                            fprintf('\n\t\t\t Children: %d',child_id);                
                            Node = synsets( theNode.children(child_id));
                            if isfield(Node,'leaf_indx') 
                                num_child_leaf_indx =length(Node.leaf_indx);
                                fprintf('\n\t\t\t num_child_leaf_indx: %d',num_child_leaf_indx);
                                for child_leaf_id=1:num_child_leaf_indx
                                    Node.leaf_indx;
                                    tmp_id = Node.leaf_indx(child_leaf_id);
                                    %idx = find(theNode.leaf_indx==tmp_id)
                                    train_label_vector_new(1,find(train_label_vector==tmp_id)) = child_id;                                                                
%                              pause
                                end
                            else
                                error('isfield(Node,leaf_indx)');
                            end 
%                             whos
%                             pause
                        end
                    else
                        error('numChildren=0');
                    end
                end
                train_label_vector = train_label_vector_new;
                fprintf('\n\t\t Training model of node: %s',theNode.WNID);
                num_classes = length(unique(train_label_vector)) ;
                fprintf('\n\t\t\t num_classes: %d',num_classes);
                fprintf('\n\t\t\t num training sample: %d',length(train_label_vector));         
%                 
%                 max_item = 300000;
%                 
%                 if length(train_label_vector) > max_item 
%                     fprintf('\n Sampling node %d', i);                    
%                     sel_rand_indices = randperm(max_item);    
%                     train_label_vector = train_label_vector(sel_rand_indices);
%                     train_instance_matrix = train_instance_matrix(sel_rand_indices,:);
%                 end
% whos
%                             pause
        %         model = train(train_label_vector, sparse(train_instance_matrix)); 
                 libsvmoption='';
                 [model] = MyTrain(conf.svm.solver,train_label_vector, train_instance_matrix, libsvmoption);
                % model = train_node(train_label_vector, train_instance_matrix);   
                fprintf('\n\t\t\t Saving model into file .....');
                synsets(i).model = model;
                save(pathToSaveModel, 'model','train_label_vector','-v7.3');   
                fprintf('done.');
            else
                load(pathToSaveModel);
                synsets(i).model = model;
            end
        else
            error('theNode.num_children>0');
        end
    end    
end