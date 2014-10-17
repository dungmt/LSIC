function [gist, param] = compute(obj, im)
%COMPUTE omputing the GIST descriptor
% it might be important to normalize the image size before computing the GIST descriptor
	%param.imageSize. If we do not specify the image size, the function LMgist
%   will use the current image size. If we specify a size, the function will
%   resize and crop the input to match the specified size. This is better when
%   trying to compute image similarities.
	%param.orientationsPerScale = [8 8 8 8]; % number of orientations per scale (from HF to LF)
	%param.numberBlocks = 4;
	%param.fc_prefilt = 4;

	[gist, param] = utility.LMgist(im, '', obj.param); %featpipem.features.GistDescriptor.LMgist(im, '', obj.param);
	
  %  [gist, param] = LMgist(D, HOMEIMAGES, param, HOMEGIST);
end

