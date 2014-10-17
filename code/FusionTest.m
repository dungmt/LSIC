%
%addpath(fullfile(pwd, 'libsvm-3.18\matlab'));
addpath('/data/Dataset/KLTN/Visual/libsvm-3.18/matlab');

NUM_Con = 81;
 NUM_TrainIm = 161789;
 NUM_TestIm = 107859;
%NUM_TrainIm = 1000;
%NUM_TestIm = 1000;
NUM_Val = 10000;

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
%--- prepare baseline data-------------------------------------------------------------

%------------- CH features
val_CH  = fullfile(pwd,'data/CH_val_test_results.mat');
if exist(val_CH,'file')
	fprintf('\n ------------- CH features ---------- \n');
else
fprintf('\n ------------- CH features ---------- \n');
%train 
path_model = fullfile(pwd,'data/CH_val_train_classifier.mat');
   if exist(path_model,'file')
	fprintf('\n -- Loading Classifier --\n');
        load(path_model);
   else
        fprintf('\n -- Training Classifier --\n');
        train_vec = importdata(fullfile(pwd,'Low_Level_Features/Train_Normalized_CH.dat'));
        train_vec = train_vec(1:NUM_TrainIm-NUM_Val,:);
        train_vec=train_vec';
        label_train = lib.fusion.genLB(prms.imdb);
        model = lib.train(train_vec,label_train);
        if ~ isempty(model)
            fprintf('\n\t Saving model ... \n');
            save(path_model, 'model', '-v7.3');
        end
   end

   %test
   fprintf('\n -- Testing Classifier --\n');
   path_results = fullfile(pwd,'data/CH_val_test_results.mat');
   test_vec = importdata(fullfile(pwd,'Low_Level_Features/Train_Normalized_CH.dat'));
   test_vec = test_vec(NUM_TrainIm-NUM_Val:NUM_TrainIm,:);
   test_vec=test_vec';
   scoremat = lib.test(model,test_vec);
   res = lib.fusion.genBaseline(scoremat);
   results=struct;
   results.res=res;
   results.scoremat=scoremat;
   save(path_results, 'results', '-v7.3');
   fprintf('\n --Complete Test --\n');
end
   %------------- Tags features
val_Tag  = fullfile(pwd,'data/Tag_val_test_results.mat');
if exist(val_Tag,'file')
	fprintf('\n ------------- Tags features ---------- \n');
else
fprintf('\n ------------- Tags features ---------- \n');
%train 
path_model = fullfile(pwd,'data/Tag_val_train_classifier.mat');
   if exist(path_model,'file')
	fprintf('\n -- Loading Classifier --\n');
        load(path_model);
   else
        fprintf('\n -- Training Classifier --\n');
        train_vec = importdata(fullfile(pwd,'NUS_WID_Tags/Train_Tags1k.dat'));
        train_vec = train_vec(1:NUM_TrainIm-NUM_Val,:);
        train_vec=train_vec';
        label_train = lib.fusion.genLB(prms.imdb);
        model = lib.train(train_vec,label_train);
        if ~ isempty(model)
            fprintf('\n\t Saving model ... \n');
            save(path_model, 'model', '-v7.3');
        end
   end

   %test
   fprintf('\n -- Testing Classifier --\n');
   path_results = fullfile(pwd,'data/Tag_val_test_results.mat');
   test_vec = importdata(fullfile(pwd,'NUS_WID_Tags/Train_Tags1k.dat'));
   test_vec = test_vec(NUM_TrainIm-NUM_Val:NUM_TrainIm,:);
   test_vec=test_vec';
   scoremat = lib.test(model,test_vec);
   res = lib.fusion.genBaseline(scoremat);
   results=struct;
   results.res=res;
   results.scoremat=scoremat;
   save(path_results, 'results', '-v7.3');
   save(path_results, 'results', '-v7.3');
   fprintf('\n --Complete Test --\n');
end
fprintf('\n ------------- fusion features ---------- \n');
   %--- gen fusion map
   if exist('data/FusionMap.mat','file')
        load('data/FusionMap.mat');
   else
   clearvars;
   input ={};
   input{1} = load(fullfile(pwd,'data/CH_val_test_results.mat'));   
   input{2} = load(fullfile(pwd,'data/Tag_val_test_results.mat'));
   lib.fusion.genFusionMap(input);
   end
   %--- fusion features
   clearvars;
   path_results = fullfile(pwd,'data/Fusion_CH_test_results.mat');
   input ={};
   input{1} = load(fullfile(pwd,'data/CH_test_results.mat'));   
   input{2} = load(fullfile(pwd,'data/Tag_test_results.mat'));
   scoremat = lib.fusion.CC(input);
   res = lib.baseline.genBaseline(scoremat);
   results=struct;
   results.res=res;
   results.scoremat=scoremat;
   scoremat = lib.filter.genfil(scoremat,10);
   baseline = lib.baseline.genBaseline(scoremat);
   
   save(path_results,'results', 'input','scoremat','baseline', '-v7.3');
   
   
   

 