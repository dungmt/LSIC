function conf = MakeDirectories(conf )
       
    % thu muc chua anh 
    fprintf('\n -----------------------------------------------');
    fprintf('\n Creating directories ...');
    conf.path.pathToImagesDir = fullfile(conf.dir.rootImagesDir,conf.dir.imagesDir);
    if ~exist(conf.path.pathToImagesDir,'dir')
        error('Not found directory %s\n',conf.path.pathToImagesDir);
    end          
    
    % --------------------------------------------------------------------
    % thu muc: features
    conf.path.pathToFeaturesDir = fullfile(conf.dir.rootDir,conf.dir.featuresDir);
    utility.MakeDirectory(conf.path.pathToFeaturesDir);
    
    if strcmp(conf.feature.typeFeature,'phow') 
        % thu muc: features\phow_voc_size
        pathToFeaturesDir_tmp = [conf.feature.typeFeature '_' conf.BOW.typeEncoder '_' conf.BOW.typePooler sprintf('_%d',conf.BOW.voc_size)];
        conf.str.strFeature = pathToFeaturesDir_tmp;
        conf.path.pathToFeaturesDir = fullfile(conf.path.pathToFeaturesDir,pathToFeaturesDir_tmp);

        utility.MakeDirectory(conf.path.pathToFeaturesDir); 

        conf.BOW.path.pathToRootDir = fullfile(conf.dir.rootDir,conf.BOW.dir.rootDir);
        utility.MakeDirectory(conf.BOW.path.pathToRootDir);       

        %code book
        conf.BOW.path.pathToCodeBooksDir = fullfile(conf.BOW.path.pathToRootDir,conf.BOW.dir.codeBooksDir);
        utility.MakeDirectory(conf.BOW.path.pathToCodeBooksDir);       

        % keypoints
        conf.BOW.path.pathToKeyPointsDir = fullfile(conf.BOW.path.pathToRootDir,conf.BOW.dir.keyPointsDir);
        utility.MakeDirectory(conf.BOW.path.pathToKeyPointsDir);
    else        
        % thu muc:  features\hog
        conf.path.pathToFeaturesDir = fullfile(conf.path.pathToFeaturesDir,conf.feature.typeFeature);
        utility.MakeDirectory(conf.path.pathToFeaturesDir); 

    end
        
    % --------------------------------------------------------------------
    % Data base
    % pathToIMDBDir
    conf.path.pathToIMDBDir = fullfile(conf.dir.rootDir,conf.dir.imdbDir);
    conf.path.pathToIMDBDir = fullfile(conf.path.pathToIMDBDir,conf.str.strFeature);
    
    
    utility.MakeDirectory(conf.path.pathToIMDBDir);
    
     % --------------------------------------------------------------------
    % Experiment
    conf.dir.experimentDir=fullfile(conf.dir.experimentDir,conf.str.strFeature);
    
    utility.MakeDirectory(conf.dir.experimentDir);    
    fprintf('\n Directories are created successfull !\n');
    %fprintf(' finish !');
 
end

