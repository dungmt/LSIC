Idx = zeros(30000,1);
 fileLabel=  '/data/Dataset/LSVRC/2010/data/ILSVRC2010_validation_ground_truth.txt';
 label_vector_tmp = dlmread(fileLabel);
for i=1:30000
    instance_matrix_i = val.instance_matrix(:, i);
    label_vector_i = val.label_vector(i);    
    idx_found = find(label_vector_tmp ==label_vector_i);
    
    for j=1:length(idx_found)
        if  isequal(instance_matrix_tmp(:,idx_found(j)), instance_matrix_i)   
            Idx(i)= idx_found(j);
            break;
        end
    end    
end
path_filename_val_selected = '/data/Dataset/LSVRC/2010/experiments/train100.val30.test150/binclassifiers/ILSVRC2010.val30.idx.sbow.mat';
save(path_filename_val_selected,'instance_matrix','label_vector','Idx','-v7.3');

% ----

pathVal ='/data/Dataset/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/Caltech256.val25p.sbow.mat';
load (pathVal);
% instance_matrix      32000x7483            1915648000  double              
% label_vector             1x7483                 59864  double        
pathToFeature = '/data/Dataset/256_ObjectCategories/features/phow_LLCEncoder_SPMPooler_4000'; 
ClassNames = utility.getDirectoriesAtPath('/data/Dataset/256_ObjectCategories/256_ObjectCategories');
Idx = zeros(length(label_vector),1);
IdxCi = zeros(length(label_vector),1);

i=1;
for ci=1: 256
    ind_ci = find(label_vector==ci);
    % load file data ung voi ci
    class_ci = ClassNames{ci};         
    filename_sbow_of_class = [class_ci,'.mat'];
    path_filename_feature = fullfile(pathToFeature, filename_sbow_of_class );    
    tmpf = load(path_filename_feature); 
    num_images = length(tmpf.setOfFeatures); % kieu cell, moi cell: kich thuoc 32000 x 1 single
    for ii=1: length(ind_ci)
        instance_matrix_ii = instance_matrix(:, ind_ci(ii));
        for j=1:num_images
            if  isequal(tmpf.setOfFeatures{j}, instance_matrix_ii)   
                Idx(i)=j;
                IdxCi(i) = ci;
                i=i+1;
                break;
            end
        end    
    end
    
end
pathValIdx ='/data/Dataset/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/Caltech256.val25p.idx.sbow.mat';
save(pathValIdx,'instance_matrix','label_vector','Idx','IdxCi','-v7.3');
