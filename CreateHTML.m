function CreateHTML(conf)

       PathOutHtml_Root = '/usr/local/apache2/htdocs';
       PathOutHtml_Dataset  = fullfile(PathOutHtml_Root, conf.datasetName);
       MakeDirectory(PathOutHtml_Dataset);
       PathOutHtml_Val  = fullfile(PathOutHtml_Dataset, 'val');
       PathOutHtml_Test  = fullfile(PathOutHtml_Dataset, 'test');
       MakeDirectory(PathOutHtml_Val);
       MakeDirectory(PathOutHtml_Test);
       
         %% -------------------------------------------------------------------
               
         
         
    fprintf('\n\t Create html page for Testing ...');
    num_Classes = conf.class.Num;
    assert(num_Classes>0);
    arr_Step        = conf.pseudoclas.arr_Step;    
    num_Arr_Step = length(arr_Step);
    assert(num_Arr_Step>0);

    % Load file ket qua
    num_pseudo_classes  = arr_Step(num_Arr_Step);
    assert(num_pseudo_classes>0);
    path_filename_score_matrix = conf.svr.path_filename_score_matrix ;
    
    fprintf('\n\t Loading score matrix from file: %s', path_filename_score_matrix);
    load(path_filename_score_matrix); %, 'inv_ScoreMatrix', 'label_vector','-v7.3');
    fprintf('finish !');
            
     %  
    totalImage = size(inv_ScoreMatrix,2);
    assert(num_pseudo_classes==size(inv_ScoreMatrix,1));
    
    str_encode = cell(totalImage,1);

    % Lay ten cac tap tin da duoc encode  base64
    pathToEncodeDir_Out='/data/Dataset/LSVRC/2010/images/encode/test';
    extstr = '.txt';
    ims = utility.getFileNamesAtPath(pathToEncodeDir_Out, extstr);
    assert(length(ims) == totalImage);
    
    for ii=1:totalImage          
          file = fullfile(pathToEncodeDir_Out, ims{ii});     
          fprintf('\n Reading encode string from %s ....',file);
          fid_out = fopen(file,'rt');
          str = textscan(fid_out, '%s', 'delimiter','\n', 'bufsize',50000);
          str_encode{ii}  = str{1};
          fclose(fid_out);   
%           str = textread(file, '%s', 'delimiter','\n', 'bufsize',50000);
          
%           str_tmp =sprintf('%s %s',str{1}, str{2});
%           str_encode{ii} =str_tmp ;      
          fprintf('.');
    end

   top_rank =150;
   num_img_per_row = 10;
   
   for pci=1: 300 % num_pseudo_classes       
      fprintf('\n Proccessing class %d: ....',pci)
       filename = fullfile(PathOutHtml_Test,sprintf('%d.htm',pci) ); 
       fid = fopen(filename, 'wt');
       fprintf(fid,'<table border=1px >');
       VV_T = inv_ScoreMatrix(pci,:);
       size(VV_T)
      
       VVABS = abs(VV_T);
      [B,IX] = sort(VVABS,'descend');
   
      icol=1;
     
      for j=1: top_rank %length(IX)
          if (icol==1)
              fprintf(fid,'<tr>');              
          end
          
          icol =  icol+1;
          
          idx =IX(j);
          s_encode = str_encode{idx};
          class_label = conf.class.Names{label_vector(idx)};
         class_words =conf.class.Words{label_vector(idx)};
          class_words = class_words(1: min(17, length(class_words)));
          % fprintf(fid,'<td>%s <br>(%.4f) </td> ', s_encode{:}, VV_T(idx));
          fprintf(fid,'<td align=center>%s <br>(%.4f)<br>(%s)<br>(%s) </td> ', s_encode{:}, VV_T(idx), class_label,class_words);
          
          if icol>num_img_per_row
              fprintf(fid,'</tr>');
              icol = 1;
          end
      end
      fprintf(fid,'</table>');
      fclose(fid);
   end
         
      fprintf('DONE \n');
        
end

