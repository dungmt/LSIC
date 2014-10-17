function [ conf ] = Compose_SV(obj, conf )
%COMPOSE Ket hop ma tran score voi USV
%   Ket hop ma tran score voi USV
    num_Classes = conf.class.Num;
    assert(num_Classes>0);
    arr_Step        = conf.pseudoclas.arr_Step;    
    num_Arr_Step = length(arr_Step);
    assert(num_Arr_Step>0);

    % Load file ket qua
    num_pseudo_classes  = arr_Step(num_Arr_Step);
    assert(num_pseudo_classes>0);
    path_filename_score_matrix = conf.svr.path_filename_score_matrix ;
    
    fprintf('\n+----------------------------------------------------+');
    fprintf('\n| @PseudoClass.Compose(obj, conf )                   |');
    fprintf('\n+----------------------------------------------------+');
    fprintf('\n\t num_Classes: %d',num_Classes);    
    fprintf('\n\t num_pseudo_classes: %d',num_pseudo_classes);   
    fprintf('\n\t path_filename_score_matrix:\n\t\t %s',path_filename_score_matrix);
    fprintf('\n+----------------------------------------------------+');     
	fprintf('\n Compose score matrix...');
       
    prefix_file_model = conf.svr.prefix_file_model;
    suffix_file_model = conf.svr.suffix_file_model;
  
   
   if ~exist(path_filename_score_matrix, 'file')
        if strcmp( conf.datasetName,'Caltech256')
            error('\n\t File %s is not found !',path_filename_score_matrix);
        elseif strcmp(conf.datasetName ,'ILSVRC2010')
           %  'inv_ScoreMatrix', 'label_vector'
           fprintf('\n Creating inv_ScoreMatrix ...')
           pathTotemp = '/net/per610a/export/das11f/plsang/dungmt/tmp';           
           formatSpec_TestResult    = 'ILSVRC2010.libsvm.pre.prob.val30.svds.1000.svr.libsvm.pre.%s.mat.test.%s.mat';
           K = 1000;
           inv_ScoreMatrix = zeros(K,150000);
           for ci=1:K
               str_ci = num2str(ci,'%.3d');  
               fprintf('\n\t Class %3d :',ci);
               start= 1;
               for j=1:150        
                    str_id = num2str(j,'%.4d');  
                    fprintf('%s-',str_id);
                    filename_kq = sprintf(formatSpec_TestResult, str_ci, str_id);
                    path_filename_kq = fullfile(pathTotemp, filename_kq);

                    if ~exist(path_filename_kq,'file')
                        error('File %s is not found !', path_filename_kq);
                    end

                    load(path_filename_kq); %save(path_filename_kq,'predicted_label', 'accuracy', 'decision_values','-v7.3');
                    inv_ScoreMatrix(ci, start: start+ 999) = decision_values';
                    start = start + 1000;
               end
           end
           gtruth_test_file = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/data/ILSVRC2010_test_ground_truth.txt';
           gt_test_label_vector = dlmread(gtruth_test_file);
           label_vector=gt_test_label_vector;
           
           fprintf('\n Saving inv_ScoreMatrix ...') 
           load(path_filename_score_matrix); %, 'inv_ScoreMatrix', 'label_vector','-v7.3');
           fprintf('finish !');
        end			
    end

    fprintf('\n\t Loading score matrix from file: %s', path_filename_score_matrix);
    load(path_filename_score_matrix); %, 'inv_ScoreMatrix', 'label_vector','-v7.3');
    fprintf('finish !');
    
	
    % Load U,S,V
    
    path_filename_decomposed = conf.pseudoclas.path_filename_decomposed;
    if ~exist(path_filename_decomposed,'file')
         error('\n\t File %s is not found !',path_filename_decomposed);
    end

    fprintf('\n\t Loading (U,S,V) file: %s...', conf.pseudoclas.filename_decomposed);
    load(path_filename_decomposed); %, 'U', 'S','V','-v7.3');
    fprintf('finish !');
    pathToRegressionTrainsTest= conf.experiment.pathToRegressionTrainsTest;
    % Tong hop tung ket qua
    for i=1: num_Arr_Step %:-1:1
        k = arr_Step(i);        
        str_k = num2str(k,'%.3d');  
        fprintf('\n\t -----------------------------------------------');
        fprintf('\n\t LSIC: Composing i=%d/%d with kkk = %3d ...',i,num_Arr_Step, k);  

        filename_final_score_matrix 		=  [conf.svr.prefix_file_ontest , str_k, conf.svr.suffix_file_ontest_final];
        path_filename_final_score_matrix 	=  fullfile(pathToRegressionTrainsTest,filename_final_score_matrix);

        if exist(path_filename_final_score_matrix, 'file') && conf.isOverWriteResult==false
            fprintf(' finish (ready) !');
           continue; 
        end
        num_pseudo_classes = k;

        if strcmp(conf.pseudoclas.str_decompose,'svds')
            UU = U(:,1:k);
            SS = S(1:k,1:k);
            VV_T = inv_ScoreMatrix(1:k,:);
            
            fprintf('\n\t Composing final score matrix xxx ..');        
            scores_matrix  = (UU*SS*VV_T);    % scores_matrix                          256x7351 
         %%   scores_matrix  = (UU*VV_T);    % SV
            fprintf(' finish !');
        
         elseif strcmp(conf.pseudoclas.str_decompose,'nmf')
           
            WW = W(:,1:k);            
            VV_T = inv_ScoreMatrix(1:k,:);
            
            fprintf('\n\t Composing final score matrix xxx ..');        
            scores_matrix  = (WW*VV_T);    % scores_matrix                          256x7351 
            fprintf(' finish !');
            
         end
            
