function TestSVROnVal(start_Idx,end_Idx, step)
	AddPathLib();
%     start_Idx = str2num(start_Idx);
% 	end_Idx = str2num(end_Idx);
% 	step = str2num(step);
	if step < 0
		if( start_Idx < end_Idx)
			error('Parameters is invalidate !');
		end
	elseif step >0 
		if( start_Idx > end_Idx)
			error('Parameters is invalidate !');
		end	
	else 
		error('Parameters is invalidate !');
    end

    assert(start_Idx>0);
   
    
    fprintf('\n Predicting for validation dataset');
    fprintf('\n\t Start from class: %d',start_Idx );    
	fprintf('\n\t To class: %d', end_Idx);
	fprintf('\n\t Step: %d', step);
    

    pathToIMDBDir   = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb';    
    pathToSVRModel = '/net/per610a/export/das11f/plsang/dungmt';
    pathToSVRResult = '/net/per610a/export/das11f/plsang/dungmt/svr_onval';
    
    filename_val   = 'ILSVRC2010.val30.val30.mat';
    path_filename_val   = fullfile(pathToIMDBDir, filename_val);
    if ~exist (path_filename_val,'file')
         error('File %s is not found !',path_filename_val);        
    end
    
    fprintf('\n\t Loading validation dataset from file: %s ...',filename_val);
    load(path_filename_val); %,'pre_valval_matrix','val_label_vector','-v7.3'); 
    fprintf('finish !'); 
    whos;
    pause;
    numTest = length(val_label_vector);
    if ~isa(pre_valval_matrix,'double')
        pre_valval_matrix = double(pre_valval_matrix);
    end
 
            
    for i=start_Idx: step: end_Idx

        str_id = num2str(i,'%.3d');
        
		
        path_filename_model = fullfile(pathToSVRModel,sprintf('ILSVRC2010.libsvm.pre.prob.val30.svds.1000.svr.libsvm.pre.%s.mat',str_id));
        filename_result     =    sprintf('ILSVRC2010.libsvm.pre.prob.val30.svds.1000.svr.libsvm.pre.%s.val30.mat',str_id);
        path_filename_result =fullfile(pathToSVRResult,filename_result);
        
        if exist(path_filename_model,'file') 			
			if exist(path_filename_result,'file')
                continue;
            end
            tic
            fprintf('\n\t Loading model %3d....',i);			
			load(path_filename_model); %, 'model', '-v7.3');
			fprintf('finish !');
			
            fprintf('\n\t Predicting ... ');			
			val_label_vector_test = zeros(1,numTest);
			val_label_vector_test(find(val_label_vector==i) ) = 1;
            val_label_vector_test= val_label_vector_test';
            assert(size(val_label_vector_test,1)==size(pre_valval_matrix,1));

			[predicted_label, accuracy, decision_values]= svmpredict(val_label_vector_test, pre_valval_matrix, model);            
           % fprintf('finish !');
            %pause;
            fprintf('\n\t Saving result: %s...', filename_result);
            save(path_filename_result, 'predicted_label', 'accuracy', 'decision_values','val_label_vector','-v7.3');
            fprintf('finish !');
			toc
		else
			error('\n Missing file %s',path_filename_model);
		end
    end
end
   