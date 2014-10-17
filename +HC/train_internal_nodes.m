function model = train_internal_nodes(Y, X, config)
    if size(Y, 1) < size(Y, 2)
      Y = Y';
    end
    num_classes = length(unique(Y));
    fprintf('\n train_internal_nodes');
    fprintf('\n\t num_classes=%d', num_classes);
    fprintf('\n\t config.libsvmoption=%s', config.libsvmoption);
    fprintf('\n\t Training...');
    model = train(X, sparse(X),config.libsvmoption); 
    fprintf('finish ! \n');
end



