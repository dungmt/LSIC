% -1fMVoG__ynNLb83 aerial building cityscape daytime grass outdoor park plant sky tree
function [ground_truth_matrix ]=  groundtruth_read(path_filename_groundtruth, map_concepts)
% generate a ground truth matrix

    fid = fopen(path_filename_groundtruth, 'rt');
    list_ground_truth_image_concepts ={};
    row_i=1;
    while true
        
        tline = fgets(fid);
        if ~ischar(tline)
            break;
        end
%         disp(tline);
        list_ground_truth_image_concepts{row_i} = textscan(tline,'%s') ;
        row_i=row_i+1;
    end

    fclose(fid);
    fprintf('\n Total number of images in file: %d images. \n', row_i-1);
    num_images = row_i-1;
    num_concepts = length(map_concepts);
    ground_truth_matrix=zeros(num_images,num_concepts);
    for i=1:num_images
        str_concepts_in_image = list_ground_truth_image_concepts{i}{1};
        num_concepts_in_image =length(str_concepts_in_image);
        fprintf('\n\t Process image %d',i);
        for j=2: num_concepts_in_image
            str_concept = str_concepts_in_image{j};
%             str_concept = str_concept{1};
            if map_concepts.isKey(str_concept)
                index_j = map_concepts(str_concept);
                ground_truth_matrix(i,index_j)=1;                
            end
            
        end
    end
    

end