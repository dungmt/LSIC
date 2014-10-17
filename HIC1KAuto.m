% Large-Scale Image Classification
% NII
function HIC1KAuto( dataset, start_Idx,end_Idx, step,Q)

    if nargin < 4
        fprintf('\n Syntax: LISC dataset start_Idx end_Idx  step');
        return;
    end
    dataset_type = dataset;
%     dataset_type = str2num(dataset);
%     start_Idx    = str2num(start_Idx);
%     end_Idx    = str2num(end_Idx);
%     step    = str2num(step);
    
    if step < 0
        if( start_Idx < end_Idx)
            error('Parameters is invalidate !');
        end
    elseif step >0 
        if( start_Idx > end_Idx)
            error('Parameters is invalidate !');
        end	
    else 
        error('Parameters is invalidate !');
    end

    conf.stylesOrganizedImages.All          = 1; % imageclef
    conf.stylesOrganizedImages.Class        = 2; % Caltech256
    conf.stylesOrganizedImages.TrainTestVal = 3; % ILSVRC
    % Chon tap du lieu
    if dataset_type ~=0
        conf.datasetName         = 'Caltech256';   % 'Caltech256', 'ILSVRC2010
        conf.styleOrganizedImages = conf.stylesOrganizedImages.Class;
    else
        conf.datasetName         = 'ILSVRC2010';   % 'Caltech256', 'ILSVRC2010
        conf.styleOrganizedImages = conf.stylesOrganizedImages.TrainTestVal;
    end
    
     % Khai bao cac thu vien
    AddPathLib();
    
    % Khoi tao cac thuc muc tuong ung
    conf = InitRootDir( conf );
    % thiet lap dac trung
    conf.BOW.typeCodebkGen = 'annkmeans';    % 'annkmeans' 'kmeans'
    conf  = SetupFeatures( conf );
    % Tao cac thu muc luu tru
    conf = MakeDirectories(conf );  
    % Load thong tin ve CSDL
    conf  = LoadInforDataset( conf ); 
    % Extract Feature cho tap anh
    conf  = ExtractAndSaveFeatures(conf);    
    % Thiet lap cac tham so de chia tap du lieu
    [ conf ] = SetupIMDB( conf );
    
    %Chia tap anh thanh train, val and test
    conf  = SplitTrainValTest( conf);
   
    %% ---------------------------------------------------------
    % Thiet lap cac tham so training
    
    conf.svm.solver = 'liblinear'; % 'vl_svmtrain {'sgd', 'sdca'}',  'liblinear', 'libsvm'
    conf.svm.preCompKernel = true;
    
    conf  = InitTrainTest3( conf );    
    % Thuc hien training classifier
    %conf  = TrainingTesting(conf);
    
    [ conf ] = CreateValidationSet( conf );
    [ conf ] = CreateTestingSet( conf );

    
    conf.randSeed = 1 ;
    randn('state',conf.randSeed) ;
    rand('state',conf.randSeed) ;
    vl_twister('state',conf.randSeed) ;
    
    pathToData = fullfile(conf.dir.rootDir,'data');
    MakeDirectory( pathToData);
    pathToHIC = sprintf('hic_auto_Q%d',Q);  
    conf.experiment.pathToHIC = fullfile(conf.path.pathToExperimentDir, pathToHIC);
    MakeDirectory(conf.experiment.pathToHIC);
    
    
    if strcmp( conf.datasetName,'Caltech256')  
        RootNode_ID=257;
    elseif strcmp( conf.datasetName,'ILSVRC2010') 
        RootNode_ID=1001;
    else
        error('conf.datasetName');
    end
            
 %   Q=16;
    file_name_meta = sprintf('meta_auto_Q%d.mat',Q);    
    file_name_meta_leaf_indx =  sprintf('meta_auto_Q%d_leaf_indx.mat',Q);
    file_name_meta_leaf_indx_model = sprintf('meta_auto_Q%d_leaf_indx_model.mat',Q);
    
    khong_dung_cach_de_qui = true;
    if khong_dung_cach_de_qui
    
        path_file_name_meta = fullfile(pathToData, file_name_meta);
        if ~exist(path_file_name_meta,'file')
            fprintf('\n Building meta data ....');
           % synsets = HC.BuildMetaData_Manually_Caltech256(conf);
            synsets = HC.BuildMetaData_Auto(conf,Q);           
            save(path_file_name_meta,'synsets','-v7.3');
            fprintf('done.');
        end

        path_file_name_meta_leaf_indx = fullfile(pathToData, file_name_meta_leaf_indx );
        if ~exist(path_file_name_meta_leaf_indx,'file')
            fprintf('\n Building leaf_indx for taxonomy ....');
            load(path_file_name_meta); 
            
%             RootNode = synsets(RootNode_ID);
%             parent_indx = 0;
%             [RootNode,synsets] = build_leaf_indx(RootNode,synsets,parent_indx)
%             synsets(RootNode_ID).leaf_indx = RootNode.leaf_indx;
%             synsets(RootNode_ID).parent_indx = RootNode.parent_indx;
            save(path_file_name_meta_leaf_indx,'synsets','-v7.3');
            fprintf('done.');   
        end    
%       return;
        path_file_name_meta_leaf_indx_model = fullfile(conf.experiment.pathToHIC, file_name_meta_leaf_indx_model);
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
    
    [Acc, SumNumConcept, MaxLevel,num_test_sample]=HC.LabelTree_Test(conf, synsets, RootNode );
    
    

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



