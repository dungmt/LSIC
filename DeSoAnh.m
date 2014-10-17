% Dem so luong anh trong thu muc
function NumImgsArr = DeSoAnh(conf)
    NumImgsArr = zeros(conf.class.Num,1);
    pathToImagesDir = conf.path.pathToImagesDir;
    extstr = 'jpg|jpeg|gif|png|bmp';
    for ci=1: conf.class.Num
                class_ci = conf.class.Names{ci};
                pathToImagesDir_In      = fullfile(pathToImagesDir,class_ci);

                ims = utility.getFileNamesAtPath(pathToImagesDir_In,extstr);
                num_images = length(ims);
                if num_images==0
                    fprintf('No images in class %s \n',class_ci); 
                end
                NumImgsArr(ci) = num_images;
    end
    file_data = fullfile(conf.dir.rootDir, 'data/thongtin.mat');
    ClassNames =     conf.class.Names;    
    save(file_data,'ClassNames','NumImgsArr');
end