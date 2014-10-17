function reSizeAndEncodeBase64Cal()
% Resize kich thuoc anh va ma hoa theo code base64
%        pathToImagesDir_In ='/data/Dataset/LSVRC/2010/images/val';       
%        pathToImagesDir_Out='/data/Dataset/LSVRC/2010/images/small/val';
%        pathToEncodeDir_Out='/data/Dataset/LSVRC/2010/images/encode/val';
       pathToImagesDir_In ='/data/Dataset/256_ObjectCategories/256_ObjectCategories';       
       pathToImagesDir_Out='/data/Dataset/256_ObjectCategories/small';
       pathToEncodeDir_Out='/data/Dataset/256_ObjectCategories/encode';       
       MakeDirectory(pathToImagesDir_Out);
       MakeDirectory(pathToEncodeDir_Out);
       
        ClassNames = utility.getDirectoriesAtPath(pathToImagesDir_In );
        numClass = length(ClassNames) -1 ;
        if numClass <1  
            error('Not found class in directory %s\n',pathToImagesDir_In);
        end 
        extstr = 'jpg|jpeg|gif|png|bmp';
%       extstr = '.JPEG';
    for ci=1:numClass
       fprintf('\n Processing class %s ...',ClassNames{ci});    
       
       pathToImagesDir_In_Class = fullfile(pathToImagesDir_In, ClassNames{ci});
       pathToImagesDir_Out_Class = fullfile(pathToImagesDir_Out, ClassNames{ci});
       pathToEncodeDir_Out_Class = fullfile(pathToEncodeDir_Out, ClassNames{ci});
       
       MakeDirectory(pathToImagesDir_Out_Class);
       MakeDirectory(pathToEncodeDir_Out_Class);
       ims = utility.getFileNamesAtPath(pathToImagesDir_In_Class, extstr);
       num_images = length(ims);
            if num_images==0
                fprintf('No images in class %s \n',class_ci); 
            end

            fprintf('\n%d images:',num_images);             
            
            for ii = 1:num_images               
                   fprintf('.'); 
                   im = imread(fullfile(pathToImagesDir_In_Class, ims{ii}));
                   im = imresize(im, [90 120]);
                   file = fullfile(pathToImagesDir_Out_Class, ims{ii});
                   imwrite(im,file);    
                   
                    fid = fopen(file,'rb');
                    bytes = fread(fid);
                    fclose(fid);
                    encoder = org.apache.commons.codec.binary.Base64;
                    base64string = char(encoder.encode(bytes))';        
                    s = sprintf('<img src="data:image/jpg;base64,%s">',base64string);
                    
                    
                    file = [fullfile(pathToEncodeDir_Out_Class, ims{ii}) '.txt'];                     
                    fid_out = fopen(file,'wt');
                    fprintf(fid_out,'%s',s);
                    fclose(fid_out);                    
                   
            end       
    end
end

