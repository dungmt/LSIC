function [annotation_dec_matrix ]=  annotation_dec_2012(concept_score_matrix, topn)
% generate a Annotation decisions matrix


   
    num_images = size(concept_score_matrix,1);
    num_concepts = size(concept_score_matrix,2);
    assert(num_images>0);
    assert(num_concepts>0);
    
    annotation_dec_matrix = zeros(num_images, num_concepts);
    for i=1:num_images
        score_row = concept_score_matrix(i,:);
        [B, IDX]=sort(score_row,'descend');
 %       IDX(1:topn)
%         pause
        annotation_dec_matrix(i, IDX(1:topn) )=1;        
    end
end