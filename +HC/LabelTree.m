% Large-Scale Image Classification
% NII
function [conf] =  LabelTree( conf,Q, isAuto)
   fprintf('\n -----------------------------------------------');   
   str_from = sprintf('_from_%s%s%s', conf.train.str_train,conf.val.str_val,conf.test.str_test);
   if isAuto==0
       
       fprintf('\n LabelTree: Manually Creating the label tree  %s ...', str_from);     
       str_auto = '_manual';
       str_Q='';       
   elseif isAuto==1
       fprintf('\n LabelTree: Automatical Creating the label tree %s ...', str_from);       
       str_auto = '_auto';
       str_Q = sprintf('_Q%d',Q);
   elseif isAuto==2
        fprintf('\n SVMTree: Automatical Creating the svm tree %s ...', str_from);       
        str_auto = '_svmtree';
        str_Q = '';
   end
  
    
    conf.randSeed = 1 ;
    randn('state',conf.randSeed) ;
    rand('state',conf.randSeed) ;
    vl_twister('state',conf.randSeed) ;
    
    pathToData = fullfile(conf.dir.rootDir,'data');
    utility.MakeDirectory( pathToData);
    pathToHIC = sprintf('hic%s%s',str_auto,str_Q);  
    conf.experiment.pathToHIC = fullfile(conf.path.pathToExperimentDir, pathToHIC);
    utility.MakeDirectory(conf.experiment.pathToHIC);
    
    
    
%     if strcmp( conf.datasetName,'Caltech256')  
%         RootNode_ID= 257;
%     elseif strcmp( conf.datasetName,'ILSVRC2010') 
%         RootNode_ID=1001;
%     else
%         error('conf.datasetName');
%     end
    
     RootNode_ID= conf.class.Num +1;
     if strcmp( conf.datasetName,'ILSVRC65')  
         RootNode_ID = 65;
     end
    
    fprintf('\n\t conf.datasetName: %s',conf.datasetName);
    fprintf('\n\t RootNode_ID: %d',RootNode_ID);
    fprintf('\n\t Q: %s',str_Q);
    fprintf('\n\t conf.experiment.pathToHIC: %s',conf.experiment.pathToHIC);
    
   
    
    file_name_meta = sprintf('meta%s%s%s.mat',str_auto,str_from,str_Q);    
    file_name_meta_leaf_indx =  sprintf('meta%s%s%s_leaf_indx.mat',str_auto,str_from,str_Q);
    file_name_meta_leaf_indx_model = sprintf('meta_leaf_indx_model.mat');
    path_file_name_meta_leaf_indx_model = fullfile(conf.experiment.pathToHIC, file_name_meta_leaf_indx_model);
    
    file_name_result_predict = sprintf('result.mat'); 
    path_file_name_result_predict = fullfile(conf.experiment.pathToHIC,file_name_result_predict);

%     if exist(path_file_name_result_predict,'file')
%        fprintf('\n LabelTree: Done !');       
%        return;
%     end
    
    path_file_name_meta = fullfile(pathToData, file_name_meta);
        
    if ~exist(path_file_name_meta,'file')
        fprintf('\n Building meta data ....');       
        synsets = HC.BuildMetaData(conf, Q, isAuto) ;         
        save(path_file_name_meta,'synsets','-v7.3');
        fprintf('done.');
    end
    
    path_file_name_meta_leaf_indx = fullfile(pathToData, file_name_meta_leaf_indx );
    if ~exist(path_file_name_meta_leaf_indx,'file')
        fprintf('\n Building leaf_indx for taxonomy ....');
        load(path_file_name_meta); 

        if isAuto==0
            RootNode = synsets(RootNode_ID);
            parent_indx = 0;
            [RootNode,synsets] = build_leaf_indx(RootNode,synsets,parent_indx)
            synsets(RootNode_ID).leaf_indx = RootNode.leaf_indx;
            synsets(RootNode_ID).parent_indx = RootNode.parent_indx;
        end
        save(path_file_name_meta_leaf_indx,'synsets','-v7.3');
        fprintf('done.');   
    end    
   
    
    if ~exist(path_file_name_meta_leaf_indx_model,'file')
        fprintf('\n Building models for taxonomy ....');
        load(path_file_name_meta_leaf_indx);
        [synsets] = HC.train_nodes_new(synsets,conf);
        save(path_file_name_meta_leaf_indx_model,'synsets','-v7.3');
        fprintf('done.');   
    else 
        fprintf('\n\t Loading synsets from file: %s ...  ', path_file_name_meta_leaf_indx_model);
        load(path_file_name_meta_leaf_indx_model);
        fprintf('done.'); 
    end
    RootNode = synsets(RootNode_ID);

   
    
    [Acc, SumNumConcept, MaxLevel,num_test_sample]=HC.LabelTree_Test(conf, synsets, RootNode );
    fprintf('\n\t Saving result test ....');
    save(path_file_name_result_predict, 'Acc', 'SumNumConcept', 'MaxLevel', 'num_test_sample', '-v7.3');
    fprintf('done.'); 
    
    Acc
    SumNumConcept
    MaxLevel
    num_test_sample
    
   

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
            elseif 1/ratio > 2
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
        [predicted_label, accuracy, decision_values] = predict(test_label_vector, test_instance_matrix, model(1), '-b 1');
    else
       decision_values_tmp; 
        for i=1:num_model
             [predicted_label_tmp(i), accuracy(i), decision_values_tmp] = predict(test_label_vector, test_instance_matrix, model(i), '-b 1');
             decision_values(i) = decision_values_tmp;
        end
        decision_values;
        [C,predicted_label] =  max(decision_values)
    end
    

end



