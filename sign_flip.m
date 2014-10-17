function [sgns,loads,S] = sign_flip(loads,X,pfstuff)

%SIGN_FLIP for assigning correct sign of loading vectors in three-way models.
% [sgns,newmodel] = sign_flip(model,X)
% INPUT
% model is a model structure (or cell of loadings if PCA or PARAFAC)
% X     is the data array
%
% OUTPUT
% sgns  is a MxF matrix where sgns(m,f) is the sign of loading f in mode m
% model is a cell containing the corrected model (or cell of loadings)
%
% If using svd ([u,s,v]=svd(X)) then set
% loads{1}=u*s;
% and loads{2}=v;
%
% If using an F-component PCA model ([t,p]=pca(X,F), then loads{1}=t; and
% loads{2}=p;
%
% Copyright 2007 R. Bro, E. Acar, T. Kolda - www.models.life.ku.dk
%                            Updated to three-way models 2013 by Bro,
%                            Leardi, Johnsen, Journal of Chemometrics

% Modification 2012, Changed PCA/PARAFAC so that there is a correction for
% varying number of vectors in X and X'. Otherwise data with very fat or
% skinny matrices would come out strange. The correction involves dividing
% by squareroot of the length of the vector and taking the mean rather than
% sum
% s(i) = s(i)/sqrt(length(a)); % Correcting for number of vectors
% S(m,f) =mean(s);

if isa(X,'dataset')
    inc = X.includ;
    X = X.data(inc{:});
end

if any(isnan(X(:))) % Simply replace data with model of data. That should work
    X = datahat(loads);
end

model = 'pca';
recallmodel = 0;
if isstruct(loads); % A PLS_model structure assumed
    recallmodel = 1;
    oldmodel = loads;
    if isfield(loads,'modeltype')
        if strcmpi(loads.modeltype,'pca')
            model = 'pca';
        elseif strcmpi(loads.modeltype,'parafac')
            model = 'parafac';
        elseif strcmpi(loads.modeltype,'tucker')
            model = 'tucker';
        elseif strcmpi(loads.modeltype,'parafac2')
            model = 'parafac2';
        else
            error(' Modeltype not supported')
        end
        loads = loads.loads;
    else
        error(' Only a cell of loadings or a recognized PLS_Toolbox model structure is valid as first input')
    end
end

order = length(size(X));
for i=1:order
    F(i) = size(loads{i},2);
end

if strcmpi(model,'parafac2')
    
    loads = sgnswitch_pf2(loads,X);
    sgns=0;
    
elseif strcmp(model,'tucker')
    % STEP 1
    % First adjust all loading vectors without considering the core
    for m = 1:order % for each mode
        for f=1:F(m) % for each component
            s=[];
            a = loads{m}(:,f);
            a = a /(a'*a);
            x = subtract_otherfactors_tucker(X, loads, m, f);
            for i=1:size(x(:,:),2) % for each column
                s(i)=(a'*x(:,i));
                s(i)=sign(s(i))*power(s(i),2);
            end
            S(m,f) =sum(s);
        end
    end
    sgns = sign(S);
    
    core = loads{end};
    for m=1:order %each mode
        core = permute(core,[m 1:m-1 m+1:order]);
        for f=1:F(m) %each component
            newloads{m,1}(:,f)=sgns(m,f)*loads{m}(:,f);
            core(f,:) = sgns(m,f)*core(f,:);
        end %each component
        core = ipermute(core,[m 1:m-1 m+1:order]);
    end  %each mode
    newloads{order +1}=core;
    loads = newloads;
    clear S
    
    % STEP 2
    % Then step two where the two biggest core elements are made positive.
    
    
    % For each mode, find out the preferred direction of the loading
    % vectors
    S  = cell(1,order);sgns = cell(1,order);
    for i = 1:order % for each mode
        A = loads{i};
        rest = loads([1:i-1 i+1:end-1]);
        core = loads{end};
        core = permute(core,[i 1:i-1 i+1:ndims(core)]);
        core = core(:,:);
        % Make kronecker of leftout modes
        Z = kron(rest{end},rest{end-1});
        for k=length(rest)-3:-1:1
            Z = kron(Z,rest{k});
        end
        Zcore = Z*core';
        innerpcamodel.modeltype='pca';
        innerpcamodel.loads{1}=A;
        innerpcamodel.loads{2}=Zcore;
        
        Xunfold = permute(X,[i 1:i-1 i+1:ndims(X)]);
        Xunfold = Xunfold(:,:);
        [out,out2,S{i}]=sign_flip(innerpcamodel,Xunfold);
        sgns{i}=sign(S{i});
    end
    
    %With the preferred signs given we now go through all the biggest
    %elements of the core and fix the signs of specific components. We
    %start with the biggest core element and fix signs such that this core
    % element is positive. When that is fixed, we move on but we do not
    %change the vectors in the biggest component that have already been
    % switched for fixing bigger core elements. We stop
    %when no more elements have free vectors that can be switched around.
    for i=1:order
        notfixed{i}=[1:size(loads{i},2)];
    end
    allempty=0;
    
    % List the most important elements in order
    core = loads{end};
    IJK = numel(core);
    howmanyelements=min(IJK,2); % Don't take more than two elements
    for k = 1:howmanyelements
        % Check factor combination number k. Number 1 is the biggest core
        % element
        [res,list] = coreanal(core,'list',howmanyelements);
        idx = list.position(k,:);
        coreval=list.corevalue(k);
        if coreval<0 % change core element if at least one mode has a free vector
            % Find the magnitude of how much the vectors in the component
            % (vector i mode 1, vector j mode 2 etc)
            % wants to be flipped
            for k2 = 1:order
                shere(k2)=S{k2}(1,idx(k2));
                availability(k2) = any(notfixed{k2}==idx(k2)); % Otherwise, that vector has been finally flipped in a more important component
            end
            shere(availability==0)=NaN; % So that we disregard already fixed ones
            if ~all(isnan(shere)) % Then one of the loading vectors in that component can be flipped if need be
                [p1,thismode]=min(shere); % We want to flip the vector that has least magnitude signwise (preferably negative)
                % change that element in core and selected loading
                core = permute(loads{end},[thismode 1:thismode-1 thismode+1:order]);
                szcore = size(core);
                core = core(:,:);
                SG = ones(size(core,1),1);
                SG(idx(thismode))=-1;
                SG = diag(SG);
                core = SG*core;
                core=reshape(core,szcore);
                core = ipermute(core,[thismode 1:thismode-1 thismode+1:order]);
                loads{end} = core;
                loads{thismode}  = loads{thismode}*SG;
                % Remove factor idx(thismode) from mode thismode
                [a,b]=find(notfixed{thismode}==idx(thismode));
                notfixed{thismode}(b)=[];
            end
        end
    end
    
else % PARAFAC and PCA
    for m = 1:order % for each mode
        for f=1:F(m) % for each component
            s=[];
            a = loads{m}(:,f);
            a = a /(a'*a);
            x = subtract_otherfactors(X, loads, m, f);
            for i=1:size(x(:,:),2) % for each column
                s(i)=(a'*x(:,i));
                s(i) = s(i)/sqrt(length(a)); % Correcting for number of vectors
                s(i)=sign(s(i))*power(s(i),2);
            end
            % S(m,f) =sum(s);
            S(m,f) =mean(s);
        end
    end
    sgns = sign(S);
    
    for f=1:F(1) %each component
        for i=1:size(sgns,1) %each mode
            se = length(find(sgns(:,f)==-1));
            if (rem(se,2)==0 )
                loads{i}(:,f)=sgns(i,f)*loads{i}(:,f);
            else
                % disp('Odd number of negatives!')
                sgns(:,f) = handle_oddnumbers(S(:,f));
                se = length(find(sgns(:,f)==-1));
                if (rem(se,2)==0)
                    loads{i}(:,f)=sgns(i,f)*loads{i}(:,f);
                else
                    disp('Something Wrong!!!')
                end
            end
        end  %each mode
    end %each component
    
end

if recallmodel
    oldmodel.loads=loads;
    loads=oldmodel;
end

try
    if any(isnan(sgns(:)))
        sgns(isnan(sgns))=1;
        j=find(prod(sgns)<0);
        for k=1:length(j)
            sgns(j(k),1)=(-1)*sgns(j(k),1);
        end
    end
end
%----------------------------------------------------------------------
function sgns=handle_oddnumbers(Bcon)

sgns=sign(Bcon);
nb_neg=find(Bcon<0);
[min_val, index]=min(abs(Bcon));
if (Bcon(index)<0)
    sgns(index)=-sgns(index);
    % since this function is called nb_neg should be greater than 0, anyway
elseif ((Bcon(index)>0) && (nb_neg>0))
    sgns(index)=-sgns(index);
end


%------------------------------------------------------------------------
function x = subtract_otherfactors(X, loads, mode, factor)

order=length(size(X));
x = permute(X,[mode 1:mode-1 mode+1:order]);
loads = loads([mode 1:mode-1 mode+1:order]);

for m = 1: order
    loads{m}=loads{m}(:, [factor 1:factor-1 factor+1:size(loads{m},2)]);
    L{m} = loads{m}(:,2:end);
end
M = outerm(L);
x=x-M;

function x = subtract_otherfactors_tucker(X, loads, mode, factor)

order=length(size(X));
% Remove column from mode
loads{mode}=loads{mode}(:,[1:factor-1 factor+1:size(loads{mode},2)]);
% Remove correspond slab in core
core = loads{end};
core = permute(core,[mode 1:mode-1 mode+1:order]);
sc = size(core);
sc(1) = sc(1)-1;
core = core([1:factor-1 factor+1:end],:);
core = reshape(core,sc);
core = ipermute(core,[mode 1:mode-1 mode+1:order]);
loads{end}=core;
M = datahat(loads);
X=X-M;
x = permute(X,[mode 1:mode-1 mode+1:order]);



function mwa = outerm(facts,lo,vect)

if nargin < 2
    lo = 0;
end
if nargin < 3
    vect = 0;
end
order = length(facts);
if lo == 0
    mwasize = zeros(1,order);
else
    mwasize = zeros(1,order-1);
end
k = 0;
for i = 1:order
    if i ~= lo
        [m,n] = size(facts{i});
        k = k + 1;
        mwasize(k) = m;
        if k > 1
        else
            nofac = n;
        end
    end
end
mwa = zeros(prod(mwasize),nofac);

for j = 1:nofac
    if lo ~= 1
        mwvect = facts{1}(:,j);
        for i = 2:order
            if lo ~= i
                mwvect = mwvect*facts{i}(:,j)';
                mwvect = mwvect(:);
            end
        end
    elseif lo == 1
        mwvect = facts{2}(:,j);
        for i = 3:order
            mwvect = mwvect*facts{i}(:,j)';
            mwvect = mwvect(:);
        end
    end
    mwa(:,j) = mwvect;
end
% If vect isn't one, sum up the results of the factors and reshape
if vect ~= 1
    mwa = sum(mwa,2);
    mwa = reshape(mwa,mwasize);
end



function newmod = sgnswitch_pf2(loads,X)
sx = size(X);
K = sx(end);
I = sx(1);
F = size(loads{2},2);
order = length(sx);

% Extract loadings
P=loads{1}.P;
H=loads{1}.H;
if order>3 % put all 'middle' loadings into B
    B = kr(loads{end-2},loads{end-3});
    for o=order-4:-1:2
        B = kr(B,loads{o});
    end
else
    B = loads{2};
end
C = loads{end};

%%%%%%%%% FIX Pk, Dk
% Turn it into a problem with Dk and Pk on one mode and the rest
% in another
Z = B; % The rest
G=zeros([I*K F]); % Pk*Dk on top of each other
for k=1:K;
    G((k-1)*I+1:I*k,:) = (P{k}*H*diag(C(k,:)));
end

% Adjust X
Xnew = permute(X,[[2:order-1] 1 order]);
Xnew = reshape(Xnew,sx(2:end-1),sx(1)*sx(end));

% Now its bilinear Xnew = Z*G'; so we can fix indeterminacy between these
% two blocks and then fix it for Pk Dk afterwards

[sgns] = sign_flip({Z,G},Xnew);
% Now modify the 'left' and 'right' loadings
% For left, just pick any one of the modes in there (for higher order models,
% there can be many)
B = B*diag(sgns(1,:));
loads{2}=loads{2}*diag(sgns(1,:)); % This is for later in case of higher order data
% For right; update C;
C = C*diag(sgns(2,:));

if any(prod(sgns)<0)
    error('Something wrong here - apologies');
end

% Now we have updated versions of A (P,H), B, C (and possibly others)
% Now fix sign indeterminacy within Pk,Dk by posing the model as Xk =
% (ADk)*H'*Pk'. This model is assessed using the two-way sign fix for each
% slab and the fixed signs are imposed on Dk and Pk

Xnew = permute(X,[order 2:order-1 1]);
for k=1:K
    LeftLoad=B*diag(C(k,:));
    Xk = reshape(Xnew(k,:),[prod(sx(2:end-1)) I]);
    [sgns,LOADS] = sign_flip({LeftLoad,P{k}*H},Xk);
    if any(prod(sgns)<0)
        error('Something wrong here - apologies');
    end
    C(k,:) = C(k,:).*sgns(1,:);
    S = pinv(H')*diag(sgns(2,:))*H';
    P{k}=P{k}*S';
    % plot(Xk'/max(Xk(:)),'color',.6*[1 1 1]),hold on,plot(P{k}),hold off, shg,axis tight,pause
end

dbg=0;
if dbg==1
    clf,subplot(2,2,1),plot(B),shg, subplot(2,2,2), plot(C),
    subplot(2,1,2), for k=1:10,plot(P{k}*H),hold on,end,55,pause
end


% Now fix indeterminacy within Pk*H
LeftLoad =[];
RightLoad =[];
Xk = [];
S = 0;
for k=1:K % Determine sign in each mode
    L1 = B*diag(C(k,:))*H';
    L2 = P{k};
    Xk = reshape(Xnew(k,:),[prod(sx(2:end-1)) I]);
    [sgns,LOADS,ss] = sign_flip({L1,L2},Xk);
    %S = S+sgns;
    S = S+ss;
    % S holds the magnitude majority sign (maybe not perfect, but it'll
    % work mostly)
end
sgns = sign(S);

if any(prod(sgns)<0) % Adjust misunderstandings so that if signs are swicthed opposite pick the sign that has the highest magnitude as judged from S
    j = find(prod(sgns)<0);
    for j2=1:length(j)
        s=S(:,j(j2));
        [a,b1]=max(abs(s));
        [a,b2]=min(abs(s));
        S(b2,j(j2))=abs(S(b2,j(j2))) * sign(S(b1,j(j2)));
    end
    sgns = sign(S);
end
H = (H'*diag(sgns(1,:)))';
for k=1:K
    P{k} = P{k}*diag(sgns(2,:));
end

if dbg==1
    clf,subplot(2,2,1),plot(B),shg, subplot(2,2,2), plot(C),
    subplot(2,1,2), for k=1:10,plot(P{k}*H),hold on,end,5566,pause
end

% Now the internal Pk Dk signs are fixed and hence Pk is correct. We then
% transform the model into a PARAFAC model
Y = zeros([F sx(2:end)]);
Y = permute(Y,[order 1:order-1]);
Xnew = permute(X,[order 1:order-1]);

for k=1:K
    Xk = reshape(Xnew(k,:),[sx(1) prod(sx(2:end-1))]);
    Yk = P{k}'*Xk;
    Y(k,:) = Yk(:)';
end

newmod=loads;
newmod{1}.P = P;
newmod{1}.H = H;
%newmod{1}.H = H*diag(sgns(1,:));
for o=2:order-1
    %newmod{o} = loads{o}*diag(sgns(o,:));
    newmod{o} = loads{o};
end
% newmod{end} = C*diag(sgns(end,:));
newmod{end} = C;

if any(prod(sgns)<0)
    error('Something wrong here - apologies');
end



function AB = kr(A,B);
%KR Khatri-Rao product
%
% The Khatri - Rao product
% For two matrices with similar column dimension the khatri-Rao product
% is kr(A,B) = [kron(A(:,1),B(:,1)) .... kron(A(:,F),B(:,F))]
%
% I/O AB = kr(A,B);
%
% kr(A,B) equals ppp(B,A) - where ppp is the triple-P product =
% the parallel proportional profiles product which was originally
% suggested in Bro, Ph.D. thesis, 1998

disp('KR.M is obsolete and will be removed in future versions. ')
disp('use KRB.M instead.')


[I,F]=size(A);
[J,F1]=size(B);

if F~=F1
    error(' Error in kr.m - The matrices must have the same number of columns')
end

AB=zeros(I*J,F);
for f=1:F
    ab=B(:,f)*A(:,f).';
    AB(:,f)=ab(:);
end