%         filename_model_ci_loss = [prefix_file_model,'loss.',str_k,suffix_file_model];   
%         filename_kq_loss = [filename_model_ci_loss, '.test.mat'];
%         path_filename_kq_loss =fullfile(pathToRegressionTrainsTest,filename_kq_loss);
%         if ~exist(path_filename_kq_loss, 'file')
%                 error('File %s not found !',path_filename_kq_loss);
%         end
%         load (path_filename_kq_loss); %  save(path_filename_kq_loss,'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');  
        % decision_values                       7351x1
%         decision_values = decision_values';
%         for jj=1:size(scores_matrix,1)
%             scores_matrix(jj,:) = scores_matrix(jj,:) + decision_values;
%         end
      
        %% Evalute

        [VL_AP, M_VL_AP, error_flat, Acc] =  Evaluate(scores_matrix, label_vector );
        
        fprintf('\n\t Accn = %f', Acc);
		fprintf('\n\t M_VL_AP = %f', M_VL_AP);
        fprintf('\n\t M_VL_AP/num_Classes = %f', M_VL_AP/num_Classes);
        fprintf('\n\t Saving score matrix to file: %s ...',filename_final_score_matrix);
        save(path_filename_final_score_matrix,'scores_matrix','label_vector','num_pseudo_classes','VL_AP','M_VL_AP','Acc','-v7.3');
        fprintf(' finish !');  
        fprintf('\n-------------- !');         
        
%         UU = U(:,1:k);
%         SS = S(1:k,1:k);
%         VV_T = inv_ScoreMatrix(1:k,:);
%         fprintf('\n\t Composing final score matrix USV ..');        
%         scores_matrix  = (UU*SS*VV_T);    
%         fprintf(' finish !');
% 
%         %% Evalute
% 
% 
%         [VL_AP, M_VL_AP, error_flat, Acc] =  Evaluate(scores_matrix, label_vector );
%         
%        
% 		fprintf('\n\t Accn = %f', Acc);
%         fprintf('\n\t M_VL_APn = %f', M_VL_AP);
%         fprintf('\n\t M_VL_AP/num_Classes = %f', M_VL_AP/num_Classes);
%         
         
         
      %  pause;
      
    

    end
        
 

end

