function [ conf ] = CreateValidationSet( conf )
%UNTITLED Summary of this function goes here
% Tao tap validation va test thanh 1 file ??
   fprintf('\n -----------------------------------------------');
   fprintf('\n CreateValidationSet: Creating validation dataset by combining classes into one file ...'); 
  
   filename_val_selected        = conf.val.filename;
   path_filename_val_selected   = conf.val.path_filename;         
   
   filename_pre_valval        = conf.val.filename_pre_valval;
   path_filename_pre_valval   = conf.val.path_filename_pre_valval;           
   fprintf('\n\t Information of validation set ...');
   fprintf('\n\t\t path_filename_val_selected: %s',path_filename_val_selected);
   fprintf('\n\t\t path_filename_pre_valval  : %s',path_filename_pre_valval);
   
%    if exist(path_filename_pre_valval,'file') && exist(path_filename_val_selected,'file')
   if exist(path_filename_val_selected,'file')
        fprintf('\n\t Creating validation set have finished (ready) !');
        return;
   end       
  
         
   if strcmp(conf.datasetName,'ILSVRC65')
   
           if exist(path_filename_val_selected,'file')
                fprintf('\n\t Creating validation set have finished (ready) !');
                return;
            end  
            output_dim=100000;
            
            val_gt_map = hedging.read_gt(fullfile(conf.dir.rootDir, 'code/ilsvrc65.val.gt'));
            val_mat_location  = fullfile(conf.dir.rootDir,'features/ilsvrc65.val.llc.mat');
            fprintf('\n Loading val\n');
            val_data = load(val_mat_location);
            val_labels = zeros(size(val_data.ids));
            fprintf('Getting labels...\n');
            for i = 1:numel(val_labels)
              val_labels(i) = conf.class2id_map.get(val_gt_map.get(val_data.ids{i}));
            end
           
             fprintf('\n\t Saving validation set into file: %s....',filename_val_selected);         
            instance_matrix = val_data.betas;
            label_vector =val_labels;
            save(path_filename_val_selected,'instance_matrix','label_vector','-v7.3');
            fprintf('finish !');
            return;
           
    else
        output_dim = conf.BOW.pooler.get_output_dim();
   end
    
   num_classes = conf.class.Num;
   Classes     = conf.class.Names;
 
   pathToIMDBDirVal    = conf.path.pathToIMDBDirVal;
   
   if strcmp( conf.datasetName,'ILSVRC2010')  
       pathToIMDBDirVal    = fullfile(conf.path.pathToFeaturesDir, 'val');
   end 
   
   if exist(path_filename_val_selected,'file')
       if ~ exist(path_filename_pre_valval,'file')
            fprintf('\n\t Loading validation set ...');
            load(path_filename_val_selected);
       end
   else
       fprintf('\n\t Creating validation set ...');
       if conf.IMDB.num_images_val>0
             num_images_val_selected = conf.IMDB.num_images_val;
             index_val_selected =1;
             fprintf('\n\t Allocating memories....');
             instance_matrix_tmp  = zeros(output_dim,50*num_classes);
             

             if strcmp( conf.datasetName,'ILSVRC2010')  
                num_images_val_selected_r = 1000;
                for ci = 1:50
                    val_id =ci;
                    filename_sbow_of_class =  ['val.',num2str(val_id,'%.4d'),'.sbow.mat'] ;
                    fprintf('\n\t\t Processing file: %s (%d/50)...',filename_sbow_of_class,ci);                   
                    path_filename_val = fullfile(pathToIMDBDirVal, filename_sbow_of_class );

                    if ~exist(path_filename_val,'file')
                        error('File %s not found ',path_filename_val);
                    end

                    fprintf('\n\t\t\t --> Loading file: %s...',filename_sbow_of_class);
                    tmpf = load(path_filename_val);            
                    instance_matrix_tmp(:,index_val_selected:index_val_selected+num_images_val_selected_r-1) = tmpf.setOfFeatures(:,:);
                    index_val_selected = index_val_selected+num_images_val_selected_r;
                end
                fileLabel=  fullfile(conf.dir.rootDir,'data/ILSVRC2010_validation_ground_truth.txt');
                label_vector_tmp = dlmread(fileLabel);
                num_gt_label_vector=length(label_vector_tmp);
                assert( num_gt_label_vector == 50*num_classes);
                
                % Chon loc theo so anh chon
                if num_images_val_selected <50
                    fprintf('\n\t Allocating memories....%d',num_images_val_selected);
                    instance_matrix  = zeros(output_dim,num_images_val_selected*num_classes);                      
                    label_vector = zeros(num_images_val_selected*num_classes,1); 
                    unique_label_vector_tmp = unique(label_vector_tmp);
                    length(unique_label_vector_tmp);
                    indx_start = 1;
                    for li=1:length(unique_label_vector_tmp);
                        index_selected = find(label_vector_tmp == unique_label_vector_tmp(li));
                        rand_indices = randperm(length(index_selected));
                        num_images_val_selected_r = min(num_images_val_selected, length(index_selected))
                        index_selected_final = index_selected( rand_indices(1:num_images_val_selected_r))
