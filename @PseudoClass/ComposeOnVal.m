function [ conf ] = ComposeOnVal(obj, conf )
%COMPOSE Ket hop ma tran score voi USV
%   Ket hop ma tran score voi USV
  
	fprintf('\n Compose score matrix...');
	
    pathToModel     = conf.path.pathToModel ; 
    pathToIMDBDir   = conf.path.pathToIMDBDir;  
    pathToDirSVD    = conf.path.pathToIMDBDir;
    pathToScoreMatrix = '/net/per610a/export/das11f/plsang/dungmt/svr_onval'; conf.path.pathToModel ;
    pathToSave      = pathToModel;
    num_Classes = conf.class.Num;
    assert(num_Classes>0);
    solvertype = obj.solvertype;
    solver          = conf.svm.solver;
    preCompKernel   = conf.svm.preCompKernel;    
    
    arr_Step        = conf.pseudoclas.arr_Step;    
    num_Arr_Step = length(arr_Step);
    assert(num_Arr_Step>0);
    
    
    
    if preCompKernel
        strPrefix_formatSpec = [conf.datasetName,'.',solver,'.pre'];       
    else
        strPrefix_formatSpec = [conf.datasetName,'.',solver]; 
    end
    % ILSVRC2010.libsvm.pre.prob.val30.svds.1000.svr.libsvm.pre.373.val30.mat
    % formatSpec_ScoreMatrix = [strPrefix_formatSpec,'.prob.val30.svds.%s.svr.',solvertype,'.ontest.mat'];      
    formatSpec_ScoreMatrix = [strPrefix_formatSpec,'.prob.val30.svds.%s.svr.',solvertype,'.onval.mat'];  
    formatSpec_USV         = [strPrefix_formatSpec,'.prob.val30.svds.%s.mat']; % num_pseudoClass
    formatSpec_FinalScoreMatrix  = [strPrefix_formatSpec,'.prob.val30.svds.%s.svr.',solvertype,'.onval.final.mat']; 
    formatSpec_SVDS         = conf.pseudoclas.formatSpec_SVDS;  
    

    % Load file ket qua
    num_pseudo_classes  = arr_Step(num_Arr_Step);
    assert(num_pseudo_classes>0);
    str_num_pseudo_classes = num2str(num_pseudo_classes,'%.3d');
    
    filename_ScoreMatrix = 'ILSVRC2010.libsvm.pre.prob.val30.svds.1000.svr.libsvm.onval30.final.mat';
    path_filename_ScoreMatrix = fullfile('/net/per610a/export/das11f/plsang/dungmt', filename_ScoreMatrix);

    if ~exist(path_filename_ScoreMatrix, 'file')
        if strcmp( conf.datasetName,'Caltech256')
            error('\n\t File %s is not found !',path_filename_ScoreMatrix);
        elseif strcmp(conf.datasetName ,'ILSVRC2010')
           %  'inv_ScoreMatrix', 'label_vector'
           fprintf('\n Creating inv_ScoreMatrix ...')
           pathTotemp = '/net/per610a/export/das11f/plsang/dungmt/svr_onval';           
           
           K = 1000;
           inv_ScoreMatrix = zeros(K,30000);
           for ci=1:K
               str_ci = num2str(ci,'%.3d');  
               fprintf('\n\t Class %3d :',ci);
               
               filename_kq = sprintf('ILSVRC2010.libsvm.pre.prob.val30.svds.1000.svr.libsvm.pre.%s.val30.mat', str_ci);
               path_filename_kq = fullfile(pathTotemp, filename_kq);
    
               if ~exist(path_filename_kq,'file')
                  error('File %s is not found !', path_filename_kq);
               end

               load(path_filename_kq); %save(path_filename_kq,'predicted_label', 'accuracy', 'decision_values','-v7.3');
               inv_ScoreMatrix(ci,:) = decision_values';   
               label_vector = val_label_vector ;
           end
            
           fprintf('\n Saving inv_ScoreMatrix ...') 
           save(path_filename_ScoreMatrix, 'inv_ScoreMatrix', 'label_vector','-v7.3');
           fprintf('finish !');
        end			
    end

    fprintf('\n Loading score matrix from file: %s', filename_ScoreMatrix);
    load(path_filename_ScoreMatrix); %, 'inv_ScoreMatrix', 'label_vector','-v7.3');
    fprintf('finish !');
    
   
	
    % Load U,S,V

    filename_svds = sprintf(formatSpec_SVDS,str_num_pseudo_classes);
    path_filename_svds = fullfile(pathToDirSVD,filename_svds);

    if ~exist(path_filename_svds,'file')
         error('\n\t File %s is not found !',path_filename_svds);
    end

    fprintf('\n\t\t Loading (U,S,V) file: %s...', filename_svds);
    load(path_filename_svds); %, 'U', 'S','V','-v7.3');
    fprintf('finish !');

    % Tong hop tung ket qua
    for i=1: num_Arr_Step %:-1:1
        k = arr_Step(i);        
        str_k = num2str(k,'%.3d');  
        fprintf('\n\t LSIC: Composing i=%d/%d with k = %3d ...',i,num_Arr_Step, k);  

        filename_final_score_matrix 		= sprintf(formatSpec_FinalScoreMatrix, str_k); 
        path_filename_final_score_matrix 	= fullfile(pathToScoreMatrix,filename_final_score_matrix);

        if exist(path_filename_final_score_matrix, 'file')
            fprintf(' finish (ready) !');
           continue; 
        end
        num_pseudo_classes = k;
        UU = U(:,1:k);
        SS = S(1:k,1:k);
        VV_T = inv_ScoreMatrix(1:k,:);
        fprintf('\n\t Composing final score matrix ..');        
        scores_matrix  = (UU*SS*VV_T);        
        fprintf(' finish !');

        %% Evalute


        fprintf('\n\t Evaluting vl_pr ...');
        VL_AP   = zeros(num_Classes,1);
        VL_AUC  = zeros(num_Classes,1);
        VL_AP_INTERP_11 = zeros(num_Classes,1);
        M_VL_AP = 0;
        for ci=1:num_Classes 
            label_vector_gt = -ones(length(label_vector),1);
            sortidx = find(label_vector ==ci);
            label_vector_gt(sortidx) = 1;

            scores = scores_matrix(ci,:);

            [rc, pr, info] = vl_pr(label_vector_gt, scores) ;
            disp(info.auc) ;
            disp(info.ap) ;
            disp(info.ap_interp_11) ;

            VL_AP(ci) = info.ap;             
            VL_AUC(ci) = info.auc;
            VL_AP_INTERP_11(ci) = info.ap_interp_11;
            M_VL_AP = M_VL_AP +info.ap;
        end

		fprintf('\n\t M_VL_AP = %f', M_VL_AP);
        fprintf('\n\t Saving score matrix to file: %s ...',filename_final_score_matrix);
        save(path_filename_final_score_matrix,'scores_matrix','label_vector','num_pseudo_classes','VL_AUC','VL_AP','VL_AP_INTERP_11','M_VL_AP','-v7.3');
        fprintf(' finish !');  
        fprintf('\n-------------- !');         

    end
        
 

end

