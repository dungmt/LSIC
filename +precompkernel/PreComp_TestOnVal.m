function PreComp_TestOnVal(conf, start_Idx,end_Idx, step)
	
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
    assert(end_Idx<= conf.class.Num);
    
    fprintf('\n Predicting for validation dataset');
    fprintf('\n\t Start from class: %d',start_Idx );    
	fprintf('\n\t To class: %d', end_Idx);
	fprintf('\n\t Step: %d', step);
    

    pathToIMDBDir   = conf.path.pathToIMDBDir;    
    solver          = conf.svm.solver;
    preCompKernel   = conf.svm.preCompKernel;
    fprintf('\n\t -------------------');
    fprintf('\n\t Solver: %s', solver);
    fprintf('\n\t preCompKernel: %d', preCompKernel);
    
    for i=start_Idx: step: end_Idx
        synset = conf.class.Names(i);
        synset = synset{1};
		pathToIMDBDir_Class = fullfile(pathToIMDBDir,synset);
        if preCompKernel
            path_filename_model 		= fullfile(pathToIMDBDir_Class,sprintf('%s.%s.pre.prob.mat',synset,solver));
            path_filename_valtrain   = fullfile(pathToIMDBDir_Class,sprintf('%s.pre.val.train.mat',synset));     
            filename_libsvm_val = sprintf('%s.%s.pre.prob.val.mat',synset,solver); 	
            path_filename_libsvm_val =fullfile(pathToIMDBDir_Class,filename_libsvm_val);
        else
            path_filename_model 		= fullfile(pathToIMDBDir_Class,sprintf('%s.%s.prob.mat',synset,solver));
            path_filename_valtrain 	= fullfile(pathToIMDBDir_Class,sprintf('%s.val.train.mat',synset));     
            filename_libsvm_val = sprintf('%s.%s.prob.val.mat',synset,solver);	
            path_filename_libsvm_val =fullfile(pathToIMDBDir_Class,filename_libsvm_val);
        end
        
        if exist(path_filename_model,'file') && exist(path_filename_valtrain,'file') 
			
			if exist(path_filename_libsvm_val,'file')
                continue;
            end
            fprintf('\n\t Loading model & instance matrix %3d: %s....',i,synset);
			tic
			
            load(path_filename_valtrain); %,'pre_valtrain_matrix','val_label_vector','-v7.3');
			load(path_filename_model); %, 'model', '-v7.3');
			fprintf('finish !');
			
            fprintf('\n\t Predicting ... ');
			numTest = length(val_label_vector);
            if ~isa(pre_valtrain_matrix,'double')
                pre_valtrain_matrix = double(pre_valtrain_matrix);
            end
			input = [(1:numTest)', pre_valtrain_matrix];
			val_label_vector_test = zeros(1,numTest);
			val_label_vector_test(find(val_label_vector==i) ) = 1;
            val_label_vector_test= val_label_vector_test';
            assert(size(val_label_vector_test,1)==size(input,1));
			[predicted_label, accuracy, decision_values]= svmpredict(val_label_vector_test, input, model,'-b 1');
            
           % fprintf('finish !');
            %pause;
            fprintf('\n\t Saving result: %s...', filename_libsvm_val);
            save(path_filename_libsvm_val, 'predicted_label', 'accuracy', 'decision_values','val_label_vector','-v7.3');
            fprintf('finish !');
			toc
			
			
		else
			if ~exist(path_filename_model,'file')
				fprintf('\n Missing file %s',path_filename_model);
			end
			if ~exist(path_filename_valtrain,'file') 
				fprintf('\n Missing file %s',path_filename_valtrain);
			end
			break;
        end
    end
      
end
   