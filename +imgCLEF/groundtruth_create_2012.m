    path_filename_data = '/data/Dataset/imageCLEF/imageclef2012/data/meta.mat';

    %% Test
    path_to_test_concepts = '/data/Dataset/imageCLEF/imageclef2012/test_annotations/concepts';
    path_to_test_images = '/data/Dataset/imageCLEF/imageclef2012/test_images/images';
    path_filename_gt_test = '/data/Dataset/imageCLEF/imageclef2012/data/test_groundtruth.mat';
    if ~exist(path_filename_gt_test,'file') 
        [ground_truth_matrix ]=  imgCLEF.groundtruth_read_2012(path_filename_data,path_to_test_concepts,path_to_test_images);
        fprintf('\n Saving ground_truth_matrix into file %s ...', path_filename_gt_test);
        save(path_filename_gt_test,'ground_truth_matrix','-v7.3');
        fprintf('done !');
    else
        fprintf('\n Loading ground_truth_matrix into file %s ...', path_filename_gt_test);
        load(path_filename_gt_test);
        fprintf('done !');    
    end
    % Evaluate
    topn = 5;
    path_filename_score_matrix_test = '/data/Dataset/imageCLEF/imageclef2012/experiments/train75p.val25p.test100p/binclassifiers/train75p.blaall/ImageCLEF2012.liblinear.prob.test100p.scores.mat';
    test = load(path_filename_score_matrix_test);
    [annotation_dec_matrix ]=  imgCLEF.annotation_dec_2012(test.scores_matrix, topn);

    GTMAT = ground_truth_matrix'; 
    SCO = test.scores_matrix';
%     DEC = annotation_dec_matrix'; 
    DEC = ground_truth_matrix'; 
save('/data/Dataset/imageCLEF/imageclef2012/data/annotation_dec_matrix.mat','annotation_dec_matrix');

     [ AP, pfirst, dPREC, dRECL, dF ] = imgCLEF.evalannotat_2012( GTMAT, SCO, DEC,'mean');
%     [ AP, pfirst, dPREC, dRECL, dF ] = imgCLEF.evalannotat_2012( GTMAT, SCO, DEC);
%      AP
 
%% Val
path_filename_gt_train = '/data/Dataset/imageCLEF/imageclef2012/data/train_groundtruth.mat';
path_filename_gt_val = '/data/Dataset/imageCLEF/imageclef2012/data/val_groundtruth.mat';
path_filename_score_matrix_val  = '/data/Dataset/imageCLEF/imageclef2012/experiments/train75p.val25p.test100p/binclassifiers/train75p.blaall/ImageCLEF2012.liblinear.prob.val25p.scores.mat';
% Doc tap val -1

if ~exist(path_filename_gt_val,'file')
     load (path_filename_data);
     num_concepts = numClass;
     pathToIMDBDirVal    = '/data/Dataset/imageCLEF/imageclef2012/imdb/train75p.val25p.test100p/val25p';
     pathloc = fullfile('/data/Dataset/imageCLEF/imageclef2012','train_annotations/concepts');    
     pathToFeaturesDirTrain=fullfile('/data/Dataset/imageCLEF/imageclef2012','train_images/images');   
     path_filename_list_id_images_in_val = '/data/Dataset/imageCLEF/imageclef2012/data/list_id_images_in_val.mat';
     
     if ~exist(path_filename_list_id_images_in_val,'file')
         list_id_images_in_val = {}; 
         num_list_id_images_in_val =0;
         
         label_vector =[];
         
         for ci=1:num_concepts
            fprintf('\n Concept: %s', Names{ci});
            class_ci = Names{ci};
            fprintf('\n\t\t Processing class: %s (%d/%d)...',Names{ci},ci,num_concepts);

            file_name_concept=[class_ci,'.txt'];
            path_file_name_concept = fullfile(pathloc,file_name_concept);                
            list_image_concepts = utility.readFileByLines(path_file_name_concept);
            num_images = length(list_image_concepts);             

            if num_images<1
                error('Concept %s is empy !!', class_ci);
            end

            filename_sbow_of_class = [class_ci,'.sbow.mat'];
            path_filename_val = fullfile(pathToIMDBDirVal, filename_sbow_of_class );
            if ~exist(path_filename_val,'file')
                error('File %s not found ',path_filename_val);
            end

            fprintf('\n\t\t\t --> Loading file: %s...',filename_sbow_of_class);
            tmpf = load(path_filename_val);           %  save(path_filename_val,'instance_matrix','label_vector','rand_indices_val','-v7.3'); 

            list_image_concepts_in_val = list_image_concepts(tmpf.rand_indices_val);
            num_image_in_val = length(list_image_concepts_in_val);
            fprintf('\n\t\t\t --> num_image_in_val: %d...',num_image_in_val);
            for j=1: num_image_in_val     

                    index_img = find(strncmp(list_id_images_in_val,list_image_concepts_in_val{j},length(list_image_concepts_in_val{j})));
        %             pause
                    if isempty(index_img)
                        num_list_id_images_in_val = num_list_id_images_in_val+1;
                        list_id_images_in_val{num_list_id_images_in_val} =  list_image_concepts_in_val{j};
