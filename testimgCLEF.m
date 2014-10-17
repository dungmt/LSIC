AddPathLib();
path_root = '/data/Dataset/imageCLEF/v2013/';
path_feats_visual = fullfile(path_root,'feats_visual');
path_feats_textual = fullfile(path_root,'feats_textual');
path_devel = fullfile(path_root,'webupv13_devel_lists');

filename_feats_visual = 'webupv13_devel_visual_gist.feat';
path_filename_feats_visual = fullfile(path_feats_visual,filename_feats_visual);

devel_filename_concepts     = 'devel_concepts.txt';
devel_filename_groundtruth  = 'devel_gnd.txt';

path_devel_filename_concepts    = fullfile(path_devel,devel_filename_concepts);
path_devel_filename_groundtruth = fullfile(path_devel,devel_filename_groundtruth);

filename_models = 'models.mat';
path_filename_models = fullfile(path_root,filename_models);

[list_concepts, map_concepts]=  imgCLEF.concepts_read(path_devel_filename_concepts);
% pause
[ground_truth_matrix ]=  imgCLEF.groundtruth_read(path_devel_filename_groundtruth, map_concepts);
% pause
[matrix_feat ]=   imgCLEF.feats_visual_read(path_filename_feats_visual);

 if ~issparse(matrix_feat)
      matrix_feat = sparse(matrix_feat);
 end
                
num_concepts = length(list_concepts);
num_images = size(matrix_feat,1);
model = cell(num_concepts,1);

% pause
if ~exist(path_filename_models,'file')
    for concept_i = 1:num_concepts
        fprintf('\n\t Training mode %d ', concept_i);
        index_concept_i  = find(ground_truth_matrix(:,concept_i));
        label_vector = -ones(num_images,1);
        label_vector(index_concept_i)=1;
        libsvmoption = sprintf(' -w1 %f -w-1 1', num_images/length(index_concept_i))
        model{concept_i} = train(label_vector, matrix_feat, libsvmoption);
    %     pause
    end

    save(path_filename_models, 'model', '-v7.3');
else
    load(path_filename_models);
end
