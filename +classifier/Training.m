function Training(conf,start_Idx,end_Idx, step)

    fprintf('\n\t Training model of classifiers ... ');   
    
  %%  preComputed_Kernel=true;
    numClass            = conf.class.Num;
    pathToIMDBDir       = conf.path.pathToIMDBDir;
    pathToModelClassifer = conf.path.pathToModelClassifer;
    ClassNames          = conf.class.Names;
    solver              = conf.svm.solver;
    preComputed_Kernel  = conf.svm.preCompKernel;
    suffix_file_train=conf.svm.suffix_file_train;
    
    path_filename_classifier_ready  = fullfile(pathToModelClassifer,[conf.datasetName,'.',solver, conf.svm.suffix_ready_classifier]);
    
    if exist (path_filename_classifier_ready,'file')
       fprintf('finish (ready) (%s) !',path_filename_classifier_ready);
       return;
    end
    
    fprintf('\n\t\t Solver: %s',solver);
    fprintf('\n\t\t preComputed_Kernel: %d',preComputed_Kernel); 
    fprintf('\n\t\t Number of classes: %d',numClass); 
    %parfor i=1:numClass
    suffix_file_model = conf.svm.suffix_file_model;
    libsvmoption = conf.svm.libsvmoption;       
   
    for i=start_Idx:step:end_Idx
       
        synset = ClassNames(i);
        synset = synset{1};
        
        fprintf('\n\t\t Traing model for class: %d: %s ...',i,synset);   
        filename_model = sprintf('%s.%s%s',synset,solver,suffix_file_model);        
        pathToDirModel = fullfile(pathToModelClassifer, synset);
        path_filename_model = fullfile(pathToDirModel,filename_model );   
        
        if ~(exist(path_filename_model,'file'))
            
            filename_data =  [synset,suffix_file_train];
			path_filename_data = fullfile(pathToDirModel,filename_data ); 
			
			if(exist(path_filename_data,'file'))		
                tic
				fprintf('\n\t\t\t Loading data file: %s...',filename_data);
				S = load(path_filename_data);  
				fprintf('finish !');
				% Training
				fprintf('\n\t\t\t Training libsvmoption =%s...',libsvmoption);
				
				if (preComputed_Kernel)					
					numTrain = length(S.label_vector);
					K = [(1:numTrain)', S.pre_matrix+eye(numTrain)*realmin];
                   % K = [(1:numTrain)', S.pre_matrix];
                    if ~isa(K,'double');
                        K =double(K);
                    end
					model = svmtrain(S.label_vector', K, libsvmoption);
					clear K;
					clear S;
                else					
					model = svmtrain(S.label_vector', sparse(double(S.instance_matrix')), libsvmoption);                
				end
				% Save mo hinh
				fprintf('\n\t\t\t Saving model to file:%s ...',filename_model);
                MySaveModel (path_filename_model, model);			   
				fprintf('finish !');
                fprintf('\n\t\t\t ');
                toc
			else
                error('Error: File %s is not found !',path_filename_data);
            end
        else
            fprintf('finish (ready) !');
        end
       
    end
%     ready=1;
%     save(path_filename_classifier_ready,  'ready','-v7.3');	
    
    
   
end
function MySaveModel (pathToFile_Model, model)
    save(pathToFile_Model, 'model', '-v7.3');
end


        
 