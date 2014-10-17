function [ conf ] = Compose(obj, conf )
%COMPOSE Ket hop ma tran score voi USV
%   Ket hop ma tran score voi USV
  
	fprintf('\n Compose score matrix...');
	solvertype = obj.solvertype;
    solver          = conf.svm.solver;
    preCompKernel   = conf.svm.preCompKernel;
    pathToModel     = conf.path.pathToModel ; 
    pathToIMDBDir   = conf.path.pathToIMDBDir;  
    preCompKernel   = conf.svm.preCompKernel;
    arr_Step        = conf.pseudoclas.arr_Step;
    num_Arr_Step = length(arr_Step);
    assert(num_Arr_Step>0);
    pathToSave =pathToModel;
    
    
    if preCompKernel
        strPrefix_formatSpec = [conf.datasetName,'.',solver,'.pre'];       
    else
        strPrefix_formatSpec = [conf.datasetName,'.',solver,'.pre']; 
    end
    
    formatSpec_ScoreMatrix = [strPrefix_formatSpec,'.prob.val30.svds.%s.svr.',solvertype,'.ontest.mat'];      
    formatSpec_USV         = [strPrefix_formatSpec,'.prob.val30.svds.%s.mat']; % num_pseudoClass
    formatSpec_FinalScoreMatrix  = [strPrefix_formatSpec,'.prob.val30.svds.%s.svr.',solvertype,'.ontest.final.mat']; 
    
    if strcmp( conf.datasetName,'Caltech256')
        
        
        
        
    elseif strcmp(conf.datasetName ,'ILSVRC2010')
  
        arr_Step = conf.pseudoclas.arr_Step;                          
        num_Arr_Step = length(arr_Step);
        assert(num_Arr_Step>0);   

        pathToDirSVD = conf.path.pathToIMDBDir;
        pathToScoreMatrix = conf.path.pathToModel ;

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


            filename_usv = sprintf(formatSpec_USV, str_k); 
            path_filename_usv = fullfile(pathToDirSVD,filename_usv);     
            % load ma tran USV de phuc hoi lai ket qua
            if ~exist (path_filename_usv, 'file')
                error('\n\t File %s is not found !',path_filename_usv);
            end

            filename_ScoreMatrix = sprintf(formatSpec_ScoreMatrix,str_k);
            path_filename_ScoreMatrix = fullfile(pathToScoreMatrix, filename_ScoreMatrix);

            if ~exist(path_filename_ScoreMatrix, 'file')
                error('\n\t File %s is not found !',path_filename_ScoreMatrix);
            end

            fprintf('\n\t Loading USV file: %s ..',filename_usv);
            load (path_filename_usv);  % U,S,V
            fprintf(' finish !');

            fprintf('\n\t Loading score matrix: %s ..',filename_ScoreMatrix);
            load (path_filename_ScoreMatrix); %  'inv_ScoreMatrix', 'label_vector','-v7.3');
            fprintf(' finish !');
            %
    % 		break;

            fprintf('\n\t Composing final score matrix ..');        
            scores_matrix  = (U*S*inv_ScoreMatrix);        
            fprintf(' finish !');
    %         fprintf('size(scores_matrix,1) =%d', size(scores_matrix,2));
    %         fprintf('length(label_vector) =%d', length(label_vector));

    %         whos
    %  		pause

            assert(size(scores_matrix,2) ==  length(label_vector));

            %% Evalute
            fprintf('\n\t Evaluting vl_pr ...');
            VL_AP = zeros(1000,1);
            VL_AUC = zeros(1000,1);
            VL_AP_INTERP_11 = zeros(1000,1);
            M_VL_AP = 0;
            for ci=1:1000 
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


            fprintf('\n\t Evaluting flat error ...');
            val_label_vector = label_vector;


            num_predictions_per_image =10;
            % predict the top labels
            scores_matrix = scores_matrix';
            [scores,pred_test]=sort(scores_matrix,2,'descend');
            pred_test = pred_test(:,1:num_predictions_per_image);
            scores = pred_test(:,1:num_predictions_per_image);


            %evaluation
            error_flat_test =zeros(num_predictions_per_image,1);       

            for ti=1:num_predictions_per_image
                error_flat_test(ti) = eval_flat2(pred_test,val_label_vector, ti);   
            end
            %accuracy = 1.0 - error;
            fprintf('\n\t\t # guesses  vs flat error');
            for ti=1:num_predictions_per_image
            fprintf('\n\t\t      %d         %f',ti, error_flat_test(ti));
                error_flat_test(ti) = eval_flat2(pred_test,val_label_vector, ti);   
            end
            %disp([(1:num_predictions_per_image)',error_flat_test]);

             fprintf('\n\t Saving score matrix to file: %s ...',filename_final_score_matrix);
             save(path_filename_final_score_matrix,'scores_matrix','error_flat_test','VL_AUC','VL_AP','VL_AP_INTERP_11','M_VL_AP','-v7.3');
             fprintf(' finish !');  
             fprintf('\n-------------- !');         

        end

        fprintf(' finished !');
    end

end

