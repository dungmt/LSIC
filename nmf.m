function [W,H] = nmf(X,K,alg,maxiter,speak)
%
% NMF wrapper function
% function [W,H] = nmf(X,K,alg[,maxiter,speak])
%
% INPUT:
%           'X'     Inputmatrix
%           'K'     Number of components
%           'alg'   Algorithm to use: 
%                   'mm'     multiplicative updates using euclidean
%                            distance. Lee, D..D., and Seung, H.S., (2001)
%                   'cjlin'  alternative non-negative least squares using 
%                            projected gradients, author: Chih-Jen Lin, 
%                            National Taiwan University.
%                   'prob'   probabilistic NFM interpretating X as samples
%                            from a multinomial, author: Lars Kai Hansen,
%                            Technical University of Denmark
%                   'als'    Alternating Least Squares. Set negative
%                            elements to zero. 
%                   'alsobs' Alternating Least Squares. Set negative elements
%                            to zero and adjusts the other elements acording
%                            to Optimal Brain Surgeon. 
%           'maxiter'   Maximum number of iterations, default = 1000.
%           'speak'     Print information to screen unless speak = 0,
%                       default = 0
%
% OUTPUT:
% W       : N x K matrix
% H       : K x M matrix
%
% Kasper Winther Joergensen
% Informatics and Mathematical Modelling
% Technical University of Denmark
% kwj@imm.dtu.dk
% 2006/12/15

switch(nargin)
    case {0,1,2}
        error('Missing parameter. Type "help nmf" for usage.');
        return
    case 3
        maxiter = 1000;
        speak = 0;
    case 4
        speak = 0;
    case 5
        % empty
    otherwise
        error('Too many parameters. Type "help nmf" for usage.');
        return
end

% find dimensionallity of X
[D,N] = size(X);

% switch algorithm 
switch lower(alg)
    case 'mm'
        if speak, disp('Using mm algorithm'),end
        [W,H]=nmf_mm(X,K,maxiter,speak);
    case 'prob' 
        if speak, disp('Using prob algorithm'),end
        [W,H]=nmf_prob(X,K,maxiter,speak);
    case 'cjlin'
        if speak, disp('Using cjlin algorithm'),end
        [W,H]=nmf_cjlin(X,rand(D,K),rand(K,N),0.000001,10000,maxiter);
    case 'als'
        if speak, disp('Using als algorithm'),end
        [W,H]=nmf_als(X,K,maxiter,speak);
    case 'alsobs'
        if speak, disp('Using alsobs algorithm'),end
        [W,H]=nmf_alsobs(X,K,maxiter,speak);
    case 'mat_als' 
        if speak
            disp('Using als algorithm in matlab');         
            opt = statset('MaxIter',maxiter,'Display','iter');
        else
            opt = statset('MaxIter',maxiter);
        end
        [W,H] = nnmf(X,K,'algorithm','als','options',opt);
     case 'mat_mult'
        if speak
            disp('Using als algorithm in matlab');         
            opt = statset('MaxIter',maxiter,'Display','iter');
        else
            opt = statset('MaxIter',maxiter);
        end
        if speak, disp('Using mult algorithm in matlab'),end
        [W,H] = nnmf(X,K,'algorithm','mult','options',opt);
     case 'cjlin_tw'
        if speak, disp('Using cjlin from authors website algorithm'),end
        Winit = abs(rand(D,K));
 		Hinit = abs(rand(K,N));
        tol = 0.000000001;		
		timelimit = 10000;
        [W,H]=nmf_cjlin_tw(X,Winit,Hinit,tol,timelimit,maxiter);
        
		
    otherwise
        error('Unknown method. Type "help nmf" for usage.');
        return
end

[W,H,nrgy] = order_comp(W,H);

