function MakeDirectory(pathToDir )
    if ~exist(pathToDir,'dir')
        mkdir(pathToDir);
        if ~exist(pathToDir,'dir')
             error('Can not create directory %s\n',pathToDir);
        end
    end
end