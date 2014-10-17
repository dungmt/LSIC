classdef HogExtractor < handle & featpipem.features.GenericFeatExtractor
    %PHOWEXTRACTOR Feature extractor for PHOW features
    
    properties
         % properties vl_hog
        cellSize 
        variant 
        numOrientations
        % properties documented on vl_phow page in vl_feat docs
        verbose
        sizes
        fast
        step
        color
        contrast_threshold
        window_size
        magnif
        float_descriptors
        
        % remove zero vector
        remove_zero
        
        % dimensionality reducing projection
        low_proj
    end
    
    methods
        function obj = HogExtractor(varargin)
            obj.cellSize =8;
            obj.variant =false;
            obj.verbose = true;
            obj.numOrientations =0;
            %%%
            obj.sizes = [4 6 8 10];
            obj.fast = true;
            obj.step = 2;
            obj.color = 'gray';
            obj.contrast_threshold = 0.005;
            obj.window_size = 1.5;
            obj.magnif = 6;
            obj.float_descriptors = false;
            
            obj.remove_zero = false;
            obj.low_proj = [];
            
            obj.out_dim = 128;
            
            featpipem.utility.set_class_properties(obj, varargin);
        end
        [hog] = compute(obj, im)
    end
    
end

