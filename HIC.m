% Large-Scale Image Classification
% NII
function HIC(conf, dataset, start_Idx,end_Idx, step,ci_start,ci_end)

    
    pathToData = fullfile(conf.dir.rootDir,'data');
    MakeDirectory( pathToData);
   
    conf.experiment.pathToHIC = fullfile(conf.path.pathToExperimentDir, 'hic_new_model');
    MakeDirectory(conf.experiment.pathToHIC);
    
    
    if strcmp( conf.datasetName,'Caltech256')  
        RootNode_ID=257;
    elseif strcmp( conf.datasetName,'ILSVRC2010') 
        RootNode_ID=1001;
    else
        error('conf.datasetName');
    end
            
    khong_dung_cach_de_qui = true;
    if khong_dung_cach_de_qui
    
        path_file_name_meta = fullfile(pathToData, 'meta.mat');
        if ~exist(path_file_name_meta,'file')
            fprintf('\n Building meta data ....');
            synsets = HC.BuildMetaData_Manually_Caltech256(conf);
            save(path_file_name_meta,'synsets','-v7.3');
            fprintf('done.');
        end

        path_file_name_meta_leaf_indx = fullfile(pathToData, 'meta_leaf_indx.mat');
        if ~exist(path_file_name_meta_leaf_indx,'file')
            fprintf('\n Building leaf_indx for taxonomy ....');
            load(path_file_name_meta); 
            
            RootNode = synsets(RootNode_ID);
            parent_indx = 0;
            [RootNode,synsets] = build_leaf_indx(RootNode,synsets,parent_indx)
            synsets(RootNode_ID).leaf_indx = RootNode.leaf_indx;
            synsets(RootNode_ID).parent_indx = RootNode.parent_indx;
            save(path_file_name_meta_leaf_indx,'synsets','-v7.3');
            fprintf('done.');   
        end    
        path_file_name_meta_leaf_indx_model = fullfile(conf.experiment.pathToHIC, 'meta_leaf_indx_model.mat');
        if ~exist(path_file_name_meta_leaf_indx_model,'file')
            fprintf('\n Building models for taxonomy ....');
            load(path_file_name_meta_leaf_indx);
            [synsets] = train_nodes_new(synsets,conf);
            save(path_file_name_meta_leaf_indx_model,'synsets','-v7.3');
            fprintf('done.');   
        else 
            fprintf('\n\t Loading synsets from file: %s ...  ', path_file_name_meta_leaf_indx_model);
            load(path_file_name_meta_leaf_indx_model);
            fprintf('done.'); 
        end
        RootNode = synsets(RootNode_ID);
    else
        Taxonomy = HC.Caltech256_Nodes();
        train_nodes(Taxonomy,Taxonomy.label, conf);
        Taxonomy = load_models(Taxonomy,Taxonomy.label, conf);
        save('/data/Dataset/Taxonomy.mat', 'Taxonomy','-v7.3'); 
        RootNode = Taxonomy;
    end
    
  [Acc, SumNumConcept, MaxLevel,num_test_sample] = HC.LabelTree_Test(conf) 

end
function [synsets] = train_nodes_new(synsets,conf)
    
    num_sysnset = length(synsets);
    dim_feature = conf.BOW.pooler.get_output_dim()
    num_train_images = conf.IMDB.num_images_train
    if strcmp( conf.datasetName,'Caltech256')  
        RootNode_ID=257;
    elseif strcmp( conf.datasetName,'ILSVRC2010') 
        RootNode_ID=1275;
    else
        error('conf.datasetName');
    end
    RootNode = synsets(RootNode_ID);        
    label_parent = RootNode.WNID;
 
    for i=1:num_sysnset
   % for i=1200:1274
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
                train_instance_matrix = zeros(num_leaf_indx*num_train_images, dim_feature);
                train_label_vector = zeros(num_leaf_indx*num_train_images, 1);

                for leaf_id=1:num_leaf_indx
                   tmp_leaf_id = theNode.leaf_indx(leaf_id);
                   fprintf('\n Loading data of class %d with leaf_id=%d...',tmp_leaf_id,leaf_id);
                   Data = HC.loadData(tmp_leaf_id, conf)       
                   train_instance_matrix( (leaf_id-1)*num_train_images+1:leaf_id*num_train_images,:) = Data.instance_matrix';
                   train_label_vector((leaf_id-1)*num_train_images+1:leaf_id*num_train_images,:) = Data.label_vector';
                end
                
                %cap nhan label
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
                                    tmp_id = Node.leaf_indx(child_leaf_id);
                                    idx = find(theNode.leaf_indx==tmp_id);
                                    train_label_vector((idx-1)*num_train_images+1:idx*num_train_images,:) = child_id;
                                end
                            else
                                error('isfield(Node,leaf_indx)');
                            end                
                        end
                    else
                        error('numChildren=0');
                    end
                end
                fprintf('\n\t\t Training model of node: %s',theNode.WNID);
                num_classes = length(unique(train_label_vector))    
                % model = train(train_label_vector, sparse(train_instance_matrix));    
                model = train_node(train_label_vector, train_instance_matrix);   
                synsets(i).model = model;
                save(pathToSaveModel, 'model','train_label_vector','-v7.3');   
            else
                load(pathToSaveModel);
                synsets(i).model = model;
            end
        else
            error('theNode.num_children>0');
        end
    end    
