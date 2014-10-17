function [conf] = LoadInforDataset( conf )
        fprintf('\n -----------------------------------------------');
        fprintf('\n Loading information about dataset....');    
        
        if strcmp( conf.datasetName,'ILSVRC65')
            K= 57;
            file_data = fullfile(conf.dir.rootDir, 'data/ilsvrc65_meta.mat');
            Infor = load (file_data);
            fprintf('finish !');
            conf.class2id_map = Infor.class2id_map;

            ClassNames = { Infor.synsets.WNID}; % lay gia tri cua thuoc tinh num_train_images trong tat ca phan tu
            conf.class.Names = ClassNames(1:K); % chon ra K phan tu dau tien 1:K
            Words = { Infor.synsets.words};
            conf.class.Words = Words(1:K);
            
            IDs = [ Infor.synsets.ids ];
            conf.class.IDs = IDs(1:K);
            conf.class.Num = K;
        elseif strcmp( conf.datasetName,'ILSVRC2010')
            K= 1000;
            file_data = fullfile(conf.dir.rootDir, 'data/meta.mat');
            Infor = load (file_data);
            fprintf('finish !');

            ClassNames = { Infor.synsets.WNID}; % lay gia tri cua thuoc tinh num_train_images trong tat ca phan tu
            conf.class.Names = ClassNames(1:K); % chon ra K phan tu dau tien 1:K
            Words = { Infor.synsets.words};
            conf.class.Words = Words(1:K);
            
            IDs = [ Infor.synsets.ILSVRC2010_ID ];
            conf.class.IDs = IDs(1:K);
            conf.class.Num = K;
        elseif strcmp(conf.datasetName ,'Caltech256')
            ClassNames = utility.getDirectoriesAtPath(conf.path.pathToImagesDir );
            numClass = length(ClassNames) -1 ;
            if numClass <1  
                error('Not found class in directory %s\n',conf.path.pathToImagesDir );
            end      
            conf.class.Num = numClass;
            conf.class.Names = ClassNames(1:numClass);
            conf.class.IDs = 1: numClass;
        elseif strcmp(conf.datasetName ,'SUN397')
%             filename_ClassName = fullfile(conf.path.pathToImagesDir,'ClassName.txt');
%             fid = fopen(filename_ClassName, 'rt');
%             lines = textscan(fid, '%s');
% %             lines = lines{1};
%             fclose(fid);
%           
%             ClassNames = lines{1};

            ClassNames = utility.getDirectoriesAtPath(conf.path.pathToImagesDir );
            numClass = length(ClassNames) ;
            if numClass <1  
                error('Not found class in directory %s\n',conf.path.pathToImagesDir );
            end      
            conf.class.Num = numClass;
            conf.class.Names = ClassNames(1:numClass);
            conf.class.IDs = 1: numClass;
            % open file
        elseif strcmp(conf.datasetName ,'ImageCLEF2012')

            path_file_data = fullfile(conf.dir.rootDir, 'data/meta.mat');
            if exist(path_file_data,'file')
                load (path_file_data);
            else
                path_file_concepts = fullfile(conf.dir.rootDir,'data/concepts.txt');
                ClassNames = utility.readFileByLines(path_file_concepts);            
                numClass = length(ClassNames) ;            
                if numClass <1  
                    error('Not found class in directory %s\n',conf.path.pathToImagesDir );
                end    
                numClass = numClass/2;
                for i=1:numClass
                    Names{i} = sprintf('%s %s',ClassNames{2*i-1},ClassNames{2*i});
                end
                save(path_file_data,'numClass','Names');
            end
            conf.class.Num = numClass;
            conf.class.Names =Names;
            conf.class.IDs = 1: conf.class.Num;
           
            
        else
            error('\nError: Dataset %s is not supported',conf.datasetName);
        end 
        fprintf('\n\t Dataset: %s',conf.datasetName); 
        fprintf('\n\t Number of classes: %d',conf.class.Num); 

end

