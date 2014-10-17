function Data = loadData(id, conf)

%     class_ci = conf.class.Names{id};
    pathToIMDBDirTrain  = conf.path.pathToIMDBDirTrain;
    pathToIMDBDirVal    = conf.path.pathToIMDBDirVal;
    pathToIMDBDirTest   = conf.path.pathToIMDBDirTest;
    if strcmp( conf.datasetName,'ILSVRC2010')  
%        pathToIMDBDirTrain    = fullfile(conf.path.pathToFeaturesDir, 'train');
       pathToIMDBDirTest  = fullfile(conf.path.pathToFeaturesDir, 'test');
       pathToIMDBDirVal = fullfile(conf.path.pathToFeaturesDir, 'val');
    end
%     filename_sbow_of_class = [class_ci,'.sbow.mat'];
%     path_filename_train = fullfile(pathToIMDBDirTrain, filename_sbow_of_class );
%     %save(path_filename_train,'instance_matrix','label_vector','-v7.3');
%     Data = load(path_filename_train); %,'instance_matrix','label_vector','-v7.3');
    
    ClassName= conf.class.Names{id};
    filename_feature = [ClassName,'.sbow.mat'];
    path_filename_feature = fullfile(pathToIMDBDirTrain,filename_feature);
    if ~exist(path_filename_feature, 'file')
        error('Error: File %s is not found !', path_filename_feature);            
    end
    fprintf('\n\t Loading positive samples from file: %s ...  ', filename_feature);
    tmp = load(path_filename_feature) % instance_matrix = 50.000(kich thuoc feature) x (so anh)
    fprintf('finish!');

    % Cho cac anh dau tien
    if strcmp(conf.datasetName,'ILSVRC2010') 
%  Name                     Size                Bytes  Class     Attributes
% 
%   instance_matrix      50000x100            20000000  single              
%   label_vector             1x100                 800  double         
         Data.instance_matrix =double( tmp.instance_matrix); 
        Data.label_vector  = tmp.label_vector;
     
    else
        Data.instance_matrix = tmp.instance_matrix;  
        Data.label_vector  = tmp.label_vector;
    end
    
    
                
    clear tmp;  
            
end