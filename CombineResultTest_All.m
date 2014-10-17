function [ conf ] = CombineResultTest_All( conf)
%CombineResultTestOnVal: Ket hop ket qua tren tap Validation

    fprintf('\n -----------------------------------------------');
    fprintf('\n CombineResultTest_All:Combining the results:');    
    num_Classes = conf.class.Num;
    assert(num_Classes>0);
    
    pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains ; 
    %% --------------------------------------------------------------------
    % Validation
    fprintf('\n\t Combining the results of validation dataset....');  
    filename_score_matrix= conf.val.filename_score_matrix;   
    path_filename_score_matrix 		= fullfile(pathToBinaryClassiferTrains,filename_score_matrix);
    
        
    if exist(path_filename_score_matrix,'file') && conf.isOverWriteResult ==false
        fprintf('finish (ready) !');            
    else       
        scores_matrix = [];        
        Accuracy = zeros(num_Classes,1);   
        for i=1:num_Classes
            ClassName = conf.class.Names(i);
            ClassName = ClassName{1};
			pathToDirTrain = fullfile(pathToBinaryClassiferTrains,ClassName);
			
            filename_libsvm_val      =     [ ClassName ,conf.val.midle_file_test,conf.val.str_val,'.mat'] ;
            path_filename_libsvm_val = fullfile(pathToDirTrain,filename_libsvm_val);
        
            %filename_libsvm_val      =     [ ClassName ,conf.val.suffix_file_test ];
            %path_filename_libsvm_val = fullfile(pathToDirClass,filename_libsvm_val);
            
            if exist(path_filename_libsvm_val,'file')
                fprintf('\n\t\t Loading result (%3d): %s...',i, filename_libsvm_val);
                S = load(path_filename_libsvm_val); %, 'predicted_label', 'accuracy', 'decision_values','val_label_vector','-v7.3');                
                fprintf('finish !');
                
                if size(S.decision_values,1) < size(S.decision_values,2) 
                    S.decision_values = S.decision_values';
                end
                prob_values = S.decision_values(:,1);
                
            	scores_matrix = [scores_matrix,prob_values];
                Accuracy(i) = S.accuracy(1);
                val_label_vector = S.val_label_vector;
            else
                error('Error: File not found "%s"!',path_filename_libsvm_val);				
            end
        end
        fprintf('\n\t Saving result scores_matrix: %s...', path_filename_score_matrix);
        save(path_filename_score_matrix, 'scores_matrix','val_label_vector','Accuracy','-v7.3');
        fprintf('finish !');
    end

    
    %% --------------------------------------------------------------------
    % Testing
    fprintf('\n\t Combining the results of testing dataset....'); 
    filename_score_matrix = conf.test.filename_score_matrix;   
    path_filename_score_matrix 		= fullfile(pathToBinaryClassiferTrains,filename_score_matrix);
 
        
    if exist(path_filename_score_matrix,'file') && conf.isOverWriteResult ==false
        fprintf('finish (ready) !');    
    else       
        scores_matrix = [];           
        Accuracy = zeros(num_Classes,1);   
        if ( strcmp( conf.datasetName,'Caltech256') || strcmp( conf.datasetName,'SUN397')  || strcmp(conf.datasetName, 'ImageCLEF2012')    )
             for i=1:num_Classes
                ClassName = conf.class.Names(i);
                ClassName = ClassName{1};
                pathToDirTrain = fullfile(pathToBinaryClassiferTrains,ClassName);               
                
                filename_libsvm_test        = [ClassName, conf.test.midle_file_test,conf.test.str_test,'.mat'] ;
                path_filename_libsvm_test 	= fullfile(pathToDirTrain, filename_libsvm_test);

                if exist(path_filename_libsvm_test,'file')
                    fprintf('\n\t\t Loading result (%3d): %s...',i, filename_libsvm_test);
                    S = load(path_filename_libsvm_test); %, 'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');    
                    fprintf('finish !');
                    if size(S.decision_values,1) < size(S.decision_values,2) 
                        S.decision_values = S.decision_values';
                    end
                    prob_values = S.decision_values(:,1);
                
                    scores_matrix = [scores_matrix,prob_values];
                   
                    Accuracy(i) = S.accuracy(1);
                    test_label_vector = S.test_label_vector;
                else
                    error('Error: File not found "%s"!',path_filename_libsvm_test);				
                end
            end
        elseif strcmp( conf.datasetName,'ILSVRC2010')
            
            for i=1:num_Classes
                ClassName = conf.class.Names(i);
                ClassName = ClassName{1};
                pathToDirClass = fullfile(pathToBinaryClassiferTrains,ClassName);

                %%%% Xet 150 file
                start = 1;
                for j=1:150 
                    str_id = num2str(j,'%.4d');
                    filename_libsvm_test        = [ClassName, conf.svm.mid_file_test, sprintf('.test.%s.mat',str_id)] ;
                    path_filename_libsvm_test 	= fullfile(pathToDirClass, filename_libsvm_test);
                    if exist (path_filename_libsvm_test, 'file')                       
                        fprintf('\n\t\t Loading result (i=%3d, j=%3d): %s...',i,j, filename_libsvm_test);
                        S =load(path_filename_libsvm_test); %, 'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');
                        
                        prob_values = S.decision_values(:,1);                                            
                        if size(prob_values,1) < size(prob_values,2) 
                            prob_values = prob_values';
                        end                   
