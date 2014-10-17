function SVR_Test(conf,solvertype, isPreComp,ci_start,ci_end)
    
    arr_Step        = conf.pseudoclas.arr_Step;
    num_Arr_Step = length(arr_Step);
    assert(num_Arr_Step>0);
    num_pseudo_classes  = arr_Step(num_Arr_Step);
    assert(num_pseudo_classes>0);
   
    pathToRegressionTrains = conf.experiment.pathToRegressionTrains;
    pathToRegressionTrainsTest = conf.experiment.pathToRegressionTrainsTest;
   
    prefix_file_model = conf.svr.prefix_file_model;
    suffix_file_model = conf.svr.suffix_file_model;
    path_filename_score_matrix = conf.svr.path_filename_score_matrix;
    
    fprintf('\n+----------------------------------------------------+');
    fprintf('\n| +classifier.SVR_Test                               |');
    fprintf('\n+----------------------------------------------------+');
    fprintf('\n\t num_pseudo_classes: %d',num_pseudo_classes);    
    fprintf('\n\t pathToRegressionTrains:\n\t\t %s',pathToRegressionTrains);
    fprintf('\n\t pathToRegressionTrainsTest:\n\t\t %s',pathToRegressionTrainsTest);
    fprintf('\n\t path_filename_score_matrix:\n\t\t %s',path_filename_score_matrix);
    fprintf('\n+----------------------------------------------------+');  
             
    fprintf('\n\t Predicting SVR...');
    if exist(path_filename_score_matrix, 'file') && conf.isOverWriteSVRTest==false 
         fprintf(' finish (ready) !');
         return;
    end
    
   if isPreComp
             testval_path_filename_ready = conf.testval.path_filename_ready;
            if ~exist(testval_path_filename_ready, 'file')
                error('Precomputing kernel between testing and validation dataset is not finished !!!');
            end
   end
     
    %if strcmp( conf.datasetName,'Caltech256')      
    if strcmp( conf.datasetName,'Caltech256')  ||  strcmp( conf.datasetName,'SUN397') || strcmp( conf.datasetName,'ILSVRC65')   
        
        % Load tap testval     
        if isPreComp
           
            path_filename_testval = conf.testval.path_filename;    
            if ~exist(path_filename_testval,'file')
                error('Error: File %s is not found !',path_filename_testval);
            end
            fprintf('\n\t Loading pre_testval_matrix to file : %s...', path_filename_testval);
            load(path_filename_testval); %, 'pre_testval_matrix','test_label_vector','-v7.3');
            fprintf('finish !');  
            test_label_vector = test_label_vector';
            numSamples =  length(test_label_vector);
            assert(numSamples>0);       

            if ~isa(pre_testval_matrix,'double')
                pre_testval_matrix = double(pre_testval_matrix);
            end
            instance_matrix = [(1:numSamples)', pre_testval_matrix];
            clear pre_testval_matrix; 
        else 
            path_filename_test= conf.test.path_filename;
            if strcmp(solvertype, 'liblinear')
%                 path_filename_test ='/data/Dataset/LSVRC/2010/experiments/train100.val30.test150/binclassifiers/ILSVRC2010.test150.sparse.sbow.mat';
                path_filename_test = conf.test.path_filename_sparse;
            end
            if ~exist(path_filename_test,'file')
             %   error('Error: File %s is not found !',path_filename_test);
              path_filename_test= conf.test.path_filename;
            end
            fprintf('\n\t Loading path_filename_test to file : %s...', path_filename_test);
            load(path_filename_test); %, 'pre_testval_matrix','test_label_vector','-v7.3');
            fprintf('finish !');  
            test_label_vector = label_vector;
            numSamples =  length(test_label_vector);
            assert(numSamples>0);       
           
            instance_matrix = instance_matrix';
            size(instance_matrix)
            size(test_label_vector)
            
            if ~isa(instance_matrix,'double')
                instance_matrix = double(instance_matrix);
            end
            
            if strcmp(solvertype, 'liblinear')
                if ~issparse(instance_matrix)
                    fprintf('\n\t sparsing data type ....');
                    instance_matrix = sparse(instance_matrix);
                    fprintf('finish !');            
                end		
            end
            
        end
        
        
        if size(test_label_vector,1)  < size(test_label_vector,2)
           test_label_vector =test_label_vector';
        end
        numSamples =  length(test_label_vector)
        
