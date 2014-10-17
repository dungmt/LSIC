function PreComp_TestOnTest(start_Idx,end_Idx, step)
	start_Idx = str2num(start_Idx);
	end_Idx = str2num(end_Idx);
	step = str2num(step);
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

	fprintf('\n start_Idx: %d', start_Idx);
	fprintf('\n end_Idx: %d', end_Idx);
	fprintf('\n step: %d', step);
	pause;
  

     if isunix
            addpath('/net/per610a/export/das09f/satoh-lab/dungmt/lib/libsvm-3.17/matlab');          
            addpath('/net/per610a/export/das09f/satoh-lab/dungmt//lib/liblinear-1.93/matlab');            
            run('/net/per610a/export/das09f/satoh-lab/dungmt/lib/vlfeat/toolbox/vl_setup'); 
            
            file_data = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/data/meta.mat';
            pathToIMDBDir = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb';
            pathToFeaturesDir ='/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/features/phow_LLCEncoder_SPMPooler_10000';
            fileLabel=   '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/data/ILSVRC2010_validation_ground_truth.txt';
            gtruth_test_file = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/data/ILSVRC2010_test_ground_truth.txt';
            pathToFile_Val = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb/ILSVRC2010.val.mat';
            pathToSave = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb';
            pathToTestFeatures = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/features/phow_LLCEncoder_SPMPooler_10000/test';

     else 
            file_data = 'F:\Dataset\LSVRC\2010\data\meta.mat';
            fileLabel=   'F:\Dataset\LSVRC\2010\data\ILSVRC2010_validation_ground_truth.txt';
            pathToIMDBDir = 'F:\Dataset\LSVRC\2010\imdb';
            pathToFeaturesDir = 'F:\Dataset\LSVRC\2010\features\phow_LLCEncoder_SPMPooler_10000';
            pathToFile_Val = 'F:\Dataset\LSVRC\2010\imdb\ILSVRC2010.val.mat'
            pathToSave = 'F:\Dataset\LSVRC\2010\imdb';
            pathToTestFeatures = 'f:\Dataset\LSVRC\2010\features\phow_LLCEncoder_SPMPooler_10000\test';
            gtruth_test_file = 'F:\Dataset\LSVRC\2010\data\ILSVRC2010_test_ground_truth.txt';

     end
     
     
	fprintf('\n\t Loading information about ILSVRD2010 dataset....');    
    K= 1000;
    
    load (file_data);
    
    WNIDs = { synsets.WNID}; % lay gia tri cua thuoc tinh num_train_images trong tat ca phan tu
    WNIDs = WNIDs(1:K); % chon ra K phan tu dau tien 1:K
    ILSVRC_IDs = [ synsets.ILSVRC2010_ID ];
    ILSVRC_IDs = ILSVRC_IDs(1:K);
      
    % Tao mau am cho tung classs    
%     fprintf('\n Loading validation dataset: %s...', pathToFile_Val);
%     load(pathToFile_Val); %, 'val_instance_matrix','val_label_vector' ,'-v7.3');
%     fprintf('finish !');
   % gt_test_label_vector = dlmread(gtruth_test_file);
 
		
	for i=start_Idx: step: end_Idx
        synset = WNIDs(i);
        synset = synset{1};
        % Tao thu muc:
		
		pathToSynsetDir = fullfile(pathToSave,synset);
        if ~exist(pathToSynsetDir,'dir')
             error('Directory %s is empty !',pathToSynsetDir);
        end	
        filename_model 		= fullfile(pathToSynsetDir,sprintf('%s.libsvm.pre.mat',synset));
        fprintf('\n Predicting %d : %s...',i, synset);  
        if exist(filename_model,'file') 
            load(filename_model); %, 'model', '-v7.3');
            
            for j=1:150        
                str_id = num2str(j,'%.4d');
                filename_testtrain = fullfile(pathToSynsetDir,sprintf('%s.pre.test.%s.train.mat',synset,str_id));
                fprintf('\n\t\t Predicting ...');                
                
                if exist(filename_testtrain,'file')
                    
                    filename_libsvm_test 	= fullfile(pathToSynsetDir,sprintf('%s.libsvm.pre.test.%s.mat',synset,str_id));
                    
                    if ~exist(filename_libsvm_test,'file')
                
                        load(filename_testtrain); %, 'pre_testtrain_matrix','test_label_vector','-v7.3');                       
                      
                        numTest = length(test_label_vector);
                        input = [(1:numTest)', pre_testtrain_matrix];
                        
                        val_label_vector_test = zeros(numTest,1); %test_label_vector;
                        
                        index_label_i = find(test_label_vector==i);
                        val_label_vector_test(index_label_i ) = 1;
                        fprintf('\n\t\t\t Number of item in this class %d: %d',i,length(index_label_i));
                        fprintf('\n\t\t\t ');
                        [predicted_label, accuracy, decision_values]= svmpredict(val_label_vector_test, double(input), model);

                      %  fprintf('finish !');

                        fprintf('\n\t\t Saving result: %s...', filename_libsvm_test);
                        save(filename_libsvm_test, 'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');
                        fprintf('finish !');     
                    else
                        fprintf('finish (ready)!');     
                    end
                else
                    fprintf('missing test file %s !',filename_testtrain);
                    break;
                end
                
            end
        else
			fprintf('Missing file %s !',filename_model);
			break;
		end
    end
    fprintf('\nDONE!\n');
 end
    
   