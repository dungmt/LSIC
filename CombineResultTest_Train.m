function CombineResultTest_Train( conf)
%CombineResultTestOnVal: Ket hop ket qua tren tap Validation

    fprintf('\n -----------------------------------------------');
    fprintf('\n CombineResultTest_All:Combining the results:');    
    num_Classes = conf.class.Num;
    assert(num_Classes>0);
    
    pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains ; 
    %% --------------------------------------------------------------------
    % Validation
    fprintf('\n\t Combining the results of training dataset....');  
    filename_score_matrix= conf.train.filename_score_matrix;   
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
			
            filename_libsvm_val      =     [ ClassName ,conf.train.midle_file_test,conf.train.str_train,'.mat'] ;
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

end
  
    
    
   