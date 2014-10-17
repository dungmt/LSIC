

function [ground_truth_matrix ]=  groundtruth_read_2012(path_filename_data,path_to_test_concepts,path_to_test_images)
% generate a ground truth matrix

%load concepts
    load (path_filename_data);
    num_images = 10000;
    num_concepts = numClass;
    
    
    extstr = 'mat';
    ims = utility.getFileNamesAtPath(path_to_test_images,extstr);
    assert(length(ims)==num_images);
    list_id_images = cell(num_images,1);
    for i=1: num_images
        list_id_images{i} = strrep(ims{i},'.feat.mat','');
    end
    
    save('/data/Dataset/imageCLEF/imageclef2012/data/list_id_images.mat','list_id_images');
    ground_truth_matrix=zeros(num_images,num_concepts);
    for i=1:num_concepts
       fprintf('\n Concept: %s', Names{i});
       file_name_concept = [Names{i},'.txt'];
       path_file_name_concept = fullfile(path_to_test_concepts, file_name_concept);
       %Doc cac anh trong concept       
       imgs = utility.readFileByLines(path_file_name_concept);            
       num_img_in_concept = length(imgs) ;            
       if num_img_in_concept <1  
          error('Not found class in file %s\n',path_file_name_concept);
       end
       fprintf(' (%d images)', num_img_in_concept);
       
       for j=1: length(imgs)           
            %index_img = find(ismember(imgs{j},list_id_images))
            index_img = find(strncmp(list_id_images,imgs{j},length(imgs{j})));
%             pause
           % if index_img<1
            if isempty(index_img)
                error('Image %s not in list_id_images',imgs{j});
            else
                ground_truth_matrix(index_img,i)=1;    
            end
       end
       
    end
    

end