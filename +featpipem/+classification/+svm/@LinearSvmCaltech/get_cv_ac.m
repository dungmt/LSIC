function [ac] = get_cv_ac(y,x,param,nr_fold)
% https://code.google.com/p/scenetext/source/browse/trunk/get_cv_ac.m?r=12
len=length(y);
ac = 0;
rand_ind = randperm(len);
for i=1:nr_fold % Cross training : folding
  test_ind=rand_ind([floor((i-1)*len/nr_fold)+1:floor(i*len/nr_fold)]');
  train_ind = [1:len]';
  train_ind(test_ind) = [];
  model = svmtrain(y(train_ind),x(train_ind,:),param);
  [pred,a,decv] = svmpredict(y(test_ind),x(test_ind,:),model,'-q');
  ac = ac + sum(y(test_ind)==pred);
end
ac = ac / len;
%fprintf('Cross-validation Accuracy = %g%%\n', ac * 100);
