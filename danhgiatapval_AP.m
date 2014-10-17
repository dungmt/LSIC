AddPathLib();
if isunix
             file_data = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/data/meta.mat';
             pathToIMDBDir = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb';
             pathToFeaturesDir ='/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/features/phow_LLCEncoder_SPMPooler_10000';
             fileLabel=   '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/data/ILSVRC2010_validation_ground_truth.txt';
             gtruth_test_file = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/data/ILSVRC2010_test_ground_truth.txt';
             pathToFile_Val = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb/ILSVRC2010.val.mat';
             pathToSave = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb';
             pathToTestFeatures = '/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/features/phow_LLCEncoder_SPMPooler_10000/test';
             
    load ('/net/per610a/export/das09f/satoh-lab/dungmt/DataSet/LSVRC/2010/imdb/ILSVRC2010.libsvm.pre.prob.val.mat');
    %scores_matrix      1000x50000            400000000  double 
 else
            file_data = 'F:\Dataset\LSVRC\2010\data\meta.mat';
            fileLabel=   'F:\Dataset\LSVRC\2010\data\ILSVRC2010_validation_ground_truth.txt';
            pathToIMDBDir = 'F:\Dataset\LSVRC\2010\imdb';
            pathToFeaturesDir = 'F:\Dataset\LSVRC\2010\features\phow_LLCEncoder_SPMPooler_10000';
            pathToFile_Val = 'F:\Dataset\LSVRC\2010\imdb\ILSVRC2010.val.mat'
            pathToSave = 'F:\Dataset\LSVRC\2010\imdb';
            pathToTestFeatures = 'f:\Dataset\LSVRC\2010\features\phow_LLCEncoder_SPMPooler_10000\test';
            gtruth_test_file = 'F:\Dataset\LSVRC\2010\data\ILSVRC2010_test_ground_truth.txt';

            
    load ('F:\Dataset\LSVRC\2010\imdb\ILSVRC2010.libsvm.pre.prob.val.mat');
    %scores_matrix      1000x50000            400000000  double 
 
end

     
     
	fprintf('\n\t Loading information about ILSVRD2010 dataset....');    
    K= 1000;
    
    load (file_data);
    
    WNIDs = { synsets.WNID}; % lay gia tri cua thuoc tinh num_train_images trong tat ca phan tu
    WNIDs = WNIDs(1:K); % chon ra K phan tu dau tien 1:K
    ILSVRC_IDs = [ synsets.ILSVRC2010_ID ];
    ILSVRC_IDs = ILSVRC_IDs(1:K);
      

    
    
    
gt_val_label_vector = dlmread(fileLabel);
[val_label_vector, idx] = sort(gt_val_label_vector);

   AP = zeros(1000,1);
    
    Precision = zeros(1000,1);
   VL_AP = zeros(1000,1);
   VL_AUC = zeros(1000,1);
   VL_AP_INTERP_11 = zeros(1000,1);

    MAP = 0;
    
     for i=1:K
            synset = WNIDs(i);
            synset = synset{1};
            
            pathToSynsetDir = fullfile(pathToSave,synset);
            if ~exist(pathToSynsetDir,'dir')
                 error('Directory %s is empty !',pathToSynsetDir);
            end	
            
           
            
            predicted_label_vector =  zeros(50000,1);
            scores=  zeros(50000,1);
            
           
            filename_result_test = sprintf('%s.libsvm.pre.val.mat',synset);
            path_filename_result_test = fullfile(pathToSynsetDir,filename_result_test);
            if ~exist(path_filename_result_test,'file')
                 error('File %s is not found !',path_filename_result_test);
            end	
            fprintf('\n\t\t Loading file %3d: %s ...',i, filename_result_test);
            load(path_filename_result_test); % save(filename_libsvm_test, 'predicted_label', 'accuracy', 'decision_values','test_label_vector','-v7.3');
            predicted_label_vector  = predicted_label;     
            scores = decision_values;
            fprintf('finish !');                
            
            label_vector = -ones(50000,1);
            sortidx = find(val_label_vector==ILSVRC_IDs(i));
            label_vector(sortidx) = 1;
            
           
            for ii=1:50000
                if (label_vector(ii)==1 && predicted_label_vector(ii) == label_vector(ii) )
                     Precision(i) =  Precision(i) +1;
               
                end
            end
           Precision(i)
            
            [rc, pr, info] = vl_pr(label_vector, scores) ;
            disp(info.auc) ;
            disp(info.ap) ;
            disp(info.ap_interp_11) ;
            
            VL_AP(i) = info.ap;             
            VL_AUC(i) = info.auc;
            VL_AP_INTERP_11(i) = info.ap_interp_11;
            
            % danh gia AP
            % get indices of current class sorted in descending order of confidence
            fprintf('\n\t Computing precision/recall...\n');
           
            tp = predicted_label_vector(sortidx)>0;
            fp = predicted_label_vector(sortidx)<0;

            fp = cumsum(fp);
            tp = cumsum(tp);
            rec = tp/sum(predicted_label_vector>0);
            prec = tp./(fp+tp);
            dataset = '';
            fprintf('\n\t Computing APs...');
           % fprintf('rec =%f,  prec=%f\n', rec,prec);
            AP(i) = featpipem.eval.VOCdevkit.VOCap(dataset, rec, prec);     
            fprintf('\n\t AP(i)=%f...', AP(i));
            MAP = MAP +AP(i);
            
            
     end
    
    % ghi ket qua
    fprintf('\n Writing result ...');
    filename_kqua_AP = 'ILSVRC2010.libsvm.pre.val.AP.mat';
    path_filename_kqua_AP = fullfile(  pathToSave, filename_kqua_AP);
    save(   path_filename_kqua_AP, 'AP','MAP','Precision','VL_AUC','VL_AP','VL_AP_INTERP_11', '-v7.3');
    
    fprintf('finish !');
   
    fprintf('\nDONE!\n');