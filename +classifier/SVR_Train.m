function SVR_Train(conf,solvertype, path_filename_instance_matrix,libsvm_options, isPreComp, scaleValue, arr_Step,ci_start,ci_end)

%	filename_precomp_instance_matrix: Ma tran chua gia tri precomputed kernel
%	filename_label_vector: ten file chua ma tran V
%	libsvm_options: options trong huan luyen

    num_Arr_Step = length(arr_Step);
    assert(num_Arr_Step>0);
    
    if ~exist(path_filename_instance_matrix, 'file')
        error('Error: File %s is not found !',path_filename_instance_matrix);
    end
    
    % Load data 1 lan
    if isPreComp
		fprintf('\n\t Loading precomputed kernel instance matrix from file  \n\t\t %s...', path_filename_instance_matrix);
		load(path_filename_instance_matrix); %  %save(filename_pre_valval_d, 'val_instance_matrix','val_label_vector','-v7.3');
		fprintf(' finish !');		
		
		% ensure input is of correct form
		if ~isa(pre_valval_matrix,'double')
            fprintf('\n\t Converting data type ....');
            pre_valval_matrix = double(pre_valval_matrix);
            fprintf('finish !');
        end		
    else        
        fprintf('\n\t Loading instance matrix from file %s...', path_filename_instance_matrix);
		validation = load(path_filename_instance_matrix); %  %save( 'instance_matrix','label_vector','-v7.3');
		fprintf(' finish !');		
      % instance_matrix : 32000    x    7483
        validation.instance_matrix = validation.instance_matrix'; % instance_matrix : 7483  x 32000

% 		if size(validation.instance_matrix,1) < size(validation.instance_matrix,2)
%             validation.instance_matrix = validation.instance_matrix';
%         end
        
		% ensure input is of correct form
		if ~isa(validation.instance_matrix,'double')
			fprintf('\n\t Converting data type ....');
			validation.instance_matrix = double(validation.instance_matrix);
			fprintf('finish !');
        end		
        
        if strcmp(solvertype, 'liblinear')
            if ~issparse(validation.instance_matrix)
                fprintf('\n\t sparsing data type ....');
                validation.instance_matrix = sparse(validation.instance_matrix);
                fprintf('finish !');            
            end		
        end
    end
   	
    %% Bat dau xu ly tung label
 
    path_filename_decomposed = conf.pseudoclas.path_filename_decomposed;
    
    if ~exist(path_filename_decomposed, 'file')
        error('Error: File %s is not found !',path_filename_decomposed);
    end
    
    fprintf('\n\t Loading decomposing matrix from file: %s...', conf.pseudoclas.filename_decomposed);
    load(path_filename_decomposed); %, 'U', 'S','V','-v7.3');
    fprintf('finish !');
    
    prefix_file_model = conf.svr.prefix_file_model;
    suffix_file_model = conf.svr.suffix_file_model;
    pathToRegressionTrains = conf.experiment.pathToRegressionTrains;
    num_pseudo_classes = size(V,2);	
    assert(num_pseudo_classes == arr_Step(num_Arr_Step) );
        

