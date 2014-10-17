
for i=1:257
    W(i,i)=0;
end

for i=1001:1676
    [a,b] = find(synsets(i).leaf_indx==585);
    if(length(a)>0)
        synsets(i)
        pause;
    end
end

for i=1:1676
    if strcmp(synsets(i).WNID,'n01503061')   
        synsets(i)
        pause;
    end
end
for i=1001:1676
    if strcmp(synsets(i).WNID,'n00021939')   
        synsets(i)
        pause;
    end
end

[aa,bb] = max(scores_matrix,[],1);
[Confusion,order] = confusionmat(test_label_vector,bb);
n_conf = size(Confusion,1);
num_data = sum(sum(Confusion)) - sum(diag(Confusion));
data_kmean = zeros(2, num_data);
indx_kmean = 1;
for i=1:n_conf
    for j=1:n_conf
        if i==j, continue, end
        val = Confusion(i,j);
        if val>0
            data_kmean (1,indx_kmean: indx_kmean+val-1)=i;
            data_kmean (2,indx_kmean: indx_kmean+val-1)=j;
            indx_kmean = indx_kmean + val;
        end
    end
end
K=8;
%data_kmean = uint8(data_kmean);
[Centers,A_indx] = vl_kmeans(data_kmean,K) ;
cl = get(gca,'ColorOrder') ;
ncl = size(cl,1) ;
for k=1:K
  sel  = find(A_indx  == k) ;  
  plot(data_kmean(1,sel),  data_kmean(2,sel),  '.',...
       'Color',cl(mod(k,ncl)+1,:)) ;
   hold on ;
end






        