%                         scores_matrix = [scores_matrix,prob_values];
                        scores_matrix(i,start : start + 999) = prob_values;  %% Can kiem tra lai 22-02
                        
                        Accuracy(i) = Accuracy(i) + S.accuracy(1);                    
                    else
                        error('Error: File not found "%s"!',path_filename_libsvm_test);		
                    end  
                    start = start+1000;
                end
                
            end
            gtruth_test_file = fullfile( conf.dir.rootDir, 'data/ILSVRC2010_test_ground_truth.txt');
            test_label_vector = dlmread(gtruth_test_file);
        elseif strcmp( conf.datasetName,'ILSVRC65')
                for i=1:num_Classes
                    ClassName = conf.class.Names(i);
                    ClassName = ClassName{1};
                    pathToDirClass = fullfile(pathToBinaryClassiferTrains,ClassName);
                    filename_libsvm_val      =     [ ClassName ,conf.test.midle_file_test,conf.test.str_test,'.mat'] ;
                    path_filename_libsvm_val = fullfile(pathToDirClass,filename_libsvm_val);

                    %filename_libsvm_val      =     [ ClassName ,conf.val.suffix_file_test ];
                    %path_filename_libsvm_val = fullfile(pathToDirClass,filename_libsvm_val);

                    if exist(path_filename_libsvm_val,'file')
                        fprintf('\n\t\t Loading result (%3d): %s...',i, filename_libsvm_val);
                        S = load(path_filename_libsvm_val); %, 'predicted_label', 'accuracy', 'decision_values','val_label_vector','-v7.3');                
                        fprintf('finish !');

                        if size(S.decision_values,1) < size(S.decision_values,2) 
                            S.decision_values = S.decision_values';
                        end
                        prob_values = S.decision_values(:,1);

                        scores_matrix = [scores_matrix,prob_values];
                        Accuracy(i) = S.accuracy(1);
                        test_label_vector = S.test_label_vector;
                    else
                        error('Error: File not found "%s"!',path_filename_libsvm_val);				
                    end
                
            end
        else
            error('\n CombineResultTest_All:%s',conf.datasetName);
        end
        
        fprintf('\n\t Saving result scores_matrix: %s...', path_filename_score_matrix);
        save(path_filename_score_matrix, 'scores_matrix','test_label_vector','Accuracy','-v7.3');
        fprintf('finish !');
    end
end
  
    
    
   