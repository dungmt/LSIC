function CreateHTMLCal_Test(conf)

       PathOutHtml_Root = '/usr/local/apache2/htdocs';
       PathOutHtml_Dataset  = fullfile(PathOutHtml_Root, conf.datasetName);
       MakeDirectory(PathOutHtml_Dataset);
       PathOutHtml_Val  = fullfile(PathOutHtml_Dataset, 'val');
       PathOutHtml_Test  = fullfile(PathOutHtml_Dataset, 'test');
       MakeDirectory(PathOutHtml_Val);
       MakeDirectory(PathOutHtml_Test);
       
         %% -------------------------------------------------------------------
               
         
         
    fprintf('\n\t Create html page for Validation ...');
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
%     % Load U,S,V
%     path_filename_decomposed = conf.pseudoclas.path_filename_decomposed;
%     if ~exist(path_filename_decomposed,'file')
%          error('\n\t File %s is not found !',path_filename_decomposed);
%     end
% 
%     fprintf('\n\t Loading (U,S,V) file: %s...', path_filename_decomposed);
%     load(path_filename_decomposed); %, 'U', 'S','V','-v7.3');
%     fprintf('finish !');
        
    
    
     %  
%      inv_ScoreMatrix = V';
     num_pseudo_classes
     size(inv_ScoreMatrix)
  
    totalImage = size(inv_ScoreMatrix,2);
    assert(num_pseudo_classes==size(inv_ScoreMatrix,1));
    
    

    % Lay ten cac tap tin da duoc encode  base64
    pathToEncodeDir_Out='/data/Dataset/256_ObjectCategories/encode';
    extstr = '.txt';
    
%     assert(length(ims) == totalImage);
    
    path_filename_val_selected = '/data/Dataset/256_ObjectCategories/experiments/train50p.val25p.test25p/binclassifiers/Caltech256.test25p.idx.sbow.mat';
    load(path_filename_val_selected, 'Idx','IdxCi');
    Classes     = conf.class.Names;
    
   top_rank =150;
   num_img_per_row = 10;
   
    num_classes=256;
    str_encode = {};
    for ci=1:num_classes
        class_ci = Classes{ci};
        fprintf('\n Processing class: %s (%d/%d)...',class_ci,ci,num_classes);                    
                 
        pathToEncodeDir_Out_ci = fullfile(pathToEncodeDir_Out, class_ci); 
        ims = utility.getFileNamesAtPath(pathToEncodeDir_Out_ci, extstr);
        str_encode_ci = cell(length(ims),1);
        for ii=1:  length(ims)       
              file = fullfile(pathToEncodeDir_Out_ci, ims{ii});     
              fprintf('\n Reading encode string from %s ....',file);
              fid_out = fopen(file,'rt');
              str = textscan(fid_out, '%s', 'delimiter','\n', 'bufsize',50000);
              str_encode_ci{ii}  = str{1};
              fclose(fid_out);   
            fprintf('.');
        end
        str_encode{ci} = str_encode_ci;
%        size(str_encode_ci)
%         size(str_encode)
%         pause;
    end
   size(str_encode)
    for pci=1: num_pseudo_classes       
           fprintf('\n\t Proccessing class %d: ....',pci)
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
              
              class_ci = IdxCi(idx);
              str_encode_ci = str_encode{class_ci};
              class_label = conf.class.Names{class_ci};
              s_encode = str_encode_ci{Idx(idx)};
              fprintf(fid,'<td align=center>%s <br>(%.4f)<br>(%s) </td> ', s_encode{:}, VV_T(idx), class_label);
              
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

