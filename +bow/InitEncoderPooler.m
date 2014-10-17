function conf = ILSVRC_InitEncoderPooler(conf)
    
    
        if size(conf.BOW.codebook )==0
            error('error: Code book is empty !');
        end
        if strcmp(conf.BOW.typeEncoder,'LLCEncoder')
            conf.BOW.encoder = featpipem.encoding.LLCEncoder(conf.BOW.codebook );
            conf.BOW.encoder.max_comps = 500;
            conf.BOW.encoder.norm_type = 'none';

            conf.BOW.pooler = featpipem.pooling.SPMPooler(conf.BOW.encoder);
            conf.BOW.pooler.subbin_norm_type = 'none';   % 'l1' or 'l2' (or other value = none)
            conf.BOW.pooler.norm_type = 'l2';            % 'l1' or 'l2' (or other value = none)
            conf.BOW.pooler.pool_type = 'max';           % 'sum' or 'max'
            conf.BOW.pooler.kermap = 'none';             % 'homker', 'hellinger' (or other value = none [default])
            conf.BOW.pooler.post_norm_type = 'none';    % 'l1' or 'l2' (or other value = none)
            conf.BOW.pooler.quad_divs = 2;              % value = 2 [default])
            conf.BOW.pooler.horiz_divs = 0;             % value = 3 [default])
 
            
        elseif strcmp(conf.BOW.typeEncoder,'VQEncoder')
            % VQEncoder
            conf.BOW.encoder = featpipem.encoding.VQEncoder(conf.BOW.codebook );
            conf.BOW.encoder.max_comps = 25; % max comparisons used when finding NN using kdtrees
            conf.BOW.encoder.norm_type = 'none'; % normalization to be applied to encoding (either 'l1' or 'l2' or 'none')

            conf.BOW.pooler = featpipem.pooling.SPMPooler(conf.BOW.encoder);
            conf.BOW.pooler.subbin_norm_type = 'none'; % normalization to be applied to SPM subbins ('l1' or 'l2' or 'none')
            conf.BOW.pooler.norm_type = 'l1'; % normalization to be applied to whole SPM vector
            conf.BOW.pooler.pool_type = 'sum'; % SPM pooling type (either 'sum' or 'max')
            conf.BOW.pooler.kermap = 'homker'; % additive kernel map to be applied to SPM (either 'none' or 'homker')
        elseif strcmp(conf.BOW.typeEncoder,'KCBEncoder')            
            conf.BOW.encoder = featpipem.encoding.KCBEncoder(conf.BOW.codebook );
            conf.BOW.encoder.max_comps = 500;
            conf.BOW.encoder.norm_type = 'none';
            conf.BOW.encoder.sigma = 45;

            conf.BOW.pooler = featpipem.pooling.SPMPooler(conf.BOW.encoder);
            conf.BOW.pooler.subbin_norm_type = 'none';
            conf.BOW.pooler.norm_type = 'l1';
            conf.BOW.pooler.pool_type = 'sum';
            conf.BOW.pooler.kermap = 'homker';


        end
    end