end
function model = train_node(train_label_vector, train_instance_matrix)
%     if ~issparse(train_instance_matrix)
%         train_instance_matrix = sparse(train_instance_matrix);
%     end
    label_vector = unique(train_label_vector);
    num_label_vector = length(label_vector);
    fprintf('\n num_label_vector %d',num_label_vector);
    if (num_label_vector<3)
        fprintf('\n Training model: num_label_vector %d',num_label_vector);
        model(1) = train(train_label_vector, sparse(train_instance_matrix));
    else
        for i=1: num_label_vector        
            pos_training_label_vector = find(train_label_vector ==label_vector(i));
            neg_training_label_vector = setdiff((1:length(train_label_vector)), pos_training_label_vector);
            tmpp_num_neg = length(neg_training_label_vector);
            tmpp_num_pos = length(pos_training_label_vector);
            svm_training_label_vector       = ones(tmpp_num_pos,1);
            svm_training_instance_matrix    = train_instance_matrix(pos_training_label_vector,:);  
            num_pos = sum(train_label_vector == label_vector(i));
            num_neg = sum(train_label_vector ~= label_vector(i));
            ratio = num_pos / num_neg;
            options='';
            if ratio > 2
                options = sprintf(' -w-1 %f -w1 1',  ratio);
            elseif 1/ratio >= 2
                options = sprintf(' -w-1 1 -w1 %f ',  1/ratio);
            end
            labels_tmp =  -1+0*train_label_vector(neg_training_label_vector,:);
            svm_training_label_vector       = cat(1,svm_training_label_vector,   labels_tmp   );              
            svm_training_instance_matrix    = cat(1,svm_training_instance_matrix, train_instance_matrix(neg_training_label_vector,:) );    
            fprintf('\n Training model %d, num_pos=%d, num_neg=%d ',i,num_pos,num_neg);
            model(i) = train(svm_training_label_vector, sparse(svm_training_instance_matrix),options)
        end
    end

end
function [predicted_label, accuracy, decision_values] = predict_node(test_label_vector, test_instance_matrix, model)

    num_model = length(model);
    if num_model < 2
         fprintf('\n predict_node: num_model=%d',num_model);
        [predicted_label, accuracy, decision_values] = predict(test_label_vector, test_instance_matrix, model(1), '-b 1');
        pause
    else
       
        for i=1:num_model
             fprintf('\n predict_node: model(%d)',i);
             [predicted_label_tmp, accuracy_tmp, decision_values_tmp] = predict(test_label_vector, test_instance_matrix, model(i))
             decision_values(i) = decision_values_tmp(1);
             accuracy(i) = accuracy_tmp(1);
             pause
        end
        decision_values
        [C,predicted_label] =  max(decision_values)
        pause
    end
    

end
function [leaf_indx,level, num_concept] = test_nodes_new(theNode, synsets, level,num_concept, test_label_vector, test_instance_matrix)
    leaf_indx =0;  
    if ~isfield(theNode,'model')  
        return;
    end
    %[predicted_label, accuracy, decision_values] = predict(test_label_vector, test_instance_matrix, theNode.model, '-b 1'); 
    %    num_concept = num_concept + length(theNode.model.Label);
    [predicted_label, accuracy, decision_values] = predict_node(test_label_vector, test_instance_matrix, theNode.model);
    num_concept = num_concept + length(theNode.model);
    
    id_predicted_label = theNode.children(predicted_label);
    fprintf('\n predicted_label: %d',predicted_label );
    fprintf('\n id_predicted_label: %d \t',id_predicted_label );
    predicted_Node = synsets(id_predicted_label);
    if ~isempty(theNode.children) && ~isempty(predicted_Node.model)
        level = level+1;
        [leaf_indx,level,num_concept] = test_nodes_new(predicted_Node, synsets, level, num_concept,test_label_vector, test_instance_matrix);
    else
       %% leaf_indx = theNode.leaf_indx(predicted_label); %predicted_label;
       %? leaf_indx = predicted_Node.leaf_indx(predicted_label); %predicted_label;
       leaf_indx =  predicted_Node.leaf_indx;
        fprintf('Nhan du doan la: %d',leaf_indx );
        fprintf('  Gia tri level: %d',level );
%         theNode.leaf_indx
    end
    
end
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
