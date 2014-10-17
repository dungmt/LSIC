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
