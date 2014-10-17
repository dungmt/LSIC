function Evaluate_All(conf)   
    fprintf('\n -----------------------------------------------');    
    fprintf('\n Evaluate_All: Evaluting ...');
    num_Classes = conf.class.Num;
    pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains ; 
    %% -------------------------------------------------------------------
    fprintf('\n\t Evaluting validation dataset by OVA classifiers...');
    
    path_filename_evaluation= conf.val.path_filename_evaluation;
    if exist(path_filename_evaluation,'file') &&  conf.isOverWriteResult ==false
        fprintf('finish (ready) (file %s! )\n',path_filename_evaluation);
        valresult = load(path_filename_evaluation);
        valresult.Acc
    else
        filename_score_matrix = conf.val.filename_score_matrix;
        path_filename_score_matrix 		= fullfile(pathToBinaryClassiferTrains,filename_score_matrix);
        if ~exist(path_filename_score_matrix,'file')
            error('File %s is not found !', path_filename_score_matrix);
        end

        fprintf('\n\t\t Loading score matrix validation file: %s ',filename_score_matrix);
        load(path_filename_score_matrix);  % save(path_filename_score_matrix, 'scores_matrix','-v7.3');
        fprintf('finish !');
        fprintf('\n\t\t Evaluating...');
        %scores_matrix = zeros(num_Classes,1) ;  % class x images    
%         whos;
%         pause
%         [VL_APE, M_VL_APE, error_flatE, AccE] =  Evaluate(conf.eigenclass.Rval , val_label_vector )
%         pause;
        Accuracy = zeros(num_Classes,1);     
        [VL_AP, M_VL_AP, error_flat, Acc] =  Evaluate(scores_matrix, val_label_vector );
        fprintf('finish !');
        
       
        fprintf('\n\t\t Acc = %f', Acc);
        fprintf('\n\t\t M_VL_AP/num_Classes = %f/%d =  %f', M_VL_AP,num_Classes, M_VL_AP/num_Classes);
        fprintf('\n\t\t Saving score matrix to file: %s ...',path_filename_evaluation);
        save(path_filename_evaluation,'VL_AP','M_VL_AP','Accuracy','error_flat','Acc','-v7.3');
        fprintf(' finish !');  
    end
    
     %% -------------------------------------------------------------------
    fprintf('\n\t Evaluting testing dataset  by OVA classifiers...');
    
    path_filename_evaluation= conf.test.path_filename_evaluation;
    if exist(path_filename_evaluation,'file') && conf.isOverWriteResult ==false
        
        fprintf('finish (ready) !');
        testresult = load(path_filename_evaluation);
        testresult.Acc
    else
        filename_score_matrix = conf.test.filename_score_matrix;
        path_filename_score_matrix 		= fullfile(pathToBinaryClassiferTrains,filename_score_matrix);
        if ~exist(path_filename_score_matrix,'file')
            error('File %s is not found !', path_filename_score_matrix);
        end

        fprintf('\n\t\t Loading score matrix validation file: %s ',filename_score_matrix);
        load(path_filename_score_matrix); 
        fprintf('finish !');

      %  scores_matrix = zeros(num_Classes,1) ;  % class x images    
        Accuracy = zeros(num_Classes,1);     
        [VL_AP, M_VL_AP, error_flat,Acc] =  Evaluate(scores_matrix, test_label_vector ) ;
       
        fprintf('\n\t\t Acc = %f', Acc);
        fprintf('\n\t\t M_VL_AP/num_Classes = %f/%d =  %f', M_VL_AP,num_Classes, M_VL_AP/num_Classes);
         
        fprintf('\n\t\t Saving score matrix to file: %s ...',conf.test.filename_evaluation);
        save(path_filename_evaluation,'VL_AP','M_VL_AP','Accuracy','error_flat','Acc','-v7.3');
        fprintf(' finish !');  
     end      
    
      %% -------------------------------------------------------------------
    fprintf('\n\t Evaluting training dataset by OVA classifiers...');
    filename_evaluation_final = conf.train.filename_evaluation;
    path_filename_evaluation=fullfile(pathToBinaryClassiferTrains,filename_evaluation_final);
    if exist(path_filename_evaluation,'file') &&  conf.isOverWriteResult ==false
        fprintf('finish (ready) (file %s! )\n',path_filename_evaluation);
    else
        filename_score_matrix = conf.train.filename_score_matrix;
        path_filename_score_matrix 		= fullfile(pathToBinaryClassiferTrains,filename_score_matrix);
        if ~exist(path_filename_score_matrix,'file')
            fprintf('File %s is not found !', path_filename_score_matrix);
            return;
            
        end

        fprintf('\n\t\t Loading score matrix validation file: %s ',filename_score_matrix);
        load(path_filename_score_matrix);  % save(path_filename_score_matrix, 'scores_matrix','-v7.3');
        fprintf('finish !');
        fprintf('\n\t\t Evaluating...');
        %scores_matrix = zeros(num_Classes,1) ;  % class x images    
%         whos;
%         pause
        Accuracy = zeros(num_Classes,1);     
        [VL_AP, M_VL_AP, error_flat, Acc] =  Evaluate(scores_matrix, val_label_vector );
        fprintf('finish !');
        
       
        fprintf('\n\t\t Acc = %f', Acc);
        fprintf('\n\t\t M_VL_AP/num_Classes = %f/%d =  %f', M_VL_AP,num_Classes, M_VL_AP/num_Classes);
        fprintf('\n\t\t Saving score matrix to file: %s ...',filename_evaluation_final);
        save(path_filename_evaluation,'VL_AP','M_VL_AP','Accuracy','error_flat','Acc','-v7.3');
        fprintf(' finish !');  
    end
        
end
