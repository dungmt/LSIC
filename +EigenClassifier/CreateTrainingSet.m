function [ conf ] = CreateTrainingSet( conf )
%UNTITLED Summary of this function goes here
% Combine training dataset into one file !
   fprintf('\n -----------------------------------------------');
   fprintf('\n Creating training dataset by combining classes into one file ...');
 
   filename_train_selected	= conf.train.filename;
   path_filename_train_selected   = conf.train.path_filename;     
   
   filename_pre_traintrain        = conf.train.filename_pre_traintrain;
   path_filename_pre_traintrain   = conf.train.path_filename_pre_traintrain;      
   
   fprintf('\n\t path_filename_train: %s',path_filename_train_selected);
   if exist(path_filename_train_selected,'file')
       fprintf('\n\t Creating training dataset have finished (ready) !');           
       
       if conf.svm.preCompKernel
                
           fprintf('\n\t Information of training dataset ...');
           fprintf('\n\t\t path_filename_train_selected: %s',path_filename_train_selected);
           fprintf('\n\t\t path_filename_pre_traintrain  : %s',path_filename_pre_traintrain);

           if exist(path_filename_pre_traintrain,'file') 
                fprintf('\n\t Precomputing train_train have finished (ready) !');
                return;
           end       
       else
           return ;
       end
   end
    if strcmp(conf.datasetName,'ILSVRC65')
   
            output_dim=100000;
    else
        output_dim = conf.BOW.pooler.get_output_dim();
    end
%     output_dim
%    pause;
   num_images_train   = conf.IMDB.num_images_train;
   
   num_classes = conf.class.Num;
   Classes     = conf.class.Names;
 
   pathToIMDBDirTrain    = conf.path.pathToIMDBDirTrain;
  
   
   fprintf('\n\t conf.path.pathToIMDBDirTrain: %s', pathToIMDBDirTrain);
   fprintf('\n\t conf.IMDB.num_images_train: %d',conf.IMDB.num_images_train);
   
   if exist(path_filename_train_selected,'file')
       if conf.svm.preCompKernel && ~ exist(path_filename_pre_traintrain,'file')
            fprintf('\n\t Loading training set ...');
            load(path_filename_train_selected);
       end
   else
        fprintf('\n\t Combining training dataset ...');
        if num_images_train >0.0 && num_images_train < 1.0
             if strcmp(conf.datasetName,'ILSVRC2010') 
                error('CreateTrainingSet: ILSVRC2010');
             elseif ( strcmp(conf.datasetName ,'Caltech256') || strcmp(conf.datasetName ,'SUN397')|| strcmp(conf.datasetName ,'ImageCLEF2012') )
                 instance_matrix=[];
                 label_vector =[];
                 sum_num_images = 0;
                 for ci = 1:num_classes
                    class_ci = Classes{ci};            
                    fprintf('\n\t\t Processing class: %s (%d/%d)...',class_ci,ci,num_classes);
                    filename_sbow_of_class = [class_ci,'.sbow.mat'];
                    path_filename_train = fullfile(pathToIMDBDirTrain, filename_sbow_of_class );

                    if ~exist(path_filename_train,'file')
                        error('File %s not found ',path_filename_train);
                    end

                    fprintf('\n\t\t\t --> Loading file: %s...',filename_sbow_of_class);
                    tmpf = load(path_filename_train);            

                    num_images = size(tmpf.instance_matrix,2); % kieu cell, moi cell: kich thuoc 32000 x 1 single
                    sum_num_images = sum_num_images + num_images;
                    instance_matrix = [instance_matrix, tmpf.instance_matrix];     
                    label_vector = [label_vector, tmpf.label_vector];  
                 end
             end

        elseif num_images_train>1
             num_images_train_selected = num_images_train;
             index_train_selected =1;
             fprintf('\n\t Allocating memories....');
             instance_matrix  = zeros(output_dim,num_images_train_selected*num_classes);
             label_vector     = zeros(num_images_train_selected*num_classes,1);
             for ci = 1:num_classes
                    class_ci = Classes{ci};            
                    fprintf('\n\t\t Processing class: %s (%d/%d)...',class_ci,ci,num_classes);
                    filename_sbow_of_class = [class_ci,'.sbow.mat'];
                    path_filename_train = fullfile(pathToIMDBDirTrain, filename_sbow_of_class );

                    if ~exist(path_filename_train,'file')
                        error('File %s not found ',path_filename_train);
                    end

                    fprintf('\n\t\t\t --> Loading file: %s...',filename_sbow_of_class);
                    tmpf = load(path_filename_train);            
                     
                    num_images = size(tmpf.instance_matrix,2);
                    
                    fprintf('\n\t\t\t --> Selecting data...');
                    num_images_train_selected_r = min(num_images_train_selected,num_images);
                    if num_images_train == num_images_train_selected       
                        instance_matrix(:, index_train_selected: index_train_selected+ num_images_train_selected_r - 1) = tmpf.instance_matrix;  
                   else
                        rand_indices = randperm(num_images);
                        rand_indices_train_selected   = rand_indices(1:num_images_train_selected_r); 
                        instance_matrix(:, index_train_selected: index_train_selected+ num_images_train_selected_r - 1) = tmpf.instance_matrix(:,rand_indices_train_selected); 
                    end
                    clear tmpf;

                    label_vector(index_train_selected: index_train_selected+num_images_train_selected_r-1,1) = ci;

                    index_train_selected = index_train_selected+num_images_train_selected_r;                 
             end
                     
        elseif num_images_train==0
             fprintf('\n\t Training dataset is selected from all ');   
        end
        if num_images_train~=0
            fprintf('\n\t Saving training set into file: %s....',filename_train_selected);         
    %         instance_matrix = instance_matrix;  % dim x n
    %         label_vector = label_vector;
            save(path_filename_train_selected,'instance_matrix','label_vector','-v7.3');
        end
   end 
    %% -----------------------------------------------------------------
    if num_images_train~=0
        if conf.svm.preCompKernel && ~ exist(path_filename_pre_traintrain,'file')
            fprintf('\n\t Precomputing kernel between training and training data ...');
            %  K = size(label_vector,2);
            K = length(label_vector);

            pre_traintrain_matrix  =[(1:K)', instance_matrix' * instance_matrix ]; % dim x n
            %=horzcat((1:K)', instance_matrix' * instance_matrix );
            fprintf('\n\t Saving into file: %s....',filename_pre_traintrain);
            train_label_vector = label_vector;
            save(path_filename_pre_traintrain,'pre_traintrain_matrix','train_label_vector','-v7.3');
        end
    end
end

