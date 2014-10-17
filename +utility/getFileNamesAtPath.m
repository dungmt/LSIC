function ims = getFileNamesAtPath(pathloc, extstr)
    dirlisting_all = dir(pathloc);
    % remove '.' and '..' items from directory listing
    dirlisting_all(arrayfun(@(x)(strcmp(x.name,'.')),dirlisting_all)) = [];
    dirlisting_all(arrayfun(@(x)(strcmp(x.name,'..')),dirlisting_all)) = []; 
    %remove all non-image entries
   % extstr = 'jpg|jpeg|gif|png|bmp';
   %    extstr = 'mat';
    % extstr = 'txt';
    dirlisting = arrayfun(@(x)~isempty(regexpi(x.name,extstr)),dirlisting_all);
    ims = arrayfun(@(x)(x.name),dirlisting_all(dirlisting),'UniformOutput',false);
end
