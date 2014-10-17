function imdb = generateImdbFromFolders_256(pathloc)
%GENERATEIMDBFROMFOLDERS Summary of this function goes here
%   Detailed explanation goes here

    imdb.images.id = [];
    imdb.images.set = uint8([]);
    imdb.images.name = {};
    imdb.images.class = [];
    imdb.images.size = zeros(2,0) ;
    imdb.dir = getTopLevelDir(pathloc);
    imdb.classes.name = [];
    imdb.classes.imageIds = {};
    imdb.sets = struct();

    % lay cac thu muc test,val, train --> sap thu tu lai: train, val,..
%     sets = getDirectoriesAtPath(pathloc);
%     for i = 1:length(sets)
%         if strcmpi(sets{i},'train')
%             if i ~= 1
%                 tmp = sets{1};
%                 sets{1} = sets{i};
%                 sets{i} = tmp;
%             end
%         end
%     end
%     for i = 1:length(sets)
%         if strcmpi(sets{i},'val')
%             if i ~= 2
%                 tmp = sets{2};
%                 sets{2} = sets{i};
%                 sets{i} = tmp;
%             end
%         end
%     end
    
    sets={'train', 'val','test'};
    
    % store set names in imdb
    for si = 1:length(sets)
        imdb.sets.(upper(sets{si})) = uint8(si);
    end
    
    imid = 1;
    
   % for si = 1:length(sets)
        % get list of classes from subdirs in set folder
       %% classes = getDirectoriesAtPath(fullfile(pathloc, sets{si}));
        classes = getDirectoriesAtPath(pathloc);
        % check classes are same for all sets
        if isempty(imdb.classes.name)
            imdb.classes.name = classes;
            imdb.classes.imageIds = cell(1, length(imdb.classes.name));
        else
            if ~isempty(setxor(classes, imdb.classes.name))
                error('Classes must be same for all datasets');
            end
        end
        % enter each directory in turn, adding images to the imdb
        ratio_img_dev =  0.5;
        ratio_img_train =  0.25;
        ratio_img_val =  ratio_img_dev - ratio_img_train;
        % ratio_img_test =  1.0 - ratio_img_dev;
        
        
        for ci = 1:length(classes)
            ims = getImagesAtPath(fullfile(pathloc, classes{ci}));
            % moi tap ta chon ra bao nhieu anh lam test, train
            num_img_select = length(ims); 
            num_img_train =  uint32(num_img_select *ratio_img_train);
            num_img_val   =  uint32(num_img_select *ratio_img_val);
            num_img_test  = num_img_select - (num_img_train +num_img_val); 
            
            %ims = vl_colsubset(ims,uint32(num_img_select)); 
            % chon random
            rand_indices = randperm(num_img_select);  % returns a row vector containing a random permutation of the integers from 1 to n inclusive.
                                                    % viewed as index of class_k_indices
  
            fprintf('\nProcessing class %s have %d iamges...',classes{ci},num_img_select);
           if num_img_train>0
                rand_indices_tmp = rand_indices(1:num_img_train);
                ims_train = ims(rand_indices_tmp);  
                rand_indices = setdiff(rand_indices,rand_indices_tmp);
                si=1;
                for ii = 1:length(ims_train)
                    % load in image to get size
                    im = imread(fullfile(pathloc, classes{ci}, ims_train{ii}));
                    imsize = size(im)';
                    imsize = imsize(1:2);
                    % store image in imdb
                    imdb.images.name = [imdb.images.name {fullfile(classes{ci}, ims_train{ii})}];
                    imdb.images.id = [imdb.images.id imid];
                    imdb.images.set = [imdb.images.set uint8(si)];
                    imdb.images.class = [imdb.images.class ci];
                    imdb.images.size = [imdb.images.size imsize];

                    imdb.classes.imageIds{ci} = [imdb.classes.imageIds{ci} imid];

                    imid = imid+1;
                end
            end
            if num_img_val>0
               % ims_val = vl_colsubset(ims,uint32(num_img_val));  
                rand_indices_tmp = rand_indices(1:num_img_val);
                ims_val = ims(rand_indices_tmp);  
                rand_indices = setdiff(rand_indices,rand_indices_tmp);
                
                si=2;
                for ii = 1:length(ims_val)
                    % load in image to get size
                    im = imread(fullfile(pathloc, classes{ci}, ims_val{ii}));
                    imsize = size(im)';
                    imsize = imsize(1:2);
                    % store image in imdb
                    imdb.images.name = [imdb.images.name {fullfile(classes{ci}, ims_val{ii})}];
                    imdb.images.id = [imdb.images.id imid];
                    imdb.images.set = [imdb.images.set uint8(si)];
                    imdb.images.class = [imdb.images.class ci];
                    imdb.images.size = [imdb.images.size imsize];

                    imdb.classes.imageIds{ci} = [imdb.classes.imageIds{ci} imid];

                    imid = imid+1;
                end
            end
            if num_img_test>0
                %ims_test = vl_colsubset(ims,uint32(num_img_test));  
                rand_indices_tmp = rand_indices(1:end);
                ims_test = ims(rand_indices_tmp);  
                 
              %  ims = setdiff(rand_indices,rand_indices_tmp);
                
                 si=3;
                for ii = 1:length(ims_test)
                    % load in image to get size
                    im = imread(fullfile(pathloc, classes{ci}, ims_test{ii}));
                    imsize = size(im)';
                    imsize = imsize(1:2);
                    % store image in imdb
                    imdb.images.name = [imdb.images.name {fullfile(classes{ci}, ims_test{ii})}];
                    imdb.images.id = [imdb.images.id imid];
                    imdb.images.set = [imdb.images.set uint8(si)];
                    imdb.images.class = [imdb.images.class ci];
                    imdb.images.size = [imdb.images.size imsize];

                    imdb.classes.imageIds{ci} = [imdb.classes.imageIds{ci} imid];

                    imid = imid+1;
                end
            end
            
            
        end
   % end % end for si
   
end
%% Ham nay se doc tat cac cac thuc muc trong pathloc
function dirs = getDirectoriesAtPath(pathloc)
    dirlisting_all = dir(pathloc);
    % remove '.' and '..' items from directory listing
    dirlisting_all(arrayfun(@(x)(strcmp(x.name,'.')),dirlisting_all)) = [];
    dirlisting_all(arrayfun(@(x)(strcmp(x.name,'..')),dirlisting_all)) = []; 
    %remove all non-directory entries
    dirlisting = dirlisting_all(arrayfun(@(x)(x.isdir),dirlisting_all));
    dirs = arrayfun(@(x)(x.name),dirlisting,'UniformOutput',false);
end

function ims = getImagesAtPath(pathloc)
    dirlisting_all = dir(pathloc);
    % remove '.' and '..' items from directory listing
    dirlisting_all(arrayfun(@(x)(strcmp(x.name,'.')),dirlisting_all)) = [];
    dirlisting_all(arrayfun(@(x)(strcmp(x.name,'..')),dirlisting_all)) = []; 
    %remove all non-image entries
    extstr = 'jpg|jpeg|gif|png|bmp';
    dirlisting = arrayfun(@(x)~isempty(regexpi(x.name,extstr)),dirlisting_all);
    ims = arrayfun(@(x)(x.name),dirlisting_all(dirlisting),'UniformOutput',false);
end

function dirname = getTopLevelDir(pathloc)
    filesepids = strfind(pathloc,filesep);
    if filesepids(end) == length(pathloc)
        pathloc = pathloc(1:end-1);
        filesepids = filesepids(1:end-1);
    end
    dirname = pathloc(filesepids(end)+1:end);
end

