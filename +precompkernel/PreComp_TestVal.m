function PreComp_TestVal(conf)
   
    fprintf('\n---------------------------------------------------------');
    fprintf('\n| function PreComp_TestVal(conf)                        |');
    fprintf('\n---------------------------------------------------------');
    fprintf('\n\t conf.datasetName: %s',conf.datasetName);    
    fprintf('\n---------------------------------------------------------');
    fprintf('\n Precomputing kernel between testing and validation dataset.....');
    
    if strcmp( conf.datasetName,'Caltech256')
        % Du lieu nay chi co 2 file
        path_filename_val  = conf.val.path_filename ;
        path_filename_test = conf.test.path_filename ;
        path_filename_testval = conf.testval.path_filename;
        
        testval_path_filename_ready = conf.testval.path_filename_ready;
    
        if exist(testval_path_filename_ready, 'file')
            fprintf(' finish (ready)!');
            return;
        end
       
        if exist(path_filename_testval,'file')
            if ~exist(testval_path_filename_ready, 'file')
                ready=1;
                save(testval_path_filename_ready, 'ready','-v7.3');
            end
            fprintf('finish (ready) !');
            return;
        end 
        
        if exist(path_filename_testval,'file')
             fprintf('finish (ready) !');
             return;
        end 
        
        % Load tap val
        if ~exist(path_filename_val,'file')
             error('Error: File %s is not found !',path_filename_val);
        end       
        % Load tap test
        if ~exist(path_filename_test,'file')
             error('Error: File %s is not found !',path_filename_test);
        end
        fprintf('\n\t Loading testing dataset ...');        
        test = load(path_filename_test); %,'instance_matrix','label_vector','-v7.3');   
        fprintf('finish !');
        fprintf('\n\t Loading validation dataset ...');
        val = load(path_filename_val); %,'instance_matrix','label_vector','-v7.3');    
        fprintf('finish !');
        fprintf('\n\t Caculating...');
        pre_testval_matrix = test.instance_matrix' *  val.instance_matrix;
        test_label_vector = test.label_vector;        
        fprintf('\n\t Saving pre_testval_matrix to file : %s...', path_filename_testval);
        save(path_filename_testval, 'pre_testval_matrix','test_label_vector','-v7.3');        
        
        ready=1;
        save(testval_path_filename_ready, 'ready','-v7.3');
        fprintf('finish !');  
        return;
    end
    
    val_path_filename = conf.val.path_filename;
    if ~exist(val_path_filename, 'file')
        error('File %s is not found !', val_path_filename);
    end
    
    testval_path_filename_ready = conf.testval.path_filename_ready;
    
    if exist(testval_path_filename_ready, 'file')
        fprintf(' finish (ready)!');
        return;
    end
    
    fprintf('\n\t Loading validation dataset ...');
    validation = load (val_path_filename);
    fprintf(' finish !');
    
    gtruth_test_file= fullfile(conf.dir.rootDir,'data/ILSVRC2010_test_ground_truth.txt');
    gt_test_label_vector = dlmread(gtruth_test_file);

    
   %% pathToOutput_PreComp_TestVal = conf.path.pathToModel ;
    pathToOutput_PreComp_TestVal ='/data/Dataset/LSVRC/2010/features/phow_LLCEncoder_SPMPooler_10000/test';
    
    start = 1;
    pathToFeaturesDirTest='/data/Dataset/LSVRC/2010/features/phow_LLCEncoder_SPMPooler_10000/test';
    for j=1:150            
        str_id = num2str(j,'%.4d');
        filename_test = ['test.',str_id,'.sbow.mat'] ;
        path_filename_test = fullfile(pathToFeaturesDirTest, filename_test);
        fprintf('\n\t Test file %s ...',filename_test);
        if exist(path_filename_test,'file')
            filename_testval =  ['test.',str_id,'.val30.mat'] ; %sprintf(formatSpec_TestVal,str_id);
            path_filename_testval = fullfile(pathToOutput_PreComp_TestVal,filename_testval);
            fprintf('\n\t\t Precomputing kernel ...');
            
            if ~exist(path_filename_testval,'file')
                tic
                load(path_filename_test); % save(filename,'setOfFeatures','index','-v7.3');
              
                pre_testval_matrix 	= setOfFeatures' * validation.instance_matrix;
                test_label_vector   = gt_test_label_vector (start: start+1000 -1 );

                fprintf('finish !');

                fprintf('\n\t\t Saving pre_testval_matrix to file : %s...', path_filename_testval);
                save(path_filename_testval, 'pre_testval_matrix','test_label_vector','-v7.3');
                fprintf('finish (%f)!',toc);                        
            else                        
                fprintf('finish (ready)!');
            end
        else
            error('Missing test file %s !',path_filename_test);           
        end
        start = start+1000;
    end
    ready=1;
    save(testval_path_filename_ready, 'ready','-v7.3');    
end
    
   