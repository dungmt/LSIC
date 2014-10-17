function synsets = BuildMetaData_Auto(conf, Q)
   
    fprintf('\n\t --> LabelTree:BuildMetaData: BuildMetaData_Auto: Automatic Building metata ...'); 
    num_classes = conf.class.Num;
     if strcmp( conf.datasetName,'Caltech256') || strcmp( conf.datasetName,'SUN397')
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
         
       elseif strcmp( conf.datasetName,'ILSVRC65')  
        pathToData = fullfile(conf.dir.rootDir,'data');
        path_file_name_meta = fullfile(pathToData, 'ilsvrc65_meta.mat');
        if ~exist(path_file_name_meta,'file')
            error('File %s not found !',path_file_name_meta);
        end
        MetaILSVRC65 = load(path_file_name_meta); %,'synsets','-v7.3');
        synsets = MetaILSVRC65.synsets(1:57);
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
% Chuyen ma tran confusion sang ma tran khoang cach
%Load score matrix
    pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains ; 
    filename_score_matrix = conf.val.filename_score_matrix;
    path_filename_score_matrix 		= fullfile(pathToBinaryClassiferTrains,filename_score_matrix);
    if ~exist(path_filename_score_matrix,'file')
        error('File %s is not found !', path_filename_score_matrix);
    end
    
    fprintf('\n\t\t Loading score matrix validation file: %s ',filename_score_matrix);
    validation = load(path_filename_score_matrix)  % save(path_filename_score_matrix, 'scores_matrix','-v7.3'); val_label_vector
    fprintf('finish !');
   
    % validation.scores_matrix =  num_images x num_class
    scores_matrix = validation.scores_matrix;
    if size(scores_matrix,1) < size(scores_matrix,2)
       scores_matrix =scores_matrix';
    end
    
    [~,pred_label_vector] = max(scores_matrix,[],2); % index of column whose value is max of each row    

    
    [confusion_matrix,order] = confusionmat(validation.val_label_vector,pred_label_vector); 
   
%     whos
%     pause

    num_class = size(confusion_matrix,1);
    assert(num_class == num_classes);
    %Acc = sum(diag(confusion_matrix));
    % Tinh ma tran similarity
    dist_matrix = confusion_matrix;
    for i=1:num_class
        for j=i+1:num_class
            dist_matrix(i,j) = dist_matrix(i,j) + dist_matrix(j,i);
            dist_matrix(j,i) = dist_matrix(i,j);
        end
%          dist_matrix(i,i)=0;
    end 

    %% - Root
    i  =num_class +1;
    synsets(i).SYNSET_ID=i;
    synsets(i).WNID = 'Root';
    synsets(i).num_children=0;
    synsets(i).children =[];
    synsets(i).leaf_indx = [1:num_class];
    synsets(i).parent_indx=[];

    % Clusster
    % Tao cac leafnode
    % we fix two parameters, the number of children Q for each node, and
    % the maximum depth H of the tree. 
    
    H=floor(log(num_class)/log(Q) +0.5);
    QH = power(Q,H);
    if(QH < num_class)
        fprintf('power(Q,H)<num_class');
    end
    fprintf('\n Value of Q =%d',Q);
    fprintf('\n Value of H =%d',H);
    Type=2;
    
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
        
        
        child_label = node.leaf_indx;
        child_dist_matrix = zeros(num_leaf_indx,num_leaf_indx);
        for ii = 1: num_leaf_indx
            for jj = ii+1: num_leaf_indx
                child_dist_matrix(ii,jj) = dist_matrix(child_label(ii),child_label(jj));
                child_dist_matrix(jj,ii) = child_dist_matrix(ii,jj) ;
            end
        end

        ncluster = min(num_leaf_indx,Q);
        [Centers, L, U] = SpectralClustering(child_dist_matrix, ncluster, Type, Q, H);
        unique_Centers = unique(Centers);
        num_cluster = length(unique_Centers);
        synsets(i).num_children=num_cluster;
        synsets(i).children = [];

        theNode = synsets(i);
        names=fieldnames(theNode);
        node_id = getfield(theNode,names{1}) ;
        for k=1:num_cluster
            child_leaf_indx = child_label(find(Centers==unique_Centers(k)));

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
%              pause
        end
         index_synset
%          synsets(i)
%          pause
%         synsets(i).leaf_indx
%         pause        
        i = i+1;
        
    end

    for i=num_class+1: length(synsets)
        synsets(i).words = synsets(i).WNID;
        synsets(i).gloss = synsets(i).WNID;
        synsets(i).wordnet_height=0;
        synsets(i).num_train_images=0;
    end

end

