classdef GistDescriptor < handle & featpipem.features.GenericFeatExtractor
    %GistDescriptor Feature extractor for GIST features
    %http://people.csail.mit.edu/torralba/code/spatialenvelope/
    properties
      param
    end
    
    methods
        function obj = GistDescriptor(varargin)
			obj.param.imageSize = [256 256]; % it works also with non-square images (use the most common aspect ratio in your set)
			obj.param.orientationsPerScale = [8 8 8 8]; % number of orientations per scale (from HF to LF)
			obj.param.numberBlocks = 4;
			obj.param.fc_prefilt = 4;
        end
       % [feats, frames] = compute(obj, im)
		[gist, param]= compute(obj, im)
		[gist, param] = LMgist(D, HOMEIMAGES, param, HOMEGIST)
    end
    
end

