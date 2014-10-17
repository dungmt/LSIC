function CombineResultTestOnVal( conf)
%CombineResultTestOnVal: Ket hop ket qua tren tap Validation

    fprintf('\n Combining the results of test on validation dataset....');    
    
    pathToIMDBDir = conf.path.pathToIMDBDir;
    FileNameScoreMatrix = conf.val.FileNameScoreMatrix;
    NumSamples =  conf.IMDB.num_images_val *conf.class.Num ;
    
    path_filename_score_matrix 		= fullfile(pathToIMDBDir,FileNameScoreMatrix);
    
    if ~exist(path_filename_score_matrix,'file')
        
        
        numSamples = NumSamples;
       
        WNIDs       = conf.class.Names;        
        ILSVRC_IDs  = conf.class.IDs;
        K= conf.class.Num;

        scores_matrix = zeros(K,numSamples);
        
        for i=1:K
            synset = WNIDs(i);
            synset = synset{1};
			pathToSave = fullfile(pathToIMDBDir,synset);
			
            filename_libsvm_val 	= fullfile(pathToSave,sprintf('%s.libsvm.pre.prob.val.mat',synset)); 		
            fprintf('\n\t\t Loading result on validation of class %3d: %s....',i,synset);
            if exist(filename_libsvm_val,'file')
                S = load(filename_libsvm_val); %, 'predicted_label', 'accuracy', 'decision_values','val_label_vector','-v7.3');
				%prob_values =  max(S.decision_values,[],2);	
                prob_values = S.decision_values(:,1);
               % scores_matrix(i,:) = S.decision_values';
				scores_matrix(i,:) = prob_values';
            else
                error('Error: File not found "%s"!',filename_libsvm_val);				
            end
        end
        fprintf('\n\t Saving result scores_matrix: %s...', path_filename_score_matrix);
       % save(path_filename_score_matrix, 'scores_matrix','-v7.3');
        save(path_filename_score_matrix, 'scores_matrix','val_label_vector','-v7.3');
        fprintf('finish !');
        
    else       
        fprintf('finish (ready) !');
    end
end
  
    
    
   