%         for i=1: num_Arr_Step %:-1:1
       for i=1:-1
            ci = i;
            k = arr_Step(i);        
            str_k = num2str(k,'%.3d');  
            filename_model_ci_loss = [prefix_file_model,'loss.',str_k,suffix_file_model];   
            path_filename_model_ci_loss = fullfile(pathToRegressionTrains,filename_model_ci_loss);
            if ~exist( path_filename_model_ci_loss, 'file')
                error('\n\t Model file %s is not found !',path_filename_model_ci_loss);
            end 
            filename_kq_loss = [filename_model_ci_loss, '.test.mat'];
            path_filename_kq_loss =fullfile(pathToRegressionTrainsTest,filename_kq_loss);
            if exist(path_filename_kq_loss, 'file') && conf.isOverWriteSVRTest==false
                fprintf('finish (ready) !');
            else
                fprintf('\n\t Loading loss model  %d ...', ci)
                load (path_filename_model_ci_loss); %,'model','-v7.3');
                fprintf('finish !');

                fprintf('\n\t Testing loss pseudo classifier %d ...', ci);  
                switch solvertype
                    case 'libsvm'                        
                        if  isPreComp                                                      
                            [predicted_label, accuracy, decision_values] = svmpredict(test_label_vector,instance_matrix, model);                               
                        else                            
                            [predicted_label, accuracy, decision_values] = svmpredict(test_label_vector,instance_matrix, model);                             
                        end
                    case 'liblinear'                                               
                            [predicted_label, accuracy, decision_values] = predict(test_label_vector,instance_matrix, model);                                   
                    otherwise
                         error('SVR_Test:otherwise: %s--> Chua cai dat', solvertype);
                 end
                save(path_filename_kq_loss,'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');                
            end
        end
    
        
        inv_ScoreMatrix = zeros(num_pseudo_classes,numSamples, 'double');
        ci_endd = min(ci_end,num_pseudo_classes);       
        tic
        for ci=ci_start:ci_endd  
            
            str_num_ci = num2str(ci,'%.3d');          
            filename_model_ci = [prefix_file_model, str_num_ci, suffix_file_model];
            path_filename_model_ci = fullfile(pathToRegressionTrains,filename_model_ci);
            if ~exist( path_filename_model_ci, 'file')
                error('\n\t Model file %s is not found !',path_filename_model_ci);
            end  
            
            filename_kq = [filename_model_ci, '.test.mat'];
            path_filename_kq =fullfile(pathToRegressionTrainsTest,filename_kq);
            if exist(path_filename_kq, 'file') && conf.isOverWriteSVRTest==false
                fprintf('\n\t Loading result of prediction class %d ...', ci)
                load(path_filename_kq);
            else
                fprintf('\n\t Loading model of pseudo classifier %d ...', ci)
                load (path_filename_model_ci); %,'model','-v7.3');
                fprintf('finish !');

                fprintf('\n\t Testing pseudo classifier %d ...', ci);  
                switch solvertype
                    case 'libsvm'                        
                        if  isPreComp                                                      
                            [predicted_label, accuracy, decision_values] = svmpredict(test_label_vector,instance_matrix, model);                            
                        else                                                    
                            [predicted_label, accuracy, decision_values] = svmpredict(test_label_vector,instance_matrix, model);                            
                        end
                    case 'liblinear'     
                            tic
                            [predicted_label, accuracy, decision_values] = predict(test_label_vector,instance_matrix, model);  
                            toc;
                            pause;
                    otherwise
                         error('SVR_Test:otherwise: %s--> Chua cai dat', solvertype);
                end
                save(path_filename_kq,'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');   
                
            end
