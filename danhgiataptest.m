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
    
    start = 1;
    for j=1:150        
        str_id = num2str(j,'%.4d');
                      
        filename_score_matrix = sprintf('ILSVRC2010.libsvm.test.%s.mat', str_id); 
        path_filename_score_matrix = fullfile(pathToIMDBDir,filename_score_matrix);
        fprintf('\n\t Composing file test: %s th', str_id );
        if exist(path_filename_score_matrix, 'file')
            fprintf(' finish (ready) !');
           continue; 
        end
        
        
        ScoreMatrix = zeros(1000,1000);
        
        for i=1:K
            synset = WNIDs(i);
            synset = synset{1};
            
            pathToSynsetDir = fullfile(pathToSave,synset);
            if ~exist(pathToSynsetDir,'dir')
                 error('Directory %s is empty !',pathToSynsetDir);
            end	
            % n01675722.libsvm.pre.test.0001.mat
            filename_result_test = sprintf('%s.libsvm.pre.test.%s.mat',synset,str_id);
            path_filename_result_test = fullfile(pathToSynsetDir,filename_result_test);
            if ~exist(path_filename_result_test,'file')
                 error('File %s is not found !',path_filename_result_test);
            end	
            fprintf('\n\t\t Loading file %3d: %s ...',i, filename_result_test);
            load(path_filename_result_test); % save(filename_libsvm_test, 'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');
            ScoreMatrix(:,i) = decision_values;           
            fprintf('finish !');
        end
        
          %% Evalute
         fprintf('\n\t Evaluting flat error ...');
         val_label_vector = gt_test_label_vector(start:start+1000-1);
         
         
        num_predictions_per_image =5;
        % predict the top labels
        scores_matrix = ScoreMatrix';
        [scores,pred_test]=sort(scores_matrix,2,'descend');
        pred_test = pred_test(:,1:num_predictions_per_image);
        scores = pred_test(:,1:num_predictions_per_image);


        %evaluation
        error_flat_test =zeros(num_predictions_per_image,1);
        error_hie_test  = zeros(num_predictions_per_image,1);

        for i=1:num_predictions_per_image
            error_flat_test(i) = eval_flat2(pred_test,val_label_vector, i);   
        end
        %accuracy = 1.0 - error;
        disp('# guesses  vs flat error');
        disp([(1:num_predictions_per_image)',error_flat_test]);

         fprintf('\n\t Saving score matrix to file: %s ...',filename_score_matrix);
         save(path_filename_score_matrix,'error_flat_test','ScoreMatrix','-v7.3');
         fprintf(' finish !');
         
        
        fprintf('\n-------------- !');     
        
        start = start+1000;
    end
    fprintf('\nDONE!\n');

    