%                          whos
%                          pause      
                        
                        instance_matrix(:, indx_start: indx_start+ num_images_val_selected_r -1) =  instance_matrix_tmp(:, index_selected_final);     
                        label_vector(indx_start: indx_start+ num_images_val_selected_r -1,1) = unique_label_vector_tmp(li);
                        
                        indx_start = indx_start+ num_images_val_selected_r;
                  
                    end
                    
                else
                    instance_matrix = instance_matrix_tmp;     
                    label_vector = label_vector_tmp; 
                end
                clear instance_matrix_tmp;
                clear label_vector_tmp;
                
                
             elseif ( strcmp(conf.datasetName ,'Caltech256') || strcmp(conf.datasetName ,'SUN397')|| strcmp(conf.datasetName ,'ImageCLEF2012') )   
                
                 instance_matrix=[];
                 label_vector =[];
                 sum_num_images = 0;
                 for ci = 1:num_classes
                    class_ci = Classes{ci};            
                    fprintf('\n\t\t Processing class: %s (%d/%d)...',class_ci,ci,num_classes);
                    filename_sbow_of_class = [class_ci,'.sbow.mat'];
                    path_filename_val = fullfile(pathToIMDBDirVal, filename_sbow_of_class );

                    if ~exist(path_filename_val,'file')
                        error('File %s not found ',path_filename_val);
                    end

                    fprintf('\n\t\t\t --> Loading file: %s...',filename_sbow_of_class);
                    tmpf = load(path_filename_val);            

                    num_images = size(tmpf.instance_matrix,2); % kieu cell, moi cell: kich thuoc 32000 x 1 single
                    sum_num_images = sum_num_images + num_images;
                    instance_matrix = [instance_matrix, tmpf.instance_matrix];     
                    label_vector = [label_vector, tmpf.label_vector];  
                 end                 
             end
            fprintf('\n\t Saving validation set into file: %s....',filename_val_selected);         
%             instance_matrix = val_instance_matrix_selected;  % dim x n
%             label_vector = val_label_vector_selected;
            save(path_filename_val_selected,'instance_matrix','label_vector','-v7.3');
            fprintf('finish !');
        end
   end 
    
   fprintf('\n\t Precomputing kernel between validation and validation data ...');
   %  K = size(label_vector,2);
   K = length(label_vector);
   pre_valval_matrix  =[(1:K)', instance_matrix' * instance_matrix ]; % dim x n
        %=horzcat((1:K)', instance_matrix' * instance_matrix );
   fprintf('\n\t Saving into file: %s....',filename_pre_valval);
   val_label_vector = label_vector;
   save(path_filename_pre_valval,'pre_valval_matrix','val_label_vector','-v7.3');
   fprintf('finish !');
   
end

