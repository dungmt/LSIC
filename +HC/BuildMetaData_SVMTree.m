function synsets = BuildMetaData_SVMTree(conf)
   
    fprintf('\n\t --> LabelTree:BuildMetaData: BuildMetaData_Auto: Automatic Building metata ...'); 
    
    num_classes = conf.class.Num;
    Classes     = conf.class.Names;
     if strcmp( conf.datasetName,'Caltech256') || strcmp( conf.datasetName,'SUN397') || strcmp( conf.datasetName,'ILSVRC65') 
         for i=1:num_classes
            ClassName = conf.class.Names{i};
            synsets(i).SYNSET_ID=i;
            synsets(i).WNID = ClassName;
            synsets(i).words = ClassName;
            synsets(i).gloss = ClassName;
            synsets(i).num_children=0;
            synsets(i).children =[];
            synsets(i).wordnet_height=0;
            synsets(i).num_train_images=0;
            synsets(i).leaf_indx=[i];
            synsets(i).parent_indx=[];
        end
     elseif strcmp( conf.datasetName,'ILSVRC2010')  
        pathToData = fullfile(conf.dir.rootDir,'data');
        path_file_name_meta = fullfile(pathToData, 'meta.mat');
        if ~exist(path_file_name_meta,'file')
            error('File %s not found !',path_file_name_meta);
        end
        MetaILSVRC2010 = load(path_file_name_meta); %,'synsets','-v7.3');
        synsets = MetaILSVRC2010.synsets(1:1000);
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
%================
% Doc tung class roi lay gia tri trung binh lam vector
    path_filename_mean_data = fullfile(conf.experiment.pathToHIC,'mean_data.mat');
    if ~exist(path_filename_mean_data,'file')
         pathToIMDBDirTrain    = conf.path.pathToIMDBDirTrain;
         if   strcmp( conf.datasetName,'ILSVRC65') 
            output_dim = 100000;
         else
             output_dim = conf.BOW.pooler.get_output_dim();
         end
         data = zeros(output_dim, num_classes);
         for ci = 1:num_classes
            class_ci = Classes{ci};            
            fprintf('\n\t\t Processing class: %s (%d/%d)...',class_ci,ci,num_classes);
            filename_sbow_of_class = [class_ci,'.sbow.mat'];
            path_filename_train = fullfile(pathToIMDBDirTrain, filename_sbow_of_class );

            if ~exist(path_filename_train,'file')
                error('File %s not found ',path_filename_train);
            end

            fprintf('\n\t\t\t --> Loading file: %s...',filename_sbow_of_class);
            tmpf = load(path_filename_train);  
            data(:,ci) = mean(tmpf.instance_matrix,2);     
         end
         fprintf('\n\t Saving mean data into file: %s....',path_filename_mean_data); 
         save(path_filename_mean_data,'data','-v7.3');
    else
        load(path_filename_mean_data);
    end
    %% - Root
    i  =num_classes +1;
    synsets(i).SYNSET_ID=i;
    synsets(i).WNID = 'Root';
    synsets(i).num_children=0;
    synsets(i).children =[];
    synsets(i).leaf_indx = [1:num_classes];
    synsets(i).parent_indx=[];

    % Clusster
    % Tao cac leafnode
    % we fix two parameters, the number of children Q for each node, and
    % the maximum depth H of the tree. 
    
%     synsets(i)
%     pause
%                 
    index_synset = i;
    while true
        if(i>length(synsets))
            break;
        end
        node = synsets(i);
        if(isempty(node));
            break;
        end;
        fprintf('\n Clusterind node %d ... ',i);
        
        num_leaf_indx = length(node.leaf_indx);
        if(num_leaf_indx < 2)
            i=i+1;            
            continue;
        end
        
        numClusters = 2;
        child_data = data(:,node.leaf_indx);
        child_label = node.leaf_indx;
        
        
        [centers, assignments] = vl_kmeans(child_data, numClusters);
      
        unique_Centers = unique(assignments);
        num_cluster = length(unique_Centers);
        if num_cluster ~=2
            error('Loi: vl_kmeans(child_data, numClusters) :num_cluster ~=2')
        end
        
        synsets(i).num_children=num_cluster;
        synsets(i).children = [];

        theNode = synsets(i);
        names=fieldnames(theNode);
        node_id = getfield(theNode,names{1}) ;
        for k=1:num_cluster
            child_leaf_indx = child_label(find(assignments==unique_Centers(k)));

            if(length(child_leaf_indx)==1)                
                synsets(i).children = [synsets(i).children, child_leaf_indx];                
                synsets(child_leaf_indx).parent_indx= node_id ;
%                 synsets(i)
%                 pause
                continue;
            else
                index_synset = index_synset+1;
                synsets(index_synset).SYNSET_ID=index_synset;
                synsets(index_synset).WNID = sprintf('Node%d',index_synset);
                synsets(index_synset).num_children=0;
                synsets(index_synset).children =[];
                synsets(index_synset).leaf_indx=  child_leaf_indx;
                synsets(index_synset).parent_indx= node_id ;                 
                synsets(i).children = [synsets(i).children, index_synset];                  
                synsets(index_synset)
            end
%               pause
        end
%          index_synset
%          synsets(i)
%          pause
%         synsets(i).leaf_indx
%         pause        
        i = i+1;
        
    end

    for i=num_classes+1: length(synsets)
        synsets(i).words = synsets(i).WNID;
        synsets(i).gloss = synsets(i).WNID;
        synsets(i).wordnet_height=0;
        synsets(i).num_train_images=0;
    end

end

