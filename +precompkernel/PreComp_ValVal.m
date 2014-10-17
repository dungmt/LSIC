function PreComp_ValVal(conf)


    fprintf('\n Precomputing kernel between validation and validation dataset.....');
    pathToIMDBDir       = conf.path.pathToIMDBDir;
    pathToFeaturesDir   = conf.path.pathToFeaturesDir;
    pathToFeaturesDirTrain  = fullfile(pathToFeaturesDir,'train');   
    pathToFeaturesDirVal    = fullfile(pathToFeaturesDir,'val');   
    pathToFeaturesDirTest   = fullfile(pathToFeaturesDir,'test');   
    
    if strcmp(conf.datasetName,'ILSVRC2010')
        gtruth_test_file= fullfile(conf.dir.rootDir,'data/ILSVRC2010_test_ground_truth.txt');
        filename_Val ='ILSVRC2010.val30.mat';
    elseif strcmp( conf.datasetName,'Caltech256')
        % Du lieu nay chi co 2 file
        path_filename_val = fullfile(pathToFeaturesDirVal, [conf.datasetName,'.sbow.mat']);
        path_filename_test = fullfile(pathToFeaturesDirTest, [conf.datasetName,'.sbow.mat']);
        path_filename_valval = fullfile(pathToIMDBDir, [conf.datasetName,'.val.val.mat']);
       
        if exist(path_filename_valval,'file')
             fprintf('finish (ready) !');
             return;
        end 
        
        % Load tap val
        if ~exist(path_filename_val,'file')
             error('Error: File %s is not found !',path_filename_val);
        end              
        fprintf('\n\t Loading validation dataset ...');
        load(path_filename_val); %,'val_instance_matrix','val_label_vector','-v7.3');    
        fprintf('finish !');
        
        fprintf('\n\t Precomputing kernel ...');
        pre_valval_matrix = val_instance_matrix' *  val_instance_matrix;
        pre_valval_matrix = [(1:length(val_label_vector))' , pre_valval_matrix];
        fprintf('finish !');
        
        fprintf('\n\t\t Saving pre_valval_matrix to file : %s...', path_filename_valval);
        save(path_filename_valval, 'pre_valval_matrix','val_label_vector','-v7.3');
        fprintf('finish !');          
        return;
    end
    
    gt_test_label_vector = dlmread(gtruth_test_file);
    path_filename_Val = fullfile(conf.path.pathToIMDBDir, filename_Val);
    
    pathToOutput_PreComp_TestVal = conf.path.pathToModel ;
   
    fprintf('\n\t Loading validation dataset');
    load (path_filename_Val);
    %val_instance_matrix = Image x Dim  =  30.000 x 50.0000
    val_instance_matrix = val_instance_matrix';
    
    
    
    start = 1;
    for j=1:150            
        str_id = num2str(j,'%.4d');
        filename_test = ['test.',str_id,'.sbow.mat'] ;
        path_filename_test = fullfile(pathToFeaturesDirTest, filename_test);
        fprintf('\n\t Test file %s ...',filename_test);
        if exist(path_filename_test,'file')
            filename_testval = sprintf(formatSpec_TestVal,str_id);
            path_filename_valval = fullfile(pathToOutput_PreComp_TestVal,filename_testval);
            fprintf('\n\t\t Precomputing kernel ...');
            
            if ~exist(path_filename_valval,'file')
                tic
                load(path_filename_test); % save(filename,'setOfFeatures','index','-v7.3');
              
                pre_testval_matrix 	= setOfFeatures' * val_instance_matrix;
                test_label_vector   = gt_test_label_vector (start: start+1000 -1 );

                fprintf('finish !');

                fprintf('\n\t\t Saving pre_testval_matrix to file : %s...', path_filename_valval);
                save(path_filename_valval, 'pre_testval_matrix','test_label_vector','-v7.3');
                fprintf('finish (%f)!',toc);                        
            else                        
                fprintf('finish (ready)!');
            end
        else
            error('Missing test file %s !',path_filename_test);           
        end
        start = start+1000;
    end
    
    fprintf('\nDONE!\n');
    
   

filename_ValVal = 'ILSVRC2010.pre.val.val.mat';
    pathToFile_ValVal = fullfile(pathToSave,filename_ValVal);
	
    fprintf('\n\t Precomputing kernel between val images ');
    %pre_valval_matrix = val_instance_matrix * val_instance_matrix';
	pre_valtrain_matrix = val_instance_matrix * instance_matrix;
    fprintf('finish !');
            
    fprintf('\n Saving pre_valval_matrix to file : %s...', filename_ValVal);
    save(pathToFile_ValVal, 'pre_valtrain_matrix','val_label_vector','-v7.3');
    fprintf('finish !');
	toc
end
    
   