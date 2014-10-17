clear all;
AddPathLib(  );
if ispc
    path_dataset = 'F:/Dataset/NUS_WIDE';
    pathToTrainTestLabels = 'F:/Dataset/NUS_WIDE/Groundtruth/TrainTestLabels';
    pathToModelSVM = 'F:/Dataset/NUS_WIDE/SVMModels'; 
    pathToTags = 'F:/Dataset/NUS_WIDE/NUS_WID_Tags';
    pathToLowLevelFeatures = 'F:/Dataset/NUS_WIDE/Low_Level_Features';
else
    
    path_dataset = '/data/Dataset/NUS_WIDE';
    pathToTrainTestLabels = '/data/Dataset/NUS_WIDE/Groundtruth/TrainTestLabels';
    pathToModelSVM = '/data/Dataset/NUS_WIDE/SVMModels'; 
    pathToTags = '/data/Dataset/NUS_WIDE/NUS_WID_Tags';
    pathToLowLevelFeatures = '/data/Dataset/NUS_WIDE/Low_Level_Features';
end
 
 path_filename_listConcepts = fullfile(path_dataset,'Concepts81.txt');    
[ listConcepts ] = NUS_WIDE.ReadConcepts(path_filename_listConcepts);
%         Normalized_CH :           64-D color histogram with each row represents an image.
%         Normalized_CORR :      144-D color correlogram with each row represents an image.
%         Normalized_EDH :         75-D edge direction histogram with each row represents an image.
%         Normalized_WT :          128-D wavelet texture with each row represents an image.
%         Normalized_CM55 :       225-D block-wise color moments with each row represent an image.
%         BoW_int :                     500-D bag of words with each row represent an image.
prefix_Train = 'Train_';
suffix_Train = '_Train';
prefix_Test = 'Test_';
suffix_Test = '_Test';

suffix_Filename_Features = '.dat';

%--------------------------------------------------------------------------
%  Train/ Test ?
%--------------------------------------------------------------------------

is_Train =true;

if is_Train
    prefix_Filename_Features = prefix_Train;
    suffix_Filename_Labels = suffix_Train;
    m_items = 161789; 
    filename_Tags = 'Train_Tags81.txt';
    fprintf('\n Training dataset');

else
    prefix_Filename_Features = prefix_Test;
    suffix_Filename_Labels = suffix_Test;
    m_items  =107859;
    filename_Tags = 'Test_Tags81.txt';
    fprintf('\n Testing dataset');
end


%--------------------------------------------------------------------------
%  Features
%--------------------------------------------------------------------------
arr_LowLevelFeatures = {'Normalized_CH','Normalized_CORR','Normalized_EDH','Normalized_WT','Normalized_CM55','BoW_int'};
arr_n_dimension_feature = [64,144,75,128,225,500];
if is_Train
    for index_feature = 1: 5 %length(arr_n_dimension_feature)

        LowLevelFeature = arr_LowLevelFeatures{index_feature};
        n_dimension_feature = arr_n_dimension_feature(index_feature);

        fprintf('\n Low-Level Features: %s',LowLevelFeature);
        fprintf('\n\t n_dimension_feature: %d',n_dimension_feature);


        filename_features  = [prefix_Filename_Features, LowLevelFeature,  suffix_Filename_Features];
        fprintf('\n Reading Low Level Features from %s...',filename_features);
        
        path_filename_features = fullfile(pathToLowLevelFeatures,filename_features);        
  
        [ listFeatures ] = NUS_WIDE.ReadLowLevelFeatures( path_filename_features, n_dimension_feature, m_items );
        fprintf('\n\t Precomputing kernel ...');
        if ~isa(listFeatures,'double');
             listFeatures =double(listFeatures);
        end
%         K  = listFeatures * listFeatures';
%         pre_instance_matrix = [(1:m_items)', K + eye(m_items)*realmin];   
%          
%         if ~isa(pre_instance_matrix,'double');
%             pre_instance_matrix =double(pre_instance_matrix);
%         end
        %--------------------------------------------------------------------------
        %  Label
        %--------------------------------------------------------------------------
        
        num_Concepts = length(listConcepts);
        

        fprintf('\n Training models of concepts');
        for ci=1:num_Concepts
            concept = listConcepts{ci};
            fprintf('\n\t Training concept %s', concept);

            filename_Label = ['Labels_' listConcepts{ci},suffix_Filename_Labels, '.txt'];
            path_filename_Label = fullfile(pathToTrainTestLabels,filename_Label);
            fid = fopen(path_filename_Label, 'rt');
            lines = textscan(fid, '%d');
            label_Matrix = lines{1};
            fclose(fid);
          %  fprintf('\n\t Number of items of concept %d: %s is %d', ci, concept, length(label_Matrix));
            assert(length(label_Matrix) == m_items );

            filename_model_svm = [concept, '.', LowLevelFeature, '.pre.linear.model.mat'];
            path_filename_model_svm = fullfile(pathToModelSVM, filename_model_svm);
            % deal with unbalanced data
        %     num_pos = sum(labels == k);
        %     num_neg = sum(labels ~= k);
            if exist(path_filename_model_svm,'file')    
                continue;
            end
            index_label_ci = find(label_Matrix ==1);
            index_label_not_ci = setdiff((1:m_items), index_label_ci);
            label_Matrix(index_label_not_ci)=-1;

            num_img_pos_per_class  = length( index_label_ci);
            num_img_neg_per_class  = m_items - num_img_pos_per_class;

            ratio_neg_pos          = num_img_neg_per_class/num_img_pos_per_class;

            %libsvmoption = sprintf('-t 0 -w1 %f -w-1 1 -b 1', ratio_neg_pos);
            libsvmoption = sprintf(' -w1 %f -w-1 1', ratio_neg_pos);
            fprintf('\n\t num_img_pos_per_class = %d',num_img_pos_per_class);
            fprintf('\n\t num_img_neg_per_class = %d',num_img_neg_per_class);
            fprintf('\n\t libsvmoption = %s',libsvmoption);
            
            %model = svmtrain(label_Matrix, pre_instance_matrix, libsvmoption);
            %model = svmtrain(double(label_Matrix), listFeatures, libsvmoption);
            model = train(double(label_Matrix), sparse(listFeatures), libsvmoption);
            if ~ isempty(model)
                fprintf('\n\t Saving model ...');
                save(path_filename_model_svm, 'model', 'libsvmoption', '-v7.3');
            end
        end
    
    end
end
%--------------------------------------------------------------------------
%  Tags
%--------------------------------------------------------------------------

path_filename_Tags = fullfile( pathToTags,filename_Tags);
fid = fopen(path_filename_Tags, 'rt');
tags_Matrix = fscanf(fid,'%d',  [num_Concepts, m_items]);
tags_Matrix  = tags_Matrix';
fclose(fid);
fprintf('\n\t Number of items of tags_Matrix %d x %d', size(tags_Matrix,1),size(tags_Matrix,2));

