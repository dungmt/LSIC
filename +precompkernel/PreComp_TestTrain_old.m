function PreComp_TestTrain(start_Idx,end_Idx, step)
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
    gt_test_label_vector = dlmread(gtruth_test_file);
    
    for i=start_Idx: step: end_Idx
        synset = WNIDs(i);
        synset = synset{1};
		
		pathToSynsetDir = fullfile(pathToSave,synset);
        if ~exist(pathToSynsetDir,'dir')
             error('Directory %s is empty !',pathToSynsetDir);
        end	
		
        filename_cur = sprintf('%s.train.mat',synset);
        filename_train = fullfile(pathToSynsetDir, filename_cur );         
        fprintf('\n\t Precomputing kernel between train images of class %3d: %s ...',i, synset);    
        if exist(filename_train,'file') 
            load(filename_train); %,'instance_matrix','label_vector','pre_matrix','-v7.3');
            start = 1;
            for j=1:150        
                str_id = num2str(j,'%.4d');
                filename_test = ['test.',str_id,'.sbow.mat'] ;
                path_test = fullfile(pathToTestFeatures, filename_test);
                fprintf('\n\t Test file %s ...',filename_test);
                if exist(path_test,'file')
                    filename_testtrain = fullfile(pathToSynsetDir,sprintf('%s.pre.test.%s.train.mat',synset,str_id));
                    fprintf('\n\t\t Precomputing kernel i=%d, j=%d...',i,j);
                    if ~exist(filename_testtrain,'file')
                        tic
                        load(path_test); % save(filename,'setOfFeatures','index','-v7.3');
                        
                        pre_testtrain_matrix = setOfFeatures' * instance_matrix;
                        test_label_vector = gt_test_label_vector (start: start+1000 -1 );
                        
                        fprintf('finish !');

                        fprintf('\n\t\t Saving pre_valtrain_matrix to file : %s...', filename_testtrain);
                        save(filename_testtrain, 'pre_testtrain_matrix','test_label_vector','-v7.3');
                        fprintf('finish (%f)!',toc);                        
                    else                        
                        fprintf('finish (ready)!');
                    end
                else
                    fprintf('missing test file %s !',path_test);
                    break;
                end
                start = start+1000;
            end
        else
			fprintf('Missing file %s !',filename_train);
			break;
		end
    end
    fprintf('\nDONE!\n');
end
    
   