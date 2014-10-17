function [ conf ] = MergeTrainVal( conf )

fprintf('\n Merging Training and Validation dataset ....');
    num_images_train = conf.IMDB.num_images_train; 
    num_images_test  = conf.IMDB.num_images_test;
    num_images_val   = conf.IMDB.num_images_val;
    if( num_images_train <0 ||  num_images_val<0)
        error('\n Can not merge !!!');
    end
    num_img_neg_per_class_selected = conf.svm.num_img_neg_per_class_selected;
    num_img_neg_per_class_selected = num_img_neg_per_class_selected + (num_images_val*num_img_neg_per_class_selected)/num_images_train;
    conf.svm.num_img_neg_per_class_selected = ceil(num_img_neg_per_class_selected);
    
    conf.svm.num_img_pos_per_class = num_images_train + num_images_val;
    
    conf.svm.num_img_neg_per_class  = conf.svm.num_img_neg_per_class_selected*(conf.class.Num-1) ;
    conf.svm.ratio_neg_pos          = conf.svm.num_img_neg_per_class/conf.svm.num_img_pos_per_class;
    conf.svm.libsvmoption = sprintf('-t 4 -w1 %f -w-1 1 -b 1', conf.svm.ratio_neg_pos);
    
     if conf.svm.select_nagative_random
         str_bla = '.rand';
         
    else
         str_bla = sprintf('.bla%d',conf.svm.num_img_neg_per_class_selected); 
        
    end
    trainDir = [ sprintf('train%dval%d',  num_images_train,num_images_val), str_bla];
    testDir =  sprintf('test%d',conf.IMDB.num_images_test);
    
    conf.experiment.pathToBinaryClassiferTrains  = fullfile(conf.experiment.pathToBinaryClassifer, trainDir);
    conf.experiment.pathToRegressionTrains  = fullfile(conf.experiment.pathToRegression, trainDir);  
    conf.experiment.pathToRegressionTrainsTest    = fullfile(conf.experiment.pathToRegressionTrains, testDir);
    
    MakeDirectory(conf.experiment.pathToBinaryClassiferTrains);
    MakeDirectory(conf.experiment.pathToRegressionTrains);
    MakeDirectory(conf.experiment.pathToRegressionTrainsTest);
    
    pathToBinaryClassiferTrains = conf.experiment.pathToBinaryClassiferTrains;
        
    
   output_dim = conf.BOW.pooler.get_output_dim;
   num_classes = conf.class.Num;
   Classes     = conf.class.Names;
 
   pathToIMDBDirTrain  = conf.path.pathToIMDBDirTrain;
   pathToIMDBDirVal    = conf.path.pathToIMDBDirVal;
   pathToIMDBDirTrainVal = conf.path.pathToIMDBDirTrainVal;
   
   conf.path.pathToIMDBDirTrain = conf.path.pathToIMDBDirTrainVal;
   %%%%%%%%%%%%%%%
   str_kernel = ['.', conf.svm.preCompKernelType];
    
    if conf.svm.preCompKernel
         str_pre = ['.pre', str_kernel];
    else
         str_pre = '';
    end
    
    str_val = sprintf('.train%dval%d',  num_images_train,num_images_val);
    conf.val.str_val = str_val;

    conf.val.filename	= [conf.datasetName,str_val,'.sbow.mat'];
    conf.val.filename_pre_valval	= [conf.datasetName,str_pre,str_val,str_val,'.mat'];
    conf.val.path_filename_pre_valval   = fullfile(conf.experiment.pathToBinaryClassifer,    conf.val.filename_pre_valval);
    conf.val.path_filename   = fullfile(conf.experiment.pathToBinaryClassifer,    conf.val.filename);
    str_test = sprintf('.test%d',   conf.IMDB.num_images_test);
    conf.test.str_test = str_test;
    conf.testval.filename  = [conf.datasetName,str_test,str_val,'.mat'];
    conf.testval.path_filename  = fullfile(conf.experiment.pathToBinaryClassifer, conf.testval.filename);

    conf.val.filename_score_matrix	= [conf.datasetName, '.',conf.svm.solver,str_pre,'.prob', conf.val.str_val,'.scores.mat'];
    conf.val.num_img_per_class = num_images_train + num_images_val;
    conf.val.filename_evaluation    = [conf.datasetName, '.',conf.svm.solver,str_pre,'.prob', conf.val.str_val,'.eval.mat'];   
    
    if exist(conf.val.path_filename ,'file') && exist(conf.val.path_filename_pre_valval ,'file')
        fprintf('finish (ready) !'); 
        return;
    end
    
     
        
   
   %%%
  
   val_instance_matrix  = zeros(output_dim,(num_images_train+num_images_val)*num_classes);
   val_label_vector = zeros(1,(num_images_train+num_images_val)*num_classes);
   index_val_instance_matrix = 1;
   
   for ci = 1:num_classes
        class_ci = Classes{ci};            
        fprintf('\n\t\t Processing class: %s (%d/%d)...',class_ci,ci,num_classes);
        filename_sbow_of_class = [class_ci,'.sbow.mat'];
        path_filename_train = fullfile(pathToIMDBDirTrain, filename_sbow_of_class );
        path_filename_val = fullfile(pathToIMDBDirVal, filename_sbow_of_class );
        path_filename_trainval = fullfile(pathToIMDBDirTrainVal, filename_sbow_of_class );
        
        if exist(path_filename_trainval,'file') 
            trainval = load(path_filename_trainval);
            num_images_trainvalfile= size(trainval.instance_matrix,2); % kieu cell, moi cell: kich thuoc 32000 x 1 single
            for k=1: num_images_trainvalfile              
                val_instance_matrix(:, index_val_instance_matrix + k-1) =trainval.instance_matrix(:,k);  
            end
            val_label_vector(1, index_val_instance_matrix:index_val_instance_matrix + num_images_trainvalfile - 1) = ci;
            index_val_instance_matrix = index_val_instance_matrix + num_images_trainvalfile;
            
            continue;
        end
        
        if ~exist(path_filename_train,'file') || ~exist(path_filename_val,'file')
            error('Features of class %s not found ',class_ci);
        end
        fprintf('\n\t\t\t --> Loading file: %s...',filename_sbow_of_class);
        valfile = load(path_filename_val);       
        trainfile = load(path_filename_train);

        num_images_valfile= size(valfile.instance_matrix,2); % kieu cell, moi cell: kich thuoc 32000 x 1 single
        num_images_trainfile= size(trainfile.instance_matrix,2); % kieu cell, moi cell: kich thuoc 32000 x 1 single
        dim_feat = size(valfile.instance_matrix,1);
        assert(num_images_valfile==num_images_val);
        assert(num_images_trainfile==num_images_train);
        assert(dim_feat == output_dim);
        
        instance_matrix = zeros(dim_feat, num_images_valfile+ num_images_trainfile);    
        label_vector = ones(1, num_images_valfile+ num_images_trainfile)*ci; 
        val_label_vector(1, index_val_instance_matrix:index_val_instance_matrix+num_images_valfile+ num_images_trainfile - 1) = ci;
        
        fprintf('\n\t\t\t --> Merge data...');
        
        for k=1: num_images_trainfile
            instance_matrix(:, k) = trainfile.instance_matrix(:,k);  
            val_instance_matrix(:, index_val_instance_matrix + k-1) =trainfile.instance_matrix(:,k);  
        end
        index_val_instance_matrix = index_val_instance_matrix + num_images_trainfile;
        for k=1: num_images_valfile
            instance_matrix(:, num_images_trainfile+k-1) = valfile.instance_matrix(:,k);  
            val_instance_matrix(:, index_val_instance_matrix + k-1) =valfile.instance_matrix(:,k); 
        end
        index_val_instance_matrix = index_val_instance_matrix + num_images_valfile;
        
        fprintf('\n\t\t\t --> Saving data into file %s...',path_filename_trainval);
        save(path_filename_trainval, 'instance_matrix', 'label_vector', '-v7.3' );
   end
   %%%%%%%%%%%%%%%%%%
   fprintf('\n Creating validation set ...');
       
    if ~exist(conf.val.path_filename ,'file')
        filename_val_new	= conf.val.filename;
        path_filename_val_new = conf.val.path_filename;
        fprintf('\n\t Saving validation set into file: %s....',filename_val_new);         
        instance_matrix = val_instance_matrix;  % dim x n
        label_vector = val_label_vector;
        save(path_filename_val_new,'instance_matrix','label_vector','-v7.3');
    end
    if ~exist(conf.val.path_filename_pre_valval ,'file')
        filename_pre_valval        = conf.val.filename_pre_valval;
        path_filename_pre_valval   = conf.val.path_filename_pre_valval;           


        fprintf('\n\t Precomputing kernel between validation and validation data ...');
        K = size(label_vector,2);
        pre_valval_matrix  =[(1:K)', instance_matrix' * instance_matrix ]; % dim x n
        %=horzcat((1:K)', instance_matrix' * instance_matrix );
        fprintf('\n\t Saving into file: %s....',filename_pre_valval);
        val_label_vector = label_vector;
        save(path_filename_pre_valval,'pre_valval_matrix','val_label_vector','-v7.3');
    end
end

