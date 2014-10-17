function [ AP, pfirst, dPREC, dRECL, dF ] = evalannotat_2012( GTMAT, SCO, DEC, varargin )
%
% EVALANNOTAT: Computes evaluation measures for image annotation
%
% Usage:
%   [ AP, pfirst, dPREC, dRECL, dF ] = evalannotat( GTMAT, SCO, DEC [, 'mean'] )
%
% Input:
%   GTMAT                - Ground truth matrix (Nconcepts x Nte)
%   SCO                  - Concept scores (Nconcepts x Nte)
%   DEC                  - Annotation decisions (Nconcepts x Nte)
%   'mean'               - Compute results mean (optional)
%
% Output:
%   AP                   - Average precision
%   pfirst               - Position of first relevant
%   dPREC                - Precision (for decision)
%   dRECL                - Recall    (for decision)
%   dF                   - F-measure (for decision)
%
%
% $Revision: 187 $
% $Date: 2012-05-07 11:11:49 +0200 (Mon, 07 May 2012) $
%

% Copyright (C) 2012 Mauricio Villegas (mvillegas AT iti.upv.es)
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.

fn = 'evalannotat:';
minargs = 3;
logfile = 2;

[ Ncnpt, Nte ] = size(GTMAT);

%%% Error detection %%%
if nargin-size(varargin,2)~=minargs
  fprintf(logfile,'%s error: not enough input arguments\n',fn);
  return;
elseif size(SCO,1)~=Ncnpt || size(SCO,2)~=Nte || size(DEC,1)~=Ncnpt || size(DEC,2)~=Nte
  fprintf(logfile,'%s error: dimensions of SCO and DEC inconsistent with GTMAT\n',fn);
  return;
end

%%% Compute evaluation measures %%%
AP = zeros(Nte,1);
pfirst = zeros(Nte,1);
for nte=1:Nte
  [ sSCOMAT, sidx ] = sort(-SCO(:,nte)); % Sap xep giam dan - ~ sap xep tang
 % sSCOMAT: gia tri 
 % sidx: index cua cac phan tu duoc sx lai
  GTPOS = find(GTMAT(sidx,nte)); % Tim vi tri cua nhan ground truth xuat hien o dau trong vi tri score
  N = size(GTPOS,1);
  nPREC = [1:N]'./GTPOS; % Tinh do chinh xac
  ap =mean(nPREC);
%    pause
  AP(nte,1) = ap;
  pfirst(nte,1) = GTPOS(1);
  
end

dPREC = (sum(GTMAT&DEC,1)./sum(DEC,1))';
dRECL = (sum(GTMAT&DEC,1)./sum(GTMAT,1))';
dF = 2*(dPREC.*dRECL)./(dPREC+dRECL);
dF(~isfinite(dF)) = 0;

if size(varargin,2)>0
  if strcmp(varargin{1},'mean')
    AP = mean(AP);
    pfirst = mean(pfirst);
    dPREC = mean(dPREC);
    dRECL = mean(dRECL);
    dF = mean(dF);
  end
end