%     for i=1: num_Arr_Step %:-1:1
%         k = arr_Step(i);        
%         str_k = num2str(k,'%.3d');  
%         fprintf('\n\t SVR_Train: Training los model i=%d/%d with k = %3d ...',i,num_Arr_Step, k);  
%         
%         % Training model_loss 
%         U_Loss = U(:,1+k:end);
%         S_Loss = S((1+k):end,(1+k):end);
%         VV_T_Loss = V(:,1+k:end);
%         scores_matrix_loss = U_Loss*S_Loss*VV_T_Loss';
%         label_loss = sum(scores_matrix_loss);
%     
%         label_loss = label_loss';
%         
%         size(validation.instance_matrix)
% %         whos
% %         pause;
%         filename_model_ci_loss = [prefix_file_model,'loss.',str_k,suffix_file_model];   
%         path_filename_model_ci_loss = fullfile(pathToRegressionTrains,filename_model_ci_loss);
% 
%         if ~exist( path_filename_model_ci_loss, 'file') || conf.isOverWriteSVRTrain==true 
%             tic
%             fprintf('\n\t\t Learning loss model %d by %s with option=%s',i,solvertype,libsvm_options);                
%             switch solvertype
%                 case 'libsvm'                        
%                     if  isPreComp                            
%                         model = svmtrain(label_loss, pre_valval_matrix, libsvm_options);            
%                     else
%                         model = svmtrain(label_loss, validation.instance_matrix, libsvm_options);
%                     end
%                 case 'liblinear'                        
%                     model = train(label_loss, validation.instance_matrix, libsvm_options);  
%             end
% 
%              fprintf('\n\t\t Writing model to file %s ...',filename_model_ci_loss); 
%             SaveModel(path_filename_model_ci_loss,model);
%             fprintf('finish !');     
%             fprintf('\n\t\t ');
%             toc
%         else
%             fprintf('\n\t\t This model is trained !');    
%         end 
%     end
    
%     clear U;
%     clear S;
	
  
    fprintf('\n\t Training SVR with arr_Step(num_Arr_Step): %d',arr_Step(num_Arr_Step));   
    fprintf('\n\t Training SVR with the number of pseudo classes: %d',num_pseudo_classes);  
    
    
    ci_endd = min(ci_end,num_pseudo_classes);
%     assert(size(validation.instance_matrix,1)== size(V,1));
   
    for ci=ci_start:ci_endd
  %  for ci=1:num_pseudo_classes     
        
        training_label_vector = V(:,ci)*scaleValue;   
     %   training_label_vector = V(:,ci)*1000;
       %%xx training_label_vector = VGT(:,ci)*scaleValue;   
        %%training_label_vector = VV(:,ci)*scaleValue;  
       % num_Samples = length(training_label_vector);        
        str_num_ci = num2str(ci,'%.3d');
        fprintf('\n\t Learning model %d / %d  ------ !',ci,num_pseudo_classes);

        filename_model_ci = [prefix_file_model,str_num_ci,suffix_file_model];   
        path_filename_model_ci = fullfile(pathToRegressionTrains,filename_model_ci);

        if ~exist( path_filename_model_ci, 'file') || conf.isOverWriteSVRTrain==true 
            tic
            fprintf('\n\t\t Learning model %d by %s with option=%s',ci,solvertype,libsvm_options);                
            switch solvertype
                case 'libsvm'                        
                    if  isPreComp                            
                        model = svmtrain(training_label_vector, pre_valval_matrix, libsvm_options);            
                    else
                        model = svmtrain(training_label_vector, validation.instance_matrix, libsvm_options);
                    end
                case 'liblinear'                        
                    model = train(training_label_vector, validation.instance_matrix, libsvm_options);  
            end

            %fprintf('\n\t\t Writing model to file: %s...', filename_model_ci);    
            fprintf('\n\t\t Writing model to file %s ...',filename_model_ci); 
            SaveModel(path_filename_model_ci,model);
            fprintf('finish !');     
            fprintf('\n\t\t ');
            toc
        else
            fprintf('\n\t\t This model is trained !');    
        end 
    end
    fprintf('\nDONE!\n');
    ready=1;
     for ci=1:num_pseudo_classes
  
        str_num_ci = num2str(ci,'%.3d');
        filename_model_ci = [prefix_file_model,str_num_ci,suffix_file_model];   
        path_filename_model_ci = fullfile(pathToRegressionTrains,filename_model_ci);

        if ~exist( path_filename_model_ci, 'file') 
            ready=0;
            break;
        end 
     end
     if ready==1
        save(conf.experiment.path_filename_svr_ready,'ready');
     end
    
end
function SaveModel(path_filename_model_ci, model)
        save(path_filename_model_ci,'model','-v7.3');
    end
    
   