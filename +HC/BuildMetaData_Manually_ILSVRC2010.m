function synsets = BuildMetaData_Manually_ILSVRC2010(conf)
   
    fprintf('\n\t --> LabelTree:BuildMetaData: BuildMetaData_Auto: Automatic Building metata ...'); 
    num_classes = conf.class.Num;
   
    if strcmp( conf.datasetName,'ILSVRC2010')  
        pathToData = fullfile(conf.dir.rootDir,'data');
        path_file_name_meta = fullfile(pathToData, 'meta.mat');
        if ~exist(path_file_name_meta,'file')
            error('File %s not found !',path_file_name_meta);
        end
        MetaILSVRC2010 = load(path_file_name_meta); %,'synsets','-v7.3');
    %%    synsets = MetaILSVRC2010.synsets(1:1000);
        synsets = MetaILSVRC2010.synsets;
        for i=1:num_classes
           % synsets(i) = MetaILSVRC2010.synsets(i);            
            synsets(i).num_children=0;
            synsets(i).children =[];            
            synsets(i).leaf_indx=i;
            synsets(i).parent_indx=[];
        end
         
     else
         error('BuildMetaData_Auto: %s Chua xy ly',conf.datasetName);    
     end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   
end

