% Large-Scale Image Classification
% NII
function HIC( dataset, start_Idx,end_Idx, step,ci_start,ci_end)

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
   
    conf.experiment.pathToHIC = fullfile(conf.path.pathToExperimentDir, 'hic_new2');
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
    
    %% Testing
    pathToIMDBDirTest   = conf.path.pathToIMDBDirTest;
    if strcmp( conf.datasetName,'ILSVRC2010')  
       pathToIMDBDirTest  = fullfile(conf.path.pathToFeaturesDir, 'test');
       gtruth_test_file= fullfile(conf.dir.rootDir,'data/ILSVRC2010_test_ground_truth.txt');    
       gt_test_label_vector = dlmread(gtruth_test_file);
    end
    
    ACC=0;
    Level=0;
    LevelAll=0;
    MaxLevel = 0;
    SumNumConcept=0;
        
    if strcmp( conf.datasetName,'Caltech256')  
        filename_test  = conf.test.filename;
        path_filename_test  = fullfile(conf.experiment.pathToBinaryClassifer, filename_test); 
        fprintf('\n\t Loading testing dataset from file: %s...',filename_test);        
        testing = load(path_filename_test); %,'instance_matrix',label_vector','-v7.3');   
        fprintf('finish !');
        num_test_sample = size(testing.instance_matrix,2)-20;
        
        for i=1:num_test_sample
            test_label_vector = testing.label_vector(i)
            test_instance_matrix =sparse( (testing.instance_matrix(:,i) )' );
            level=1;
            num_concept=1;
            if khong_dung_cach_de_qui
                [leaf_indx,level,num_concept] = test_nodes_new(RootNode, synsets, level,num_concept, test_label_vector, test_instance_matrix);
            else
                [leaf_indx,level] = test_nodes(Taxonomy, level, test_label_vector, test_instance_matrix);
            end
            LevelAll = LevelAll + level;
            SumNumConcept = SumNumConcept + num_concept;
            if (level > MaxLevel) 
                MaxLevel = level;
            end
            if(leaf_indx == test_label_vector)
                ACC = ACC+1;
                Level = Level + level;
            end
    %          pause;
        end
    elseif strcmp( conf.datasetName,'ILSVRC2010') 
         start = 1; 
        for j=1:150 
                str_id = num2str(j,'%.4d');
                filename_test = ['test.',str_id,'.sbow.mat'] ;
                path_filename_test = fullfile(pathToIMDBDirTest, filename_test);
                if ~exist(path_filename_test,'file')  % kiem tra xem co file test                    
                    error('Missing test file %s !',path_filename_test);    
                end
                
                fprintf('\n\t\t Test file %s ...',filename_test);
                
                
                % load data: /data/Dataset/LSVRC/2010/features/phow_LLCEncoder_SPMPooler_10000/test/test.0004.sbow.mat
                % index                  1x1000                 8000  double              
                % setOfFeatures      50000x1000            200000000  single    
                fprintf('\n\t\t Loading data from file %s ...',filename_test);
                load(path_filename_test); % save(filename,'setOfFeatures','index','-v7.3');
                test_label_vector   = gt_test_label_vector (start: start+1000 -1 );
                numTest = 1000;               
             
                testing_instance_matrix = double(setOfFeatures');
                 fprintf('\n\t\t testing_instance_matrix.size 1 %d ...',size(testing_instance_matrix,1));
                num_test_sample = numTest;
                for i=1:num_test_sample
                    test_label_vector_i = test_label_vector(i)
                    test_instance_matrix =sparse( testing_instance_matrix(i,:));
                    level=1;
                    num_concept=1;
                    if khong_dung_cach_de_qui
                        [leaf_indx,level,num_concept] = test_nodes_new(RootNode, synsets, level,num_concept, test_label_vector_i, test_instance_matrix);
                    else
                        [leaf_indx,level] = test_nodes(Taxonomy, level, test_label_vector_i, test_instance_matrix);
                    end
                    LevelAll = LevelAll + level;
                    SumNumConcept = SumNumConcept + num_concept;
                    if (level > MaxLevel) 
                        MaxLevel = level;
                    end
                    if(leaf_indx == test_label_vector_i)
                        ACC = ACC+1;
                        Level = Level + level;
                 %       leaf_indx
%                         pause
                    end
                      
                end
               start = start+1000;  
         end
    else
        error('conf.datasetName');
    end
    
    
    SumNumConcept
    MaxLevel
    ACC
    Level
    LevelAll
    num_test_sample
    ACC/num_test_sample
    Level/num_test_sample
  
    %%%%%%%%%%%%%%%%%%
    % Truong hop dung du lieu toan cuc
%     pathToSaveData = '/data/Dataset/HICData.mat';
%     if ~exist(pathToSaveData,'file')        
%         fprintf('\n Allocating memory for variables ...');
%         globeData  = zeros(256*30,32000);
%         globeLabel = zeros(256*30,1);
%         fprintf('done.');
%         for i=1:256
%            fprintf('\n Loading data of class %d ...',i);
%            Data = HC.loadData(i, conf)       
%            globeData( (i-1)*30+1:i*30,:) = Data.instance_matrix';
%            globeLabel((i-1)*30+1:i*30,:) = Data.label_vector';
%         end
%         globeData = sparse(globeData);
%         save(pathToSaveData, 'globeData','globeLabel','-v7.3');    
%     else
%         load (pathToSaveData);
%     end


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
                num_classes = length(unique(train_label_vector)) ;
                fprintf('\n\t\t\t num_classes: %d',num_classes);
                fprintf('\n\t\t\t num training sample: %d',length(train_label_vector));         
                
                max_item = num_train_images * 370;
                
                if length(train_label_vector) > max_item 
                    fprintf('\n Sampling node %d', i);                    
                    sel_rand_indices = randperm(max_item);    
                    train_label_vector = train_label_vector(sel_rand_indices);
                    train_instance_matrix = train_instance_matrix(sel_rand_indices,:);
                end
                 model = train(train_label_vector, sparse(train_instance_matrix));    
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
function [leaf_indx,level, num_concept] = test_nodes_new(theNode, synsets, level,num_concept, test_label_vector, test_instance_matrix)
    leaf_indx =0;  
    if ~isfield(theNode,'model')  
        return;
    end
    [predicted_label, accuracy, decision_values] = predict(test_label_vector, test_instance_matrix, theNode.model, '-b 1');
%      pause
    %[predicted_label, accuracy, decision_values] = predict_node(test_label_vector, test_instance_matrix, theNode.model)
    num_concept = num_concept + length(theNode.model.Label);
    
    id_predicted_label = theNode.children(predicted_label);
    fprintf('\n predicted_label: %d',predicted_label );
    fprintf('\t id_predicted_label: %d \t',id_predicted_label );
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