%             whos
%             pause
            inv_ScoreMatrix(ci,:) = decision_values';
            
        end
         % Luu tru ket qua lai
         fprintf('Thoi gian test'); 
         toc
         pause;
         label_vector=test_label_vector;
         fprintf('\n Saving score matrix to file: %s ...', path_filename_score_matrix);
         save(path_filename_score_matrix, 'inv_ScoreMatrix', 'label_vector','-v7.3');
         fprintf('finish !');     
    elseif strcmp(conf.datasetName ,'ILSVRC2010')
        formatSpec_TestVal = 'ILSVRC2010.test.%s.val30.mat';        
        num_FileTest = 150;
        mySize = 1000;        
        %% Bat dau xu ly tung label 
        inv_ScoreMatrix = zeros(num_pseudo_classes,num_FileTest*mySize, 'double');
        label_vector = zeros(num_FileTest*mySize,1);

        pathToOutput_PreComp_TestVal ='/data/Dataset/LSVRC/2010/features/phow_LLCEncoder_SPMPooler_10000/test';   
        
        prefix_file_model = conf.svr.prefix_file_model;
        suffix_file_model = conf.svr.suffix_file_model;
        
        ci_endd = min(ci_end,num_pseudo_classes);
      
        switch solvertype        
            case 'libsvm'     
                if  isPreComp                              
                    start =1;                       
                    for j=1:num_FileTest     
                        str_id = num2str(j,'%.4d');
                         filename_testval =  ['test.',str_id,'.val30.mat'] ; %sprintf(formatSpec_TestVal,str_id);
                        path_filename_testval = fullfile(pathToOutput_PreComp_TestVal,filename_testval);                                
                        if ~exist(path_filename_testval,'file')
                           error('\n\t File %s is not found !',path_filename_testval);
                        end
                        load(path_filename_testval); %, 'pre_testval_matrix','test_label_vector','-v7.3');
                        pre_instance_matrix = [(1:mySize)', double(pre_testval_matrix)];        
                        for ci=ci_start:ci_endd
                              str_num_ci = num2str(ci,'%.3d');          
                              filename_model_ci = [prefix_file_model, str_num_ci, suffix_file_model];
                              path_filename_model_ci = fullfile(pathToRegressionTrains,filename_model_ci);

                              if ~exist( path_filename_model_ci, 'file')
                                  error('\n\t Model file %s is not found !',path_filename_model_ci);                                    
                              end        
                              load (path_filename_model_ci); %,'model','-v7.3');

                               
                               filename_kq = [filename_model_ci, '.test.', str_id, '.mat'];
                               path_filename_kq =fullfile(pathToRegressionTrainsTest,filename_kq);
                               if exist(path_filename_kq, 'file')
                                    fprintf('\n\t Loading result of prediction class %d ...', ci)
                                    load(path_filename_kq);
                               else
                                   fprintf('\n\t Testing pseudo class: %d  and test file: test.%s ..\n',ci,str_id);
                                   [predicted_label, accuracy, decision_values] = svmpredict(test_label_vector,pre_instance_matrix, model);
                                   save(path_filename_kq,'predicted_label', 'accuracy', 'decision_values','-v7.3');
                               end
                               inv_ScoreMatrix(ci, start: start+mySize-1) = decision_values';
                              %  label_vector(start: start+mySize-1) = test_label_vector;
                             
                        end
                        start = start +  mySize;
                        
                    end                    
                else
                    error('chua xu ly');
                        
                end
                
            case 'liblinear'            
                error('chua xu ly');
                test_label_vector = zeros(mySize,1);
                [predicted_label, accuracy, decision_values]= predict(test_label_vector, sparse(double(setOfFeatures')), model);  
                
        end

        % Luu tru ket qua lai
        gtruth_test_file= fullfile(conf.dir.rootDir,'data/ILSVRC2010_test_ground_truth.txt');   
        gt_test_label_vector = dlmread(gtruth_test_file);
        label_vector=gt_test_label_vector;

        fprintf('\n Saving score matrix to file: %s ...', path_filename_score_matrix);
        save(path_filename_score_matrix, 'inv_ScoreMatrix', 'label_vector','-v7.3');
        fprintf('finish !');  
        end
  
end
    
   