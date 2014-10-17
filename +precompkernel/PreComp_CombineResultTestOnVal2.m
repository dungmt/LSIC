%Giam so anh xuong con 300 cho tat ca
% Doc cac file
% Neu so luong lon hon 300 thi giam con 300
% Ghi lai ket qua

function PreComp_CombineResultTestOnVal2( kk)
num_concept = str2num(kk);  

     if isunix
            file_data = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/data/meta.mat';
             pathToIMDBDir = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb';
             pathToFeaturesDir ='/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/features/phow_LLCEncoder_SPMPooler_10000';
             fileLabel=   '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/data/ILSVRC2010_validation_ground_truth.txt';
             pathToFile_Val = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb/ILSVRC2010.val.mat';
			 
			      addpath('/home/dungmt/lib/libsvm-3.17/matlab');          
        path(path,'/home/dungmt/lib/liblinear-1.93/matlab');
        run('/home/dungmt/lib/vlfeat/toolbox/vl_setup'); 
		
     else 
            file_data = 'F:\Dataset\LSVRC\2010\data\meta.mat';
            fileLabel=   'F:\Dataset\LSVRC\2010\data\ILSVRC2010_validation_ground_truth.txt';
            pathToIMDBDir = 'F:\Dataset\LSVRC\2010\imdb';
            pathToFeaturesDir = 'F:\Dataset\LSVRC\2010\features\phow_LLCEncoder_SPMPooler_10000';
            pathToFile_Val = 'F:\Dataset\LSVRC\2010\imdb\ILSVRC2010.val.mat'
     end
     
     
	fprintf('\n\t Loading information about ILSVRD2010 dataset....');    
    K= 1000;
    
    load (file_data);
    
    WNIDs = { synsets.WNID}; % lay gia tri cua thuoc tinh num_train_images trong tat ca phan tu
    WNIDs = WNIDs(1:K); % chon ra K phan tu dau tien 1:K
    ILSVRC_IDs = [ synsets.ILSVRC2010_ID ];
    ILSVRC_IDs = ILSVRC_IDs(1:K);
      
    % Tao mau am cho tung classs    
%    pathToSave = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb';
%    fprintf('\n Loading validation dataset: %s...', pathToFile_Val);
%    load(pathToFile_Val); %, 'val_instance_matrix','val_label_vector' ,'-v7.3');
%    fprintf('finish !');
    
    
    filename_result 		= fullfile(pathToIMDBDir,'ILSVRC2010.libsvm.pre.prob.val.mat');
    if ~exist(filename_result,'file')
        scores_matrix = zeros(K,50000);
        for i=1:K
            synset = WNIDs(i);
            synset = synset{1};
			pathToSave = fullfile(pathToIMDBDir,synset);
			
            filename_libsvm_val 	= fullfile(pathToSave,sprintf('%s.libsvm.pre.prob.val.mat',synset)); 		
            fprintf('\n\t Loading result on validation of class %3d: %s....',i,synset);
            if exist(filename_libsvm_val,'file')
                S = load(filename_libsvm_val); %, 'predicted_label', 'accuracy', 'decision_values','val_label_vector','-v7.3');
				prob_values =  max(S.decision_values,[],2);				
               % scores_matrix(i,:) = S.decision_values';
				scores_matrix(i,:) = prob_values';
            else
                error('Error: File not found "%s"!',filename_libsvm_val);
				break;
            end
        end
        fprintf('\n Saving result: %s...', filename_result);
        save(filename_result, 'scores_matrix','-v7.3');
        fprintf('finish !');
    else
        fprintf('\n\t Loading scores_matrix ...');
        load(filename_result);
        fprintf('finish !');
    end
    
    
  %  filename_svds 		= fullfile(pathToIMDBDir,'ILSVRC2010.libsvm.pre.prob.val.svds.mat');
  %  if ~exist(filename_svds,'file')
  %      U_Matrix={};
   %     S_Matrix={};
    %    V_Matrix={};
     %   arr_Step = [100 200 300 400 500 600 700 800 900 1000];
      %  for i=length(arr_Step):-1:1
            %k = arr_Step(i);
			k = num_concept;
            fprintf('\n\t Calculating svds k=%d...',k);
            [U,S,V] = svds(scores_matrix,k);
            fprintf('finish !');
            fprintf('\n Saving result: %s...', filename_result);
            filename_svds_usv = fullfile(pathToIMDBDir,sprintf('ILSVRC2010.libsvm.pre.prob.val.svds.%3d.mat',k));
            save(filename_svds_usv, 'U', 'S','V','-v7.3');
            fprintf('finish !');
       %     U_Matrix{i}=U;
       %     S_Matrix{i}=S;            
       %     V_Matri{i}=V;
       % end
       % fprintf('\n Saving result: %s...', filename_svds);
       % save(filename_svds, 'U_Matrix', 'S_Matrix','V_Matrix','-v7.3');
       % fprintf('finish !');
   
   % end
    
    
    
            
            
    fprintf('\nDONE!\n');
    
    
   