function ListClass(conf,start_Idx,end_Idx, step)
%TrainingTesting Thuc hien training cho tap du lieu
% Dung pp precomputed kernel
% 
    fprintf('\n Training model of classifiers...');   
    %% Tao thu muc trong chua ket qua tung class 
    pathToIMDBDir = conf.path.pathToIMDBDir;
    pathToModelClassifer = conf.path.pathToModelClassifer;
    pathToFeaturesDirTrain = fullfile(conf.path.pathToFeaturesDir,'train');
    
    for i=start_Idx:step:end_Idx
        ClassName = conf.class.Names{i};
        fprintf('\n Class (%d): %s', i,ClassName);
        
        filename_class = ['/net/per610a/export/das11f/plsang/dungmt/', ClassName, '/',ClassName,'.libsvm.pre.prob.bla10.mat'];
        if exist(filename_class, 'file')
            fprintf(' ready !');
        else
            pause;
         %   break;
        end
        
            
%  		filename_old = ['/net/per610a/export/das11f/plsang/dungmt/', ClassName, '/',ClassName,'.pre.val.train.bla10.mat'];
%         filename_new = ['/net/per610a/export/das11f/plsang/dungmt/', ClassName, '/',ClassName,'.pre.val30.train.bla10.mat'];
%  		if exist(filename_old, 'file')
%             if exist(filename_new, 'file')
%                 fprintf('\n\t Deleting file %s ...', filename_old);
%                 delete (filename_old);
%                 fprintf('finish !');
%             else
%                 fprintf('\n\t Renaming file %s to %s ...', filename_old,filename_new);
%                 movefile (filename_old,filename_new);
%                 fprintf('finish !');
%             end			
% 		end
	%	pause;
		
    end
    %% Tao tap du lieu train cho tung class    

end

