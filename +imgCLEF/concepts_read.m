% # concept	type	sense	wn_offset(3.0)	wiki
% aerial	adj	1	01380267	http://en.wikipedia.org/wiki/Aerial_photography
function [list_concepts, map_concepts]=  concepts_read(path_devel_filename_concepts)

    fid = fopen(path_devel_filename_concepts, 'rt');
    tline = fgets(fid);
    
  
    list_concepts ={};
    row_i=1;
    keys={};
    
    while true
        
        tline = fgets(fid);
        if ~ischar(tline)
            break;
        end
%         disp(tline);
        list_concepts{row_i} = textscan(tline,'%s') ;
        keys(row_i) = list_concepts{row_i}{1}(1);
        row_i=row_i+1;
    end
    fclose(fid);
    values=[1:row_i-1];
    map_concepts = containers.Map(keys, values);
    
    fprintf('\n Total number of concepts in file: %d concepts. \n', row_i-1);


end