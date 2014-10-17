% * feats_visual/webupv13_*.feat.gz
% 
%   The visual features in a simple ASCII text sparse format. The first
%   line of the file indicates the number of vectors (N) and the
%   dimensionality (DIMS). Then each line corresponds to one vector,
%   starting with the number of non-zero elements and followed by pairs
%   of dimension-value, being the first dimension 0. In summary the file
%   format is:
% 
%     N DIMS
%     nz1 Dim(1,1) Val(1,1) ... Dim(1,nz1) Val(1,nz1)
%     nz2 Dim(2,1) Val(2,1) ... Dim(2,nz2) Val(2,nz2)
%     ...
%     nzN Dim(N,1) Val(N,1) ... Dim(N,nzN) Val(N,nzN)
function [matrix_feat ]=  feats_visual_read(path_filename_feats_visual)

    fid = fopen(path_filename_feats_visual, 'rt');
%     lines = textscan(fid, '%s');
%     lines = lines{1};
    tline = fgets(fid);
    
    if ischar(tline)
        x = str2num(tline)
        N=x(1);
        DIMS = x(2);
    end
    assert(N>0 && DIMS>0);
    fprintf('\n  The visual features in a simple ASCII text sparse format');
    fprintf('\n\t The number of vectors (N):%d',N);
    fprintf('\n\t The dimensionalityn(DIMS):%d',DIMS);
    fprintf('\n');
  
    matrix_feat = zeros(N,DIMS);
    row_i=1;
    while true
        
        tline = fgets(fid);
        if ~ischar(tline)
            break;
        end
%         disp(tline);
        x = str2num(tline);
        nzi = x(1);
        fprintf('\n\t\t vector:%d - the number of non-zero elements:%d',row_i, nzi);
        k=2;
        for j=1: nzi
            Dim_i_nzj = x(k); 
            Val_i_nzj = x(k+1);
            
            matrix_feat(row_i, Dim_i_nzj+1) = Val_i_nzj;
            k=k+2;
        end 
        row_i=row_i+1;
    end

    fclose(fid);


end