function PreCom_SVR(pre_case, kk)
	pre_num = str2num(pre_case);
	num_concept = str2num(kk);  
	
	fprintf('\n Value of pre_num: %d', pre_num);
	if(pre_num ==1) 
		pre =true;
	else 
		pre =false;
	end
	
	if isunix
            file_data = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/data/meta.mat';
             pathToIMDBDir = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb';
             pathToFeaturesDir ='/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/features/phow_LLCEncoder_SPMPooler_10000';
             fileLabel=   '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/data/ILSVRC2010_validation_ground_truth.txt';
             pathToFile_Val = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb/ILSVRC2010.val.mat';
			 pathToSave = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb';
             
			 addpath('/net/per610a/export/das09f/satoh-lab/dungmt/lib/libsvm-3.17/matlab');          
             addpath('/net/per610a/export/das09f/satoh-lab/dungmt//lib/liblinear-1.93/matlab');            
             run('/net/per610a/export/das09f/satoh-lab/dungmt/lib/vlfeat/toolbox/vl_setup'); 
		
     else 
            file_data = 'F:\Dataset\LSVRC\2010\data\meta.mat';
            fileLabel=   'F:\Dataset\LSVRC\2010\data\ILSVRC2010_validation_ground_truth.txt';
            pathToIMDBDir = 'F:\Dataset\LSVRC\2010\imdb';
            pathToFeaturesDir = 'F:\Dataset\LSVRC\2010\features\phow_LLCEncoder_SPMPooler_10000';
            pathToFile_Val = 'F:\Dataset\LSVRC\2010\imdb\ILSVRC2010.val.mat';
            pathToSave = 'F:\Dataset\LSVRC\2010\imdb\';
     end
     
     
	fprintf('\n\t Loading information about ILSVRD2010 dataset....');    
    K= 1000;

      
    % Tao mau am cho tung classs    
    
%    fprintf('\n Loading validation dataset: %s...', pathToFile_Val);
%    load(pathToFile_Val); %, 'val_instance_matrix','val_label_vector' ,'-v7.3');
%    fprintf('finish !');
  
    
    % Learn SVR
	
	
	if pre
		filename_pre_valval = fullfile(pathToSave,sprintf('ILSVRC2010.pre.val.val.mat'));
		
		fprintf('\n Loading precomputed kernel of validation %s...', filename_pre_valval);
		load(filename_pre_valval); %  save(pathToFile_ValVal, 'pre_valval_matrix','val_label_vector','-v7.3');
		%pre_valval_matrix = sparse(double(pre_valval_matrix));
		pre_valval_matrix = double(pre_valval_matrix);
		fprintf('finish !');
        libsvm_options = '-s 3 -t 4 -m 20000';
	else
		%filename_pre_valval = fullfile(pathToSave,sprintf('ILSVRC2010.val.mat'));
		%fprintf('\n Loading validation %s...', filename_pre_valval);
		%load(filename_pre_valval); 
		
		
		
		%filename_pre_valval_d = fullfile(pathToSave,sprintf('ILSVRC2010.val.d.mat'));
		%fprintf('\n Loading validation %s...', filename_pre_valval_d);
		%save(filename_pre_valval_d, 'val_instance_matrix','val_label_vector','-v7.3');
		%load(filename_pre_valval_d);
		%val_instance_matrix = val_instance_matrix ./ 0.1323;
		
		%filename_pre_valval_ds = fullfile(pathToSave,sprintf('ILSVRC2010.val.ds.mat'));
		%5fprintf('\n Saving validation %s...', filename_pre_valval_ds);
		%save(filename_pre_valval_ds, 'val_instance_matrix','val_label_vector','-v7.3');
		
		
		%val_instance_matrix = sparse(val_instance_matrix);
		filename_pre_valval_dss = fullfile(pathToSave,sprintf('ILSVRC2010.val.dss.mat'));
		fprintf('\n Saving validation %s...', filename_pre_valval_dss);
		%save(filename_pre_valval_dss, 'val_instance_matrix','val_label_vector','-v7.3');
		load(filename_pre_valval_dss); %, 'val_instance_matrix','val_label_vector','-v7.3');
		
		fprintf('finish !');
		%libsvm_options = '-s 0 -t 0 -m 20000';
		libsvm_options = '-s 3 -t 2 -c 20 -g 64 -p 1 -v 5 -m 20000' ;
		libsvm_options2 = '-s 0 -c 20 -p 1 -v 5' ;
	end
		    
    
    arr_Step = [100 200 300 400 500 600 700 800 900 1000];
	if matlabpool('size') > 0
          matlabpool close;            
    end
	%matlabpool open 2;
	
	
 %   for i=4:length(arr_Step)
  %      k = arr_Step(i);
		k = num_concept;
        fprintf('\n\t Training SVR k=%d...',k);
        filename_svds_usv   = fullfile(pathToSave,sprintf('ILSVRC2010.libsvm.pre.prob.val.svds.%3d.mat',k));
        filename_svr        = fullfile(pathToSave,sprintf('ILSVRC2010.libsvm.pre.prob.val.svds.svr.new.%3d.mat',k));
            
        if exist( filename_svds_usv, 'file')           
            if ~exist( filename_svr, 'file')
                fprintf('\n Loading file: %s...', filename_svds_usv);
                load(filename_svds_usv); %, 'U', 'S','V','-v7.3');
                fprintf('finish !');
                clear U;
                clear S;

                fprintf('\nTraining models...');
                num_classes =  size(V,2);
                fprintf('\n Number of classes: %d', num_classes);
                libsvm = cell(num_classes,1);
                if pre
                    %parfor ci=1:num_classes      
                    for ci=1:num_classes     
                            training_label_vector = V(:,ci);        
                            fprintf('\nLearning model %d with option=%s',ci,libsvm_options);
                           % libsvm{ci} = svmtrain(training_label_vector, training_instance_matrix, libsvm_options); 
                            libsvm{ci} = svmtrain(training_label_vector, pre_valval_matrix, libsvm_options);   
                    end
                else
                    for ci=1:num_classes      
                         filename_model_ci       = fullfile(pathToSave,sprintf('ILSVRC2010.libsvm.pre.prob.val.svds.svr.%3d.%d.mat',k,ci));
                         fprintf('\nLearning model %d with option=%s',ci,libsvm_options);
                         
                         if ~exist( filename_model_ci, 'file')
                            training_label_vector = V(:,ci); %*10000;  
						%	fprintf('\n Training libsvm...');
                         %   model = svmtrain(training_label_vector, val_instance_matrix, libsvm_options);  
							fprintf('\n Training liblinear...');
							model_linear = train(training_label_vector, val_instance_matrix, libsvm_options2)
                            fprintf('\n Writing model to file: %s...', filename_model_ci);
                          %  save(filename_model_ci, 'model','model2','-v7.3');
						  
							save(filename_model_ci,'model_linear','-v7.3');
                            fprintf('finish !');               
                            
                         %else
                          %  load(filename_model_ci);
                           % fprintf('finish  (ready) !');    
                         end
                         %libsvm{ci} = model;                       
                    end
                end						
            
                fprintf('\n Writing data to file: %s...', filename_svr);
                save(filename_svr, 'libsvm','-v7.3');
                fprintf('finish !');

            end
        end
 %   end
    
     if matlabpool('size') > 0
          matlabpool close;            
    end       
            
    fprintf('\nDONE!\n');
    end
    
   