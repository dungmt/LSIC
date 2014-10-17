function [ conf ] = CreateTestingSet( conf )
%UNTITLED Summary of this function goes here
% Tao tap validation va test thanh 1 file ??

    if strcmp(conf.datasetName,'ILSVRC2010')     
        return;
    end
   fprintf('\n Creating testing set ...');
   filename_test_selected	= conf.test.filename;
   path_filename_test_selected   = fullfile(conf.experiment.pathToBinaryClassifer,    filename_test_selected);           
   if exist(path_filename_test_selected,'file')
        fprintf('finish (ready) !');
        return;
   end
         
   output_dim = conf.BOW.pooler.get_output_dim;
   num_images_test   = conf.IMDB.num_images_test;
   num_classes = conf.class.Num;
   Classes     = conf.class.Names;
 
   pathToIMDBDirTest    = conf.path.pathToIMDBDirTest;
   
   
   
    if num_images_test>0
         num_images_test_selected = conf.IMDB.num_images_test;
         index_test_selected =1;
         test_instance_matrix_selected  = zeros(output_dim,num_images_test_selected*num_classes);
         test_label_vector_selected = zeros(1,num_images_test_selected*num_classes);
         
         for ci = 1:num_classes
           
            class_ci = Classes{ci};            
            fprintf('\n\t\t Processing class: %s (%d/%d)...',class_ci,ci,num_classes);
            filename_sbow_of_class = [class_ci,'.sbow.mat'];
            path_filename_test = fullfile(pathToIMDBDirTest, filename_sbow_of_class );
            
            if ~exist(path_filename_test,'file')
                error('Features of class %s not found ',class_ci);
            end
            
            fprintf('\n\t\t\t --> Loading file: %s...',filename_sbow_of_class);
            tmpf = load(path_filename_test);            
           
            num_images = size(tmpf.instance_matrix,2); % kieu cell, moi cell: kich thuoc 32000 x 1 single
            fprintf('\n\t\t\t --> Selecting data...');
            num_images_test_selected_r = min(num_images_test_selected,num_images);
            if num_images_test == num_images_test_selected               
                for k=1: num_images_test_selected_r
                    test_instance_matrix_selected(:, index_test_selected + k - 1) = tmpf.instance_matrix(:,k);  
                end
            else
                rand_indices = randperm(num_images);
                rand_indices_test_selected   = rand_indices(1:num_images_test_selected_r);  
                for k= 1 :  num_images_test_selected_r
                    test_instance_matrix_selected(:, index_test_selected + k - 1) = tmpf.instance_matrix(:,rand_indices_test_selected(k));  
                end
            end
            
             
            test_label_vector_selected(1,index_test_selected: index_test_selected+num_images_test_selected_r-1) = ci;
            
            index_test_selected = index_test_selected+num_images_test_selected_r;
         end
         
        fprintf('\n\t Saving testing set into file: %s....',filename_test_selected);
         
         instance_matrix = test_instance_matrix_selected;
         label_vector = test_label_vector_selected;
         save(path_filename_test_selected,'instance_matrix','label_vector','-v7.3');

        
     end

end

