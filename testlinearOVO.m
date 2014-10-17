AddPathLib();
path_filename_train_selected_sparse = '/home/mmlab1/dungmt/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/Caltech256.train50p.sbow.mat';
path_filename_model = '/home/mmlab1/dungmt/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/ocvo.mat';
path_filename_test = '/home/mmlab1/dungmt/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/Caltech256.test25p.sbow.mat';

path_filename_test_res = '/home/mmlab1/dungmt/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/Caltech256.test25p.res.ovo.mat';
solver = 'liblinear';
if ~exist(path_filename_model, 'file')
    tic;
    fprintf('\n\t Loading training dataset ...');
    training = load(path_filename_train_selected_sparse)
    fprintf('finish !');

    toc %Elapsed time is 548.358387 seconds.

    libsvmoption = '';
    
    fprintf('\n Training model...');
    tic ;
    model = MyTrainOVO(solver,training.label_vector, training.instance_matrix ,libsvmoption);
    save(path_filename_model, 'model','-v7.3');
    toc
end
load(path_filename_model);
testing = load(path_filename_test);
testing_label_vector = testing.label_vector;
[predicted_label, accuracy, decision_values,vote_matrix] = MyPredictOVA(solver,testing.label_vector, testing.instance_matrix, model);
save(path_filename_test_res, 'predicted_label', 'accuracy', 'decision_values','vote_matrix','testing_label_vector','-v7.3');