%                         instance_matrix = [instance_matrix, tmpf.instance_matrix(:,j)];     
                        label_vector = [label_vector, tmpf.label_vector(j)];  
                        fprintf('.');
                    end
            end
         end
         path_filename_val_selected = '/data/Dataset/imageCLEF/imageclef2012/experiments/train75p.val25p.test100p/binclassifiers/ImageCLEF2012.val25p.sbow.mat';
         save(path_filename_list_id_images_in_val,'list_id_images_in_val','num_list_id_images_in_val');     
         fprintf('\n\t Creating validation');
         if ~exist(   path_filename_val_selected,'file')
             pathToFeaturesDirTrain = '/data/Dataset/imageCLEF/imageclef2012/train_images/images'

             filename_feature_of_image=[list_id_images_in_val{1},'.feat.mat'];
             path_filename_feature_of_image = fullfile(pathToFeaturesDirTrain,filename_feature_of_image);
             tmpf = load(path_filename_feature_of_image);


             instance_matrix=zeros(size(tmpf.setOfFeatures,1),num_list_id_images_in_val);
             for j=1: num_list_id_images_in_val     
                filename_feature_of_image=[list_id_images_in_val{j},'.feat.mat'];
                path_filename_feature_of_image = fullfile(pathToFeaturesDirTrain,filename_feature_of_image);
                tmpf = load(path_filename_feature_of_image);
                instance_matrix(:,j) = tmpf.setOfFeatures(:,1);
                fprintf('.');
             end

             fprintf('\n\t Saving validation set into file: %s....',path_filename_val_selected);         
    %             instance_matrix = val_instance_matrix_selected;  % dim x n
    %             label_vector = val_label_vector_selected;
                save(path_filename_val_selected,'instance_matrix','label_vector','-v7.3');
                fprintf('finish !');
         end   
     else
        fprintf('\n\t Loading file %s ...', path_filename_list_id_images_in_val);
        load(path_filename_list_id_images_in_val);
        fprintf('done !'); 
         
     end
    fprintf('\n\t\t num_list_id_images_in_val: %d',num_list_id_images_in_val);
    fprintf('\n\t Creating val_ground_truth_matrix');
    val_ground_truth_matrix = zeros(num_list_id_images_in_val,num_concepts);     
    path_train_annotations = '/data/Dataset/imageCLEF/imageclef2012/train_annotations/annotations';
    for j=1: num_list_id_images_in_val     
        file_name_image_concept=[list_id_images_in_val{j},'.txt'];
        path_file_name_image_concept = fullfile(path_train_annotations,file_name_image_concept);
        fprintf('\n\t\t File %s ',file_name_image_concept);
        list_id_concept = utility.readFileByLines(path_file_name_image_concept);
        num_list_id_concept = length(list_id_concept)/2;
        fprintf(' (%d concepts)',num_list_id_concept);
     
        for k=1:num_list_id_concept
            id_concept = str2num( sprintf('%s',list_id_concept{2*k-1}) )+1;
            if (id_concept<1 || id_concept > num_concepts)
                error('id_concept=%d',id_concept);
            end            
            val_ground_truth_matrix(j,id_concept)=1;   
        end
     end 

    fprintf('\n Saving ground_truth_matrix into file %s ...', path_filename_gt_val);
    ground_truth_matrix = val_ground_truth_matrix;
    save(path_filename_gt_val,'ground_truth_matrix','-v7.3');

    fprintf('done !');        
 
else
        fprintf('\n Loading ground_truth_matrix into file %s ...', path_filename_gt_val);
        load(path_filename_gt_val);
        fprintf('done !');    
end
fprintf('\n Evaluate....')
    

    GTMAT = ground_truth_matrix'; 
    val =load(path_filename_score_matrix_val);
    SCO = val.scores_matrix';
%     DEC = annotation_dec_matrix'; 
    DEC = ground_truth_matrix'; 
    [ AP, pfirst, dPREC, dRECL, dF ] = imgCLEF.evalannotat_2012( GTMAT, SCO, DEC,'mean');
%     [ AP, pfirst, dPREC, dRECL, dF ] = imgCLEF.evalannotat_2012( GTMAT, S


 