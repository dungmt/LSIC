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






path_filename_train_selected_sparse = '/data/Dataset/LSVRC/2010/experiments/train300.val30.test150/binclassifiers/ILSVRC2010.train300.sbow.sparse.mat';
tic;
fprintf('\n\t Loading training dataset ...');
training = load(path_filename_train_selected_sparse)
fprintf('finish !');

toc %Elapsed time is 548.358387 seconds.
%31% MEM

label_ci=1;
svm_training_label_vector = 2 * (training.label_vector==label_ci) - 1 ;  

% 94.4% MEM --> Matlab restart

%svm_training_label_vector = svm_training_label_vector(100:200100,:);
%training.instance_matrix = training.instance_matrix(100:200100,:);
%64% MEM --> Matlab restart

svm_training_label_vector = svm_training_label_vector(1:150150,:);
training.instance_matrix = training.instance_matrix(1:150150,:);
% %  tic ;
% >> model = train(svm_training_label_vector, training.instance_matrix ,libsvmoption);
% .*
% optimization finished, #iter = 13
% Objective value = -600.658052
% nSV = 5309
% >> toc
% Elapsed time is 549.245437 seconds.

% svm_training_label_vector = svm_training_label_vector(151:150150,:);
% instance_matrix = training.instance_matrix(151:150150,:);


libsvmoption = ' -w1 999 -w-1 1';
fprintf('\n Training model...');
tic ;
model = train(svm_training_label_vector, training.instance_matrix ,libsvmoption);
toc

% 80% MEM
% Attempt to restart MATLAB? [y or n]>>




