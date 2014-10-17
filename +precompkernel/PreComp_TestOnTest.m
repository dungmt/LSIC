function PreComp_TestOnTest(conf, start_Idx,end_Idx, step)
	
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
    
    fprintf('\n Predicting for testing dataset');
    fprintf('\n\t Start from class: %d',start_Idx );    
	fprintf('\n\t To class: %d', end_Idx);
	fprintf('\n\t Step: %d', step);
    
    pathToModelClassifer = conf.path.pathToModelClassifer;
    pathToIMDBDir   = conf.path.pathToIMDBDir;    
    solver          = conf.svm.solver;
    preCompKernel   = conf.svm.preCompKernel;
    pathToFeaturesDirTest = fullfile(conf.path.pathToFeaturesDir,'test');
    
    
    fprintf('\n\t -------------------');
    fprintf('\n\t Solver: %s', solver);
    fprintf('\n\t preCompKernel: %d', preCompKernel);    
    
    suffix_file_testtrain = conf.svm.suffix_file_train;  
    num_img_neg_per_class_selected = conf.svm.num_img_neg_per_class_selected;
    suffix_file_model= conf.svm.suffix_file_model; 
   if strcmp(conf.datasetName,'ILSVRC2010')
        gtruth_test_file= fullfile(conf.dir.rootDir,'data/ILSVRC2010_test_ground_truth.txt');             	
        
        for i=start_Idx: step: end_Idx
            synset = conf.class.Names(i);
            synset = synset{1};
            ClassName = synset;
             %pathToDirModel = fullfile(pathToIMDBDir,synset);
            pathToDirModel = fullfile(pathToModelClassifer,synset);
            pathToDirClass = fullfile(pathToModelClassifer,ClassName);
            pathToOutput_PreComp_TestVal = pathToDirModel;
            if ~exist(pathToDirModel,'dir')
                 error('Directory %s is empty !',pathToDirModel);
            end	
                
            filename_model = sprintf('%s.%s%s',synset,solver,suffix_file_model);     
            path_filename_model     = fullfile(pathToDirModel,filename_model ); 
            
            fprintf('\n Predicting %d : %s...',i, synset);  
            if exist(path_filename_model,'file') 
                load(path_filename_model); %, 'model', '-v7.3');
                
                for j=1:150 
                    str_id = num2str(j,'%.4d');
                    filename_libsvm_test        = [ClassName, conf.svm.mid_file_test, sprintf('.test.%s.mat',str_id)] ;
                    path_filename_libsvm_test 	= fullfile(pathToDirModel, filename_libsvm_test);

                    filename_testtrain = [ClassName,'.pre.test.',str_id,suffix_file_testtrain];
                    path_filename_testtrain = fullfile(pathToDirClass,filename_testtrain);
                    if exist(path_filename_testtrain,'file')
                            fprintf('\n\t\t Loading pre_testval_matrix to file : %s...', filename_testtrain);
                            if ~exist (path_filename_libsvm_test, 'file')
                                load(path_filename_testtrain); %, 'pre_testtrain_matrix','test_label_vector','-v7.3');
                                fprintf('finish !');
                            else
                                 fprintf('finish (ready)!'); 
                            end
                    else
                            error('File %s is not found !',path_filename_testtrain);
                    end
                    % Thuc hien test
                    fprintf('\n\t\t Predicting...'); 
                        if ~exist (path_filename_libsvm_test, 'file')
                            numTest = length(test_label_vector);
                            input = [(1:numTest)', pre_testtrain_matrix];
                            if ~isa(input,'double');
                                   input =double(input);
                            end


                            testing_label_vector = zeros(numTest,1); %test_label_vector;
                            index_label_i = find(test_label_vector==i);
                            testing_label_vector(index_label_i ) = 1;
                            fprintf('\n\t\t\t Number of item in this class %d: %d',i,length(index_label_i));
                            fprintf('\n\t\t\t ');
                            [predicted_label, accuracy, decision_values]= svmpredict(testing_label_vector, input, model,'-b 1');


                            fprintf('\n\t\t Saving result: %s...', filename_libsvm_test);
                            save(path_filename_libsvm_test, 'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');
                            fprintf('finish !');   
                            clear input;
                        else
                            fprintf('finish (ready) !');   
                        end                        
                        clear pre_testtrain_matrix;      
                end
            else
                error('Missing file %s !',filename_model);
                            
            end
        end
        
   elseif strcmp( conf.datasetName,'Caltech256')
        
       suffix_file_testtrain   = conf.svm.suffix_file_testtrain;    
       suffix_file_model= conf.svm.suffix_file_model; 
        
       for i=start_Idx: step: end_Idx
            synset = conf.class.Names(i);
            synset = synset{1};
            fprintf('\n\t Class %3d : %s ... ',i,synset);
            
            %pathToDirModel = fullfile(pathToIMDBDir,synset);
            pathToDirModel = fullfile(pathToModelClassifer,synset);
            pathToIMDBDir_Class=pathToDirModel;
            filename_testtrain = [synset, suffix_file_testtrain];
            path_filename_testtrain =fullfile(pathToDirModel, filename_testtrain);  
            
            filename_model = sprintf('%s.%s%s',synset,solver,suffix_file_model);     
            path_filename_model     = fullfile(pathToDirModel,filename_model );                     
            
            if preCompKernel      
                if conf.svm.select_nagative_random
                    filename_libsvm_test = sprintf('%s.%s.pre.prob.test.mat',synset,solver); 
                else
                    filename_libsvm_test = sprintf('%s.%s.pre.prob.bla%d.test.mat',synset,solver,conf.svm.num_img_neg_per_class_selected); 
                end              
                path_filename_libsvm_test =fullfile(pathToIMDBDir_Class,filename_libsvm_test);
            else                
                if conf.svm.select_nagative_random
                    filename_libsvm_test = sprintf('%s.%s.prob.test.mat',synset,solver); 
                else
                    filename_libsvm_test = sprintf('%s.%s.prob.bla%d.test.mat',synset,solver,conf.svm.num_img_neg_per_class_selected); 
                end  	
                path_filename_libsvm_test =fullfile(pathToIMDBDir_Class,filename_libsvm_test);
            end

            if exist(path_filename_model,'file') && exist(path_filename_testtrain,'file') 

                if exist(path_filename_libsvm_test,'file')
                    continue;
                end
                fprintf('\n\t Loading model & instance matrix %3d: %s....',i,synset);
                tic

                load(path_filename_testtrain); %,'pre_testtrain_matrix','test_label_vector','-v7.3');
                load(path_filename_model); %, 'model', '-v7.3');
                fprintf('finish !');

                fprintf('\n\t Predicting ... ');
                numTest = length(test_label_vector);
                if ~isa(pre_testtrain_matrix,'double')
                    pre_testtrain_matrix = double(pre_testtrain_matrix);
                end
                input = [(1:numTest)', pre_testtrain_matrix];
                label_vector = zeros(1,numTest);
                label_vector(find(test_label_vector==i) ) = 1;
                label_vector= label_vector';
                assert(size(label_vector,1)==size(input,1));
                [predicted_label, accuracy, decision_values]= svmpredict(label_vector, input, model,'-b 1');

               % fprintf('finish !');
                %pause;
                fprintf('\n\t Saving result: %s...', filename_libsvm_test);
                save(path_filename_libsvm_test, 'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');
                fprintf('finish !');
                toc


            else
                if ~exist(path_filename_model,'file')
                    fprintf('\n Missing file %s',path_filename_model);
                end
                if ~exist(path_filename_testtrain,'file') 
                    fprintf('\n Missing file %s',path_filename_testtrain);
                end
                break;
            end
        end
   end
end
   