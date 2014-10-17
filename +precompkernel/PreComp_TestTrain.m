function PreComp_TestTrain(conf, start_Idx,end_Idx, step)
    fprintf('\n Precomputing kernel between testing and training dataset.....');
    if strcmp( conf.datasetName,'Caltech256')
        fprintf('finish (ready) !');
        return;
    end
   
    pathToIMDBDir       = conf.path.pathToIMDBDir;
    pathToFeaturesDir   = conf.path.pathToFeaturesDir;
    pathToFeaturesDirTrain  = fullfile(pathToFeaturesDir,'train');   
    pathToFeaturesDirVal    = fullfile(pathToFeaturesDir,'val');   
    pathToFeaturesDirTest   = fullfile(pathToFeaturesDir,'test');   
    pathToModelClassifer = conf.path.pathToModelClassifer;
    
    gtruth_test_file= fullfile(conf.dir.rootDir,'data/ILSVRC2010_test_ground_truth.txt');    
    gt_test_label_vector = dlmread(gtruth_test_file);
              
   suffix_file_testtrain = conf.svm.suffix_file_train;     
   suffix_file_train= conf.svm.suffix_file_train; 
        
    for ci=start_Idx:step:end_Idx
         
        ClassName = conf.class.Names{ci};            
        pathToDirClass = fullfile(pathToModelClassifer,ClassName);
        pathToOutput_PreComp_TestVal = pathToDirClass;
        
        filename_data_to_train = [ClassName,suffix_file_train];
        path_filename_data_to_train = fullfile(pathToDirClass, filename_data_to_train ); 
        
        
        if ~exist(path_filename_data_to_train, 'file')
          	error('File %s is not found !',path_filename_data_to_train);            
        end
        fprintf('\n\t class (%3d): %s ...',ci,ClassName);
        
        j=150;
        str_id = num2str(j,'%.4d');
        filename_testtrain = [ClassName,'.pre.test.',str_id,suffix_file_testtrain];
        path_filename_testtrain = fullfile(pathToOutput_PreComp_TestVal,filename_testtrain);
        if exist(path_filename_testtrain,'file')
            continue;
        end         
                    
        tic
        
        fprintf('\n\t\t Loading training dataset file...');
        load(path_filename_data_to_train);%,'instance_matrix','label_vector','pre_matrix','-v7.3'); 
        % instance_matrix: dim x n_images
        fprintf('finish !');
        
        
        start = 1;
        for j=1:150            
            str_id = num2str(j,'%.4d');
            filename_test = ['test.',str_id,'.sbow.mat'] ;
            path_filename_test = fullfile(pathToFeaturesDirTest, filename_test);
            fprintf('\n\t\t Test file %s ...',filename_test);
            if exist(path_filename_test,'file')
                filename_testtrain = [ClassName,'.pre.test.',str_id,suffix_file_testtrain];
                path_filename_testtrain = fullfile(pathToOutput_PreComp_TestVal,filename_testtrain);
                fprintf('\n\t\t Precomputing kernel ...');

                if ~exist(path_filename_testtrain,'file')
                    tic
                    load(path_filename_test); % save(filename,'setOfFeatures','index','-v7.3');

                    pre_testtrain_matrix = setOfFeatures' * instance_matrix;
                    test_label_vector   = gt_test_label_vector (start: start+1000 -1 );

                    fprintf('finish !');

                    fprintf('\n\t\t Saving pre_testval_matrix to file : %s...', path_filename_testtrain);
                    save(path_filename_testtrain, 'pre_testtrain_matrix','test_label_vector','-v7.3');
                    fprintf('finish (%f)!',toc);        
                    clear pre_testtrain_matrix;
                else                        
                    fprintf('finish (ready)!');
                end
            else
                error('Missing test file %s !',path_filename_test);           
            end
            start = start+1000;
        end
    end 
end
    
   