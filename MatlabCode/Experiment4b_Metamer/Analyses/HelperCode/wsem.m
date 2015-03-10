function se_condition=wsem(data)
% compute within subject standard error of the mean
% 
% input
%        data: rows=subjects, columns = all within-subject conditions
%              If you pass in an MxNxC matrix, the matrix will be flattened
%              to Mx(N*C), assuming M=num subjects, N*C=numConditions.
%
%   doCorrect: whether to apply morey's correction to cousineau's method
%
% citation
% Error bars show within-subject standard error of the mean computed
% with Morey's (2008) correction to Cousineau's (2005) method.
%
% refs
% Cousineau, D. (2005). Confidence intervals in within-subject designs: 
% A simpler solution to Loftus and Masson?s method. Tutorials in 
% Quantitative Methods for Psychology, 1(1), 42-45.
% 
% Morey, R. D. (2008). Confidence intervals from normalized data: 
% A correction to Cousineau (2005). Tutorial in Quantitative Methods for 
% Psychology, 4(2), 61?64.

if nargin<2
  doCorrection=1;
end

% flatten data to be size [numSubjects x numConditions]
[nS nX nC]=size(data);
data=reshape(data,[nS nX*nC]);

% First, grand mean-normalize the data
% new value = old value - subject mean + grand mean
GM=mean2(data); % grand mean
SM=mean(data,2); % subject mean
ndata=bsxfun(@minus,data,SM)+GM; % grand mean normalized

% Then compute SEM in the usual way on the normalized data
% standard error mean = standard deviation / square root of the number of participants
N=size(ndata,1);
se_condition=std(ndata)/sqrt(N);

if (doCorrection==1)
  
  % Cousineau's error bars tend to be too small. This happens because 
  % the normalization method introduces a small bias. To correct this
  % bias, multiply the variances in each condition by M/(M-1), where M 
  % is the number of conditions.
  % 
  % Except we're working with standard deviations, not variances, so 
  % multiply by sqrt(M/[M-1]).
  M=size(ndata,2);  
  correctionFactor = sqrt(M/[M-1]);
  se_condition=se_condition*correctionFactor;

end

% reshape ci output to matchin data input
se_condition=reshape(se_condition,[1 nX nC]);

