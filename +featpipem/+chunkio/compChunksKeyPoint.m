function chunk_files = compChunksKeyPoint(prms, featextr)
%COMPCHUNKSIMDB Compute feature chunks, save to disk and return filenames
%   Given a set of test parameters 'prms', computes the features for all
%   image sets in a given imdb and saves to chunk files
%
%   chunk_files - output filenames. Is an instance of containers.map, with
%                 one keyed value for each of 'train', 'test' and (if it
%                 exists) 'val', each containing a cell array of chunk
%                 filenames

% default parameters ------------------------------------------------------
% imdb
% paths.dataset
% paths.codes
% paths.compdata
% paths.results
% experiment.name
% experiment.dataset
% experiment.codes_suffix
% chunkio.chunk_size
% chunkio.num_workers
% 

% output format of chunk filenames
% placeholders: codes_suffix targetset chunkstartidx
CHUNK_FNAME = '%s_%s_chunk%d.mat';

% initialize output map
chunk_files = containers.Map();
extstr = 'JPEG|jpg|jpeg|gif|png|bmp';
pathToKeyPointsDir = prms.BOW.path.pathToKeyPointsDir;
pathToImagesDir = prms.path.pathToImagesDir;
        
% iterate over sets in IMDB
%for targetsets = {'train', 'val', 'test'}
for targetsets = { 'val', 'test'}
    
    targetset = targetsets{1};
    switch targetset
        case 'train'
           % ids = find(prms.imdb.images.set == prms.imdb.sets.TRAIN);
           pathToImagesDir_In      = fullfile(pathToImagesDir,'train');           
           
        case 'val'
           pathToImagesDir_In      = fullfile(pathToImagesDir,'val');
%             if isfield(prms.imdb.sets, 'VAL')
%                 ids = find(prms.imdb.images.set == prms.imdb.sets.VAL);
%             else
%                 disp('Skipping validation set (deson''t exist in IMDB)');
%                 continue;
%             end
        case 'test'
            %ids = find(prms.imdb.images.set == prms.imdb.sets.TEST);
            pathToImagesDir_In      = fullfile(pathToImagesDir,'test');
    end
    ims = utility.getFileNamesAtPath(pathToImagesDir_In,extstr);
    
    % calculate chunk start indexes
    % chunk_starts_ = 1:prms.chunkio.chunk_size:length(ids);
    chunk_size = prms.chunkio.chunk_size;
    num_workers = prms.chunkio.num_workers;
    num_images = length(ims);
   
    chunk_starts_ = 1:prms.chunkio.chunk_size:length(ims);
    if num_images < chunk_size
        num_workers =1;
    end
    % allocate chunks to workers
    chunk_starts = cell(num_workers);
    for w = 1:num_workers
        chunk_starts{w} = chunk_starts_(w:prms.chunkio.num_workers:end);
    end    
    % initialize storage for chunk filenames in parfor
    chunk_files_by_worker = cell(num_workers, 1);
    
    % compute chunks
    % for w = 1:num_workers
    parfor w = 1:prms.chunkio.num_workers
        featextr2 = featextr;
        % iterate through chunks assigned to current worker
        for c = 1:length(chunk_starts{w})
            fprintf('Processing chunk starting at %d (worker: %d round: %d)...\n',...
                chunk_starts{w}(c), w, c);
           % path = fullfile(prms.paths.codes, sprintf(CHUNK_FNAME, prms.experiment.codes_suffix, targetset, chunk_starts{w}(c)));
            path = fullfile(pathToKeyPointsDir, [targetset,'.',num2str( chunk_starts{w}(c),'%.4d'),'.kps.mat'] );
            if exist(path,'file')
                fprintf('Chunkfile exists. Skipping...\n');
                continue;
            end
            % this_chunk_size = min(chunk_size, length(ids)-chunk_starts{w}(c)+1);
            this_chunk_size = min(chunk_size, length(ims)-chunk_starts{w}(c)+1);
            chunk = zeros(encpooler.get_output_dim, this_chunk_size, 'single');
%             setOfFeats = cell(this_chunk_size,1);
%             setOfFrames = cell(this_chunk_size,1);
%             setOfImgSize  = cell(this_chunk_size,1);
          
            % iterate through images in current chunk
            for i = chunk_starts{w}(c):chunk_starts{w}(c)+this_chunk_size-1
               % filename_img = prms.imdb.images.name{ids(i)};
                filename_img = fullfile(pathToImagesDir_In, ims{i});
                
                fprintf('  computing features for image: %s....\n', ims{i}); 
                im = imread(filename_img);
                im = featpipem.utility.standardizeImageImgNet(im);
                [feats, frames] = featextr2.compute(im);
                
%                 cur_code = encpooler.compute(size(im), feats, frames);
%                 
%                 if any(isnan(cur_code))
%                     error('NaNs in the code of chunk %d (worker: %d round: %d)!', i, w, c);
%                 end
                
                %chunk(:,i-chunk_starts{w}(c)+1) = cur_code;
                setOfFeats{i-chunk_starts{w}(c)+1}   = feats;
                setOfFrames{i-chunk_starts{w}(c)+1}  = frames;
                setOfImgSize{i-chunk_starts{w}(c)+1}    = size(im);
                
               % break;
            end
            index = chunk_starts{w}(c):chunk_starts{w}(c)+this_chunk_size-1;
            %save_chunk_(path, chunk, index);
            save_chunk_imgnet(path, setOfFeats,setOfFrames,setOfImgSize, index);
            % append filename to output
           % chunk_files_by_worker{w}{end+1} = path;
            chunk_files_by_worker{w} = path;
        end
    end
    
    % copy chunk filenames over to output map
    chunk_files(targetset) = {};
    for w = 1:num_workers
        chunk_files(targetset) = [chunk_files(targetset) chunk_files_by_worker{w}];
    end
    
end

fprintf('Features computed!\n');

end
function save_chunk_imgnet(filename, setOfFeats,setOfFrames,setOfImgSize, index)
%save(filename,'chunk_feats','chunk_frames','chunk_sizes','index','-v7.3');
save(filename,  'setOfFeats', 'setOfFrames', 'setOfImgSize','index','-v7.3'); 
end
function save_chunk_(filename, chunk, index) %#ok<INUSD>
save(filename,'chunk','index','-v7.3');
end


