function [ output_args ] = ReduceDemension()
%Thu giam so chieu cua ma tran label_image theo SVD
%   Detailed explanation goes here
created_matrix_multiclass();
%utility.reSizeAndEncodeBase64_ImageCLEFT();
imagecleft();

end
% Ham tim ma tran label_image
% Truong hop multiclass: 1 anh thuoc 1 class
function created_matrix_multiclass()
     
    datasetName         = 'abc';
    pathToImagesDir     = '';
    pathToOutputDir     = '';
    
    Class = utility.getDirectoriesAtPath(pathToImagesDir );
    if isempty(Class)
            error('Not found class in directory %s\n',pathToImagesDir );
    end
        
    numClass = length(Class);

    matrixA = zeros(numClass,1);
    totalImage = 0;
    num_images_class =50;  % so anh toi da trong 1 class
    extstr = 'jpg|jpeg|gif|png|bmp';
    
    % tinh so anh trong tung class
    for ci = 1:numClass
            class_ci = Class{ci};
            fprintf('Computing features for class: %s (%d/%d)... \n',class_ci,ci,numClass);  
            pathToImagesDir_In      = fullfile(conf.pathToImagesDir,class_ci);
            ims = utility.getFileNamesAtPath(pathToImagesDir_In,extstr);
            num_images = length(ims);
            if num_images==0
                fprintf('No images in class %s \n',class_ci); 
            end            
            if num_images<num_images_class
                fprintf('Number of images in class %s is %d\n',class_ci,num_images); 
            end 
            num_images = min(num_images, num_images_class);
            % tao mang co num_images so 1
            matrixA(ci,1) = num_images;
            totalImage = totalImage + num_images;
     end
      % Tao ma tran cac gia tri 1
      matrixImgClass = zeros(totalImage, numClass);
      startRow = 0;
      for ci = 1:numClass
          num_images = matrixA(ci,1);       
          parfor ii=1: num_images
              matrixImgClass(startRow + ii ,ci ) =1; 
          end
          startRow = startRow + num_images;
      end   
      
      %warning('off','MATLAB:xlswrite:AddSheet');     
     % tenfile = ['C:\Users\Administrator\Dropbox\Code\temp_' sprintf('%d',numClass) '.mat']; 
     % tenfile = ['C:\Temp\data\temp_my_' sprintf('%d',numClass) '.mat'];      
     % save(tenfile, 'matrixImgClass');    
    
     % filename = ['C:\Temp\data\temp_my_' sprintf('%d',numClass) '_' conf.datasetName '.xls']; 
     % xlswrite(filename,matrixImgClass,1);          
     % xlswrite(filename,Class,2);
      
     % xuat ra file html
   
      nconcept=50;  % so concept can giam
      epsilon =0.25;
      while nconcept < numClass
          
          [U,S,V] =svds(matrixImgClass', nconcept);

          filename = fullfile(pathToOutputDir, [datasetName '_index_' sprintf('%d',num_images_class)  '_' sprintf('%d',nconcept) '.htm'] ); 

          fid = fopen(filename,'wt');
          fprintf(fid,'<h2>Dataset: %s </h2>\n', datasetName);
          fprintf(fid,'<h3>Number of class: %d </h3>\n', numClass);
          fprintf(fid,'<h3>Number of Concept: %s </h3>\n', sprintf('%d - epsilon=%f - number of images in class: %d',nconcept,epsilon, num_images_class));
          fprintf(fid,'<table border=1px >');
          for k=1: nconcept
              concept = sprintf('Concept %d: ', k);
              fprintf(fid,'<tr><td nowrap>');
              fprintf(fid,concept);
              fprintf(fid,'</td><td>');
              UU = U(:,k);
              UUABS = abs(UU);
              [B,IX] = sort(UUABS,'descend');
              for j=1: length(IX)
                  idx =IX(j);
                  if B(j,1) >= epsilon
                        fprintf(fid,'%s (%.4f) - ', Class{idx}, UU(idx,1));
                  else break;
                 end
              end
               fprintf(fid,'</td></tr>');
          end
          fprintf(fid,'</table>');

          fclose(fid);
          nconcept = nconcept + 10;
      end
%       xlswrite(filename,S,3);
%       xlswrite(filename,V,4);
%       xlswrite(filename,D,5);
       fprintf('DONE \n');
            
end
% Ham nay ap dung tren du lieu imagecleft
function imagecleft()
       Path ='D:\Dung Document\00_Nghiencuu\semantic\Dataset\imageclef2012\train_annotations\annotations';
       pathToEncodeDir_Out='D:\Dung Document\00_Nghiencuu\semantic\Dataset\imageclef2012\train_images\encode';
       pathToOutputDir  = 'C:\temp\imageclef2012';
       fileData         = 'C:\temp\imageclef2012\imageclef2012.mat'; % file nay chua matrixImgClass, ham nao tao ra ?
       % Tao file du lieu neu chua co
        if ~exist(fileData,'file')            
            imgList = utility.getFileNamesAtPath(Path,'txt');
            totalImage = length(imgList);          
            num_class = 94;
            Class = cell(num_class,1);
            IdxClass = zeros(num_class,1);            
            matrixImgClass = zeros(num_class,totalImage);
            
            for ii=1: totalImage
                filename = fullfile(Path, imgList{ii});
                fid = fopen(filename,'rt');
                lines = textscan(fid, '%s');
                lines = lines{1};
                fclose(fid);
                id_prev=1;
                for i = 1: length(lines)
                    str =lines{i};    
                    if length(str) <1 
                        break; 
                      % continue;
                    end                
                    if mod(i,2)~= 0 
                        id = str2num (str) +1 ;
                        matrixImgClass(id,ii)=1;
                        id_prev = id;
                    else
                        if isempty(find(IdxClass == id_prev))
                            Class{id_prev} = str;
                        end
                    end
                end     

            end    
             save(fileData,'matrixImgClass','Class', 'imgList');
        end
        
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
       tmp = load(fileData);
       matrixImgClass = tmp.matrixImgClass;       
       Class = tmp.Class;
       imgList = tmp.imgList;
       
       num_class = length(Class);      
       totalImage = length(imgList);
       str_encode = cell(totalImage,1);
       
       % Lay ten cac tap tin da duoc encode  base64
       for ii=1:totalImage
              modifiedStr = strrep(imgList{ii}, '.txt', '.jpg'); % tim va thay the chuoi
              file = [fullfile(pathToEncodeDir_Out, modifiedStr) '.txt'];     
              fid_out = fopen(file,'rt');
              str = textscan(fid_out, '%s');
              str = str{1};
              fclose(fid_out);   
              str_tmp =sprintf('%s %s',str{1}, str{2});
              str_encode{ii} =str_tmp ;             
              
       end
      nconcept=10;
      epsilon =0.25;
      top_rank=20;
      while nconcept < num_class
          
          [U,S,V] =svds(matrixImgClass, nconcept);

          filename = fullfile(pathToOutputDir,['V2_index_' sprintf('%d_%d_%d',num_class, nconcept,top_rank) '.htm']); 

          fid = fopen(filename, 'wt');
          fprintf(fid,'<h2>Dataset: imageclef2012 </h2>\n');
          fprintf(fid,'<h3>Number of Concept: %s </h3>\n',nconcept);
          fprintf(fid,'<h3>Number of class: %d </h3>\n', num_class);
%           fprintf(fid,'<h3>Number of Concept: %s </h3>\n', sprintf('%d - epsilon=%f - number of images in class: %d',nconcept,epsilon, num_images_class));
          fprintf(fid,'<table border=1px >');
          fprintf(fid,'<tr><td nowrap>Concepts</td>');
          for j=1: top_rank 
                  fprintf(fid,'<td>Top %d</td>',j);
          end
          fprintf(fid,'</tr>');
          %tinh tren ma tran V
          for k=1: nconcept
              concept = sprintf('Concept %d', k);
              fprintf(fid,'<tr><td nowrap>%s</td>',concept);
                
              UU = V(:,k);
              UUABS = abs(UU);
              [B,IX] = sort(UUABS,'descend');
              for j=1: top_rank %length(IX)
                  idx =IX(j);
%                  if B(j,1) >= epsilon
                        fprintf(fid,'<td>%s (%.4f) </td> ', str_encode{idx}, UU(idx,1));
%                   else break;
%                  end
              end              
 
              fprintf(fid,'</tr>\n');

          end
   
             %tinh tren ma tran U       
              
%           for k=1: nconcept
%               concept = sprintf('Concept %d: ', k);
%               fprintf(fid,'<tr><td nowrap>');
%               fprintf(fid,concept);
%               fprintf(fid,'</td><td>');
%               UU = U(:,k);
%               UUABS = abs(UU);
%               [B,IX] = sort(UUABS,'descend');
%               for j=1: length(IX)
%                   idx =IX(j);
%                   if B(j,1) >= epsilon
%                         fprintf(fid,'%s (%.4f) - ', Class{idx}, UU(idx,1));
%                   else break;
%                  end
%               end
%                fprintf(fid,'</td></tr>');
%          end

          fprintf(fid,'</table>');
          fclose(fid);
          
          nconcept = nconcept + 10;
      end
      fprintf('DONE \n');
        
end

