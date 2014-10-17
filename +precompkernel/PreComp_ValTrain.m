function PreComp_ValTrain(conf)

    fprintf('\n Precomputing kernel between validation/ testing and training dataset...');   
    
  %%  preComputed_Kernel=true;
    numClass            = conf.class.Num;
    pathToIMDBDir       = conf.path.pathToIMDBDir;
    pathToModelClassifer = conf.path.pathToModelClassifer;
    ClassNames          = conf.class.Names;
    
    pathToFeaturesDir  = conf.path.pathToFeaturesDir;
    pathToFeaturesDirTrain  = fullfile(pathToFeaturesDir,'train');   
    pathToFeaturesDirVal    = fullfile(pathToFeaturesDir,'val');   
    pathToFeaturesDirTest   = fullfile(pathToFeaturesDir,'test');   
    
    path_filename_valtrain_ready  = fullfile(pathToIMDBDir,[conf.datasetName,conf.svm.suffix_ready_valtrain]);
    path_filename_testtrain_ready = fullfile(pathToIMDBDir,[conf.datasetName,conf.svm.suffix_ready_testtrain]);
   
    if strcmp( conf.datasetName,'Caltech256')
        if exist (path_filename_valtrain_ready,'file') && exist (path_filename_testtrain_ready,'file')
           fprintf('finish (ready) !');
           return;
        end
        
        path_filename_val   = fullfile(pathToFeaturesDirVal, [conf.datasetName,'.sbow.mat']);
        path_filename_test  = fullfile(pathToFeaturesDirTest, [conf.datasetName,'.sbow.mat']);
        % Load tap val
        if ~exist(path_filename_val,'file')
             error('Error: File %s is not found !',path_filename_val);
        end       
        % Load tap test
        if ~exist(path_filename_test,'file')
             error('Error: File %s is not found !',path_filename_test);
        end
        fprintf('\n\t Loading testing dataset ...');        
        load(path_filename_test); %,'test_instance_matrix','test_label_vector','-v7.3');   
        fprintf('finish !');
    elseif strcmp(conf.datasetName,'ILSVRC2010')        
        path_filename_val = fullfile(pathToIMDBDir, [conf.datasetName,'.val30.mat']);
        % val_instance_matrix=zeros(validation_size,output_dim,'single');
        if exist (path_filename_valtrain_ready,'file')
           fprintf('finish (ready) !');
           return;
        end
    else
        error('%s chua ho tro',conf.datasetName);        
    end
    
    fprintf('\n\t Loading validation dataset ...');
    load(path_filename_val); %,'val_instance_matrix','val_label_vector','-v7.3');    
    fprintf('finish !');
    %%
     %parfor i=1:numClass
    suffix_file_valtrain    = conf.svm.suffix_file_valtrain;
    suffix_file_testtrain   = conf.svm.suffix_file_testtrain;
    suffix_file_train       = conf.svm.suffix_file_train;
    for i=1:numClass

        synset = ClassNames(i);
        synset = synset{1};
        fprintf('\n\t Class %3d : %s ... ',i,synset);

        %pathToDirModel = fullfile(pathToIMDBDir,synset);
        pathToDirModel = fullfile(pathToModelClassifer,synset);
        

        filename_valtrain  = [synset, suffix_file_valtrain];
        filename_testtrain = [synset, suffix_file_testtrain];
        
        path_filename_valtrain  =fullfile(pathToDirModel, filename_valtrain);
        path_filename_testtrain =fullfile(pathToDirModel, filename_testtrain);
        
        if exist(path_filename_valtrain,'file')
             fprintf('finish (ready) !');
             continue;
        end

        filename_data =  [synset,suffix_file_train];
        path_filename_data = fullfile(pathToDirModel,filename_data ); 

        if ~exist(path_filename_data,'file')
             error('Error: File %s is not found !',path_filename_data);
        end
        tic
        fprintf('\n\t\t Loading training data file: %s...',filename_data);
        load(path_filename_data);  
        fprintf('finish !');
        
        fprintf('\n\t\t Precomputing kernel between validation and training data ...');
        if strcmp( conf.datasetName,'Caltech256')  
            % Tinh ket qua precomputed
            % val_instance_matrix  :  32.000 x 7710
            % test_instance_matrix :  32.000 x 5140
            % instance_matrix      :  32.000 x 330
            pre_valtrain_matrix  = val_instance_matrix' * instance_matrix;
            pre_testtrain_matrix = test_instance_matrix' * instance_matrix;   
             % Save mo hinh
            fprintf('\n\t\t Saving pre_testtrain_matrix to file ...');               
            save(path_filename_testtrain, 'pre_testtrain_matrix','test_label_vector','-v7.3');	 
            fprintf('finish !');
        elseif strcmp(conf.datasetName,'ILSVRC2010')   
            % val_instance_matrix = zeros(validation_size,output_dim,'single'); 
            pre_valtrain_matrix  = val_instance_matrix * instance_matrix;       
             % Save mo hinh
            
        end
        fprintf('finish !');
        fprintf('\n\t\t Saving pre_valtrain_matrix to file ...');
        save(path_filename_valtrain,  'pre_valtrain_matrix','val_label_vector','-v7.3');	
        fprintf('finish !');    
        clear pre_valtrain_matrix;
        clear instance_matrix;
        toc
    end
    
    ready=1;
    if strcmp( conf.datasetName,'Caltech256') 
        save(path_filename_testtrain_ready,  'ready','-v7.3');
    end    
    save(path_filename_valtrain_ready,  'ready','-v7.3');	
    
    
end
 