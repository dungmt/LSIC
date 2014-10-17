%
%addpath(fullfile(pwd, 'libsvm-3.18\matlab'));
addpath('/data/Dataset/KLTN/Visual/libsvm-3.18/matlab');
NUM_Con = 81;
NUM_TrainIm = 161789;
NUM_TestIm = 107859;
%NUM_TrainIm = 1000;
%NUM_TestIm = 1000;


% -- database
    fprintf(' \n -- Loading Database -- \n');
imdb=fullfile(pwd,'data', sprintf('imdb.mat'));
if exist(imdb,'file')
    prms = load('data/imdb.mat'); % IMDB file
	else
    lib.gendb(pwd);
	prms = load('data/imdb.mat'); % IMDB file
end
clear imdb;
fprintf(' \n -- Loaded -- \n');
%------------- CORR features
fprintf('\n ------------- CORR features ---------- \n');
%train 
n_dimension_feature = 144;

path_model = fullfile(pwd,'data/CORR_train_classifier.mat');
   if exist(path_model,'file')
	fprintf('\n -- Loading Classifier --\n');
        load(path_model);
   else
        fprintf('\n -- Training Classifier --\n');
        %%train_vec = importdata(fullfile(pwd,'Low_Level_Features/Train_Normalized_CORR.dat'));
		path_filename_features = fullfile(pwd,'Low_Level_Features/Train_Normalized_CORR.dat');
		
		  [ train_vec ] = lib.NUS_WIDE.ReadLowLevelFeatures( path_filename_features, n_dimension_feature, NUM_TrainIm );
        train_vec = train_vec(1:NUM_TrainIm,:);
        train_vec=train_vec';
        label_train = lib.genLB(prms.imdb);
        model = lib.train(train_vec,label_train);
        if ~ isempty(model)
            fprintf('\n\t Saving model ... \n');
            save(path_model, 'model', '-v7.3');
        end
   end

   %test
   fprintf('\n -- Testing Classifier --\n');
   path_results = fullfile(pwd,'data/CORR_test_results.mat');
   if ~exist(path_results,'file')
	   test_vec = importdata(fullfile(pwd,'Low_Level_Features/Test_Normalized_CORR.dat'));
	   test_vec = test_vec(1:NUM_TestIm,:);
	   test_vec=test_vec';
	   scoremat = lib.test(model,test_vec);
	   res = lib.baseline.genBaseline(scoremat);
	   results=struct;
	   results.res=res;
	   results.scoremat=scoremat;
	 %  save(path_results, 'results', '-v7.3');
	   % filer
	   scoremat = lib.filter.genfil(scoremat,10);
	   baseline = lib.baseline.genBaseline(scoremat);
	   save(path_results, 'results','scoremat','baseline', '-v7.3');
	   fprintf('\n --Complete Test --\n');
   end
   %------------- Tags features
fprintf('\n ------------- Tags features ---------- \n');
%train 
path_model = fullfile(pwd,'data/Tag_train_classifier.mat');
   if exist(path_model,'file')
	fprintf('\n -- Loading Classifier --\n');
        load(path_model);
   else
        fprintf('\n -- Training Classifier --\n');
		%%train_vec = importdata(fullfile(pwd,'NUS_WID_Tags/Train_Tags1k.dat'));
        train_vec = importdata(fullfile(pwd,'NUS_WID_Tags/Train_Tags81.txt'));
       %% train_vec = train_vec(1:NUM_TrainIm,:);
        train_vec=train_vec';
        label_train = lib.genLB(prms.imdb);
		whos
		pause
        model = lib.train(train_vec,label_train);
        if ~ isempty(model)
            fprintf('\n\t Saving model ... \n');
            save(path_model, 'model', '-v7.3');
        end
   end

   %test
   fprintf('\n -- Testing Classifier --\n');
   path_results = fullfile(pwd,'data/Tag_test_results.mat');
   if ~exist(path_results,'file')
	   test_vec = importdata(fullfile(pwd,'NUS_WID_Tags/Test_Tags81.txt'));
	   test_vec = test_vec(1:NUM_TestIm,:);
	   test_vec=test_vec';
	   scoremat = lib.test(model,test_vec);
	   res = lib.baseline.genBaseline(scoremat);
	   results=struct;
	   results.res=res;
	   results.scoremat=scoremat;
	   save(path_results, 'results', '-v7.3');
		 % filer
	   scoremat = lib.filter.genfil(scoremat,10);
	   baseline = lib.baseline.genBaseline(scoremat);
	   save(path_results, 'results','scoremat','baseline', '-v7.3');
	   fprintf('\n --Complete Test --\n');
   end

 