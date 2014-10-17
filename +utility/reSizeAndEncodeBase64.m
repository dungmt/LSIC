function reSizeAndEncodeBase64()
% Resize kich thuoc anh va ma hoa theo code base64
       pathToImagesDir_In ='/data/Dataset/LSVRC/2010/images/test';       
       pathToImagesDir_Out='/data/Dataset/LSVRC/2010/images/small/test';
       pathToEncodeDir_Out='/data/Dataset/LSVRC/2010/images/encode/test';
       
       MakeDirectory(pathToImagesDir_Out);
       MakeDirectory(pathToEncodeDir_Out);
        
%        extstr = 'jpg|jpeg|gif|png|bmp';
       extstr = '.JPEG';
       ims = utility.getFileNamesAtPath(pathToImagesDir_In, extstr);
       num_images = length(ims);
            if num_images==0
                fprintf('No images in class %s \n',class_ci); 
            end

            fprintf('\n%d images:',num_images);             
            
            for ii = 1:num_images               
                   fprintf('.'); 
                   im = imread(fullfile(pathToImagesDir_In, ims{ii}));
                   im = imresize(im, [90 120]);
                   file = fullfile(pathToImagesDir_Out, ims{ii});
                   imwrite(im,file);    
                   
                    fid = fopen(file,'rb');
                    bytes = fread(fid);
                    fclose(fid);
                    encoder = org.apache.commons.codec.binary.Base64;
                    base64string = char(encoder.encode(bytes))';        
                    s = sprintf('<img src="data:image/jpg;base64,%s">',base64string);
                    
                    
                    file = [fullfile(pathToEncodeDir_Out, ims{ii}) '.txt'];                     
                    fid_out = fopen(file,'wt');
                    fprintf(fid_out,'%s',s);
                    fclose(fid_out);                    
                   
            end       
    end

