function CombineEvaluate_All(conf)   
% Ket hop cac ket qua lai
    fprintf('\n -----------------------------------------------');       
    fprintf('\n CombineEvaluate_All: Combine Evaluate val, test ...');
    
    num_Classes = conf.class.Num;
    fprintf('\n\t conf.datasetName: %s', conf.datasetName);
    fprintf('\n\t conf.class.Num: %d', conf.class.Num);
    fprintf('\n\t ---------------------------------------');
    fprintf('\n\t Combining ... ');
    
    path_filename_combine_evaluation = conf.experiment.path_filename_combine_evaluation;
    if exist(path_filename_combine_evaluation,'file') && conf.isOverWriteResult==false
        fprintf(' done (ready) !');
        
        load (path_filename_combine_evaluation);
        fprintf('\n\t Results:');
        MAP_Val
        Acc_Val        
        
        MAP_Test
        Acc_Test
        conf.pseudoclas.arr_Step
        SVR_Arr_MAP_Test
        SVR_Arr_Acc_Test
        return;
    end
    
    
    pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains ; 
    
    %% -------------------------------------------------------------------
    fprintf('\n\t Evaluting validation dataset...');
    path_filename_evaluation = conf.val.path_filename_evaluation;
    if ~exist(path_filename_evaluation,'file')
        error('\n File %s is not found !',path_filename_evaluation);
    else
        
        load(path_filename_evaluation); %,'VL_AP','M_VL_AP','Accuracy','error_flat','-v7.3');
        
        if strcmp( conf.datasetName,'Caltech256')
            MAP_Val =  M_VL_AP/num_Classes ;
        else 
            MAP_Val = M_VL_AP;
        end
        Acc_Val = Acc;
        fprintf(' finish !');  
    end
    
     %% -------------------------------------------------------------------
    fprintf('\n\t Evaluting testing dataset...');
    path_filename_evaluation= conf.test.path_filename_evaluation;
    if ~exist(path_filename_evaluation,'file')
        error('\n File %s is not found !',path_filename_evaluation);
    else
       
        load(path_filename_evaluation); %,'VL_AP','M_VL_AP','Accuracy','error_flat','-v7.3');x
        if strcmp( conf.datasetName,'Caltech256')
            %MAP_Test = ( M_VL_AP - VL_AP(num_Classes) ) / (num_Classes-1);
            MAP_Test =  M_VL_AP/num_Classes ;
        else 
            MAP_Test = M_VL_AP;
        end
        Acc_Test = Acc;
        fprintf(' finish !');  
    end
    
    %% -------------------------------------------------------------------
    fprintf('\n\t Evaluting SVR on Testing ...');
    arr_Step        = conf.pseudoclas.arr_Step;    
    num_Arr_Step = length(arr_Step);
    assert(num_Arr_Step>0);
    SVR_Arr_MAP_Test = zeros(1, num_Arr_Step);
    SVR_Arr_Acc_Test = zeros(1, num_Arr_Step);
    pathToRegressionTrainsTest= conf.experiment.pathToRegressionTrainsTest;
    % Tong hop tung ket qua
    for i=1: num_Arr_Step %:-1:1
        k = arr_Step(i);        
        str_k = num2str(k,'%.3d');  
        fprintf('\n\t LSIC: Composing i=%3d/%d with k = %3d ...',i,num_Arr_Step, k);  

        filename_final_score_matrix 		=  [conf.svr.prefix_file_ontest , str_k, conf.svr.suffix_file_ontest_final];
        path_filename_evaluation 	=  fullfile(pathToRegressionTrainsTest,filename_final_score_matrix);

        if ~exist(path_filename_evaluation, 'file')
            error('\n File %s is not found !',path_filename_evaluation);
        end
       
        load(path_filename_evaluation); %,'scores_matrix','label_vector','num_pseudo_classes','VL_AUC','VL_AP','VL_AP_INTERP_11','M_VL_AP','-v7.3');z
 
        if strcmp( conf.datasetName,'Caltech256')
            SVR_Arr_MAP_Test(i) =  M_VL_AP /num_Classes;
        else 
            SVR_Arr_MAP_Test(i) = M_VL_AP;       
        end
        
        SVR_Arr_Acc_Test(i) = Acc;
        
        
        fprintf(' finish !');  
        fprintf('\n\t\t ------------------------------------ !');         
      %  pause;
    end
    
    % Save tat ca ket qua len file
    fprintf('\n\t Saving score matrix to file: %s ...',conf.experiment.filename_combine_evaluation);
    save(path_filename_combine_evaluation, 'MAP_Test', 'MAP_Val','Acc_Test', 'Acc_Val', 'SVR_Arr_MAP_Test','SVR_Arr_Acc_Test','-v7.3');
    fprintf(' done !');          
        
end