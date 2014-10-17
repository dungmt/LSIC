function [Acc, SumNumConcept, MaxLevel,num_test_sample]=LabelTree_Test(conf, synsets, RootNode)  
%% Testing
% Updated: 22-2
    fprintf('\n\t -----------------------------------');
   fprintf('\n\t LabelTree:LabelTree_Test: Testing ...'); 
    pathToIMDBDirTest   = conf.path.pathToIMDBDirTest;
    if strcmp( conf.datasetName,'ILSVRC2010')  
       pathToIMDBDirTest  = fullfile(conf.path.pathToFeaturesDir, 'test');
       gtruth_test_file= fullfile(conf.dir.rootDir,'data/ILSVRC2010_test_ground_truth.txt');    
       gt_test_label_vector = dlmread(gtruth_test_file);
    end
    
    Acc=0;
    Level=0;
    LevelAll=0;
    MaxLevel = 0;
    SumNumConcept=0;
        
    if strcmp( conf.datasetName,'Caltech256')  || strcmp( conf.datasetName,'SUN397')  || strcmp( conf.datasetName,'ILSVRC65') 
        filename_test  = conf.test.filename;
        path_filename_test  = fullfile(conf.experiment.pathToBinaryClassifer, filename_test); 
        fprintf('\n\t Loading testing dataset from file: %s...',filename_test);        
        testing = load(path_filename_test); %,'instance_matrix',label_vector','-v7.3');   
        fprintf('finish !');
        num_test_sample = size(testing.instance_matrix,2);
        tic
        for i=1:num_test_sample
            test_label_vector = testing.label_vector(i);
            test_instance_matrix =sparse( (testing.instance_matrix(:,i) )' );
            level=1;
            num_concept=0;
            
            [leaf_indx,level,num_concept] = HC.test_nodes_new(RootNode, synsets, level,num_concept, test_label_vector, test_instance_matrix);
           
            LevelAll = LevelAll + level;
            SumNumConcept = SumNumConcept + num_concept;
            if (level > MaxLevel) 
                MaxLevel = level;
            end
            if(leaf_indx == test_label_vector)
                Acc = Acc+1;
                Level = Level + level;
            end
    %          pause;
        end
         toc
        pause;
    elseif strcmp( conf.datasetName,'ILSVRC2010') 
         start = 1; 
         tic
        for j=1:150 
                str_id = num2str(j,'%.4d');
                filename_test = ['test.',str_id,'.sbow.mat'] ;
                path_filename_test = fullfile(pathToIMDBDirTest, filename_test);
                if ~exist(path_filename_test,'file')  % kiem tra xem co file test                    
                    error('Missing test file %s !',path_filename_test);    
                end
                
                fprintf('\n\t\t Test file %s ...',filename_test);
                
                
                % load data: /data/Dataset/LSVRC/2010/features/phow_LLCEncoder_SPMPooler_10000/test/test.0004.sbow.mat
                % index                  1x1000                 8000  double              
                % setOfFeatures      50000x1000            200000000  single    
                fprintf('\n\t\t Loading data from file %s ...',filename_test);
                load(path_filename_test); % save(filename,'setOfFeatures','index','-v7.3');
                test_label_vector   = gt_test_label_vector (start: start+1000 -1 );
                numTest = 1000;               
             
                testing_instance_matrix = double(setOfFeatures');
                 fprintf('\n\t\t testing_instance_matrix.size 1 %d ...',size(testing_instance_matrix,1));
                num_test_sample = numTest;
                for i=1:num_test_sample
                    test_label_vector_i = test_label_vector(i)
                    test_instance_matrix =sparse( testing_instance_matrix(i,:));
                    level=1;
                    num_concept=1;
                    
                    [leaf_indx,level,num_concept] = HC.test_nodes_new(RootNode, synsets, level,num_concept, test_label_vector_i, test_instance_matrix);
                    
                    LevelAll = LevelAll + level;
                    SumNumConcept = SumNumConcept + num_concept;
                    if (level > MaxLevel) 
                        MaxLevel = level;
                    end
                    if(leaf_indx == test_label_vector_i)
                        Acc = Acc+1;
                        Level = Level + level;
                 %       leaf_indx
%                         pause
                    end
                      
                end
               start = start+1000;  
        end
        
        toc
        pause;
    else
        error('conf.datasetName');
    end
   
  
    %%%%%%%%%%%%%%%%%%
    % Truong hop dung du lieu toan cuc
%     pathToSaveData = '/data/Dataset/HICData.mat';
%     if ~exist(pathToSaveData,'file')        
%         fprintf('\n Allocating memory for variables ...');
%         globeData  = zeros(256*30,32000);
%         globeLabel = zeros(256*30,1);
%         fprintf('done.');
%         for i=1:256
%            fprintf('\n Loading data of class %d ...',i);
%            Data = HC.loadData(i, conf)       
%            globeData( (i-1)*30+1:i*30,:) = Data.instance_matrix';
%            globeLabel((i-1)*30+1:i*30,:) = Data.label_vector';
%         end
%         globeData = sparse(globeData);
%         save(pathToSaveData, 'globeData','globeLabel','-v7.3');    
%     else
%         load (pathToSaveData);
%     end
end