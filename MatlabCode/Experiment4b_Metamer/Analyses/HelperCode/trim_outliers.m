function [trimData D]=trim_outliers(D,SD,dataField,trimMethod,dropList,parseList,saveName)
% Trim outliers from data set.
%
% D:            data structure, or filename used to load a data strucure
%               D.fieldName=[1xN], where N=number of trials
%               with any number of field names
%
% dataField:    field of D that has the data to be trimmed
%
% trimMethod:   ZScore, MAD, MDM (see below for details)
%
% dropList:     a cell array of strings, specify global filter to apply to all trials
%               dropList should specify which trials to "exclude" or "drop"
%               e.g., 
%               dropList={'Accuracy==0','RT<100'}
%               drops trials with errors and RTs less than 1/10th of a second
%
% parseList:    a cell array of strings, specifying which data fields
%               should be used for parsing the data for trimming (e.g., by subject, condition)
%               e.g.,
%               parseList={'Subject','Condition'} 
%               will parse the data into separate sets for each combination of
%               subject and condition (e.g., if there are 3 subjects, and 2
%               conditions, the data will be split into 3x2=6 subsets, and each
%               subset will be trimmed separately.
%
% methods:
%   (1) ZScore
% 		-compute z-score
% 		-find item with most extreme absolute(z-score)
% 		-if it's greater than SD cutoff (e.g., 3 standard deviations), drop it
% 		-repeat, until no items exceed SD cutoff
%  
% 	(2) Median Absolute Deviation (MAD) 
% 		-compute median absolute deviation
% 			MAD = b * median( abs(x ? median(x) ) )
% 			If we set b=1.4826, then MAD is an estimate of the standard deviation of our data set,
% 			assuming that the true underlying data came from a Gaussian distribution.
% 		-find item with most extreme MAD value
% 		-if it's greater than SD cutoff (e.g., 3 standard deviations), drop it
% 		-repeat, until no items exceed SD cutoff
% 
%  (3) Median Deviation of the Medians (MDM), better than MAD in general, especially for fewer data points
% 		-compute median deviation of medians
% 			MDM = c * median( median( abs(xi ?xj) ) )
%			for all datapoints, xi, compute the difference to all other data points, xj
%  			If we set c=1.1926, then MDM is a robust estimate of the standard deviation of the data set, 
% 			assuming that the true underlying data came from a Gaussian distribution. 
%
% 	REFERENCES:
% 	Hampel FR (1974) The influence curve and its role in robust estimation. Journal of American Statistical Association 69:383-393.
% 	Rousseeuw PJ, Croux C (1993) Alternatives to the median absolute deviation. Journal of American Statistical Association 88:1273-1283.
% 	    
% e.g.,
% D.RT=[1000 250 340 500 256 1];
% D.Accuracy=[1 0 1 1 1 1];
% D.Subject=[1 1 1 2 2 2];
% >>[trimData D]=trim_outliers(D,3,'RT','ZScore',{'Accuracy==0','RT<200'},{'Subject'},'test.csv')
% >>[trimData D]=trim_outliers('visSearchObjects_MixedStruct.csv',3,'logRT','ZScore',{'Accuracy==0','RT<200'},{'Subject','Condition','SetSize'},'test.csv')
% -------------------------------------------------------------------------
% 9578
% Check Inputs
% -----------------------------------
if isstr(D)
    D=dload(D);
end

% Apply Global Filters
% -----------------------------------
dropThese=[];
for f=1:length(dropList)
    ['dropThese=[dropThese find(D.' dropList{f} ')]'];
    eval(['dropThese=[dropThese find(D.' dropList{f} ')];']);
end

fieldNames=fieldnames(D);
for f=1:length(fieldNames)
    
    if strcmp(fieldNames{f},'currImNum')
      D.(fieldNames{f})(dropThese,:)=[];
    else 
      D.(fieldNames{f})(dropThese)=[];
    end
end

% Add Log RT if it doesn't exist (assumes RT exists)
% -----------------------------------
if strcmp(dataField,'logRT') & ~ismember('logRT',fieldNames)
    if ismember('RT',fieldNames)
        D.logRT=log(D.RT);
    end
end

% Parse Data into Subsets (using parseList)
% Trim outliers from each subset of data
% -----------------------------------

% if there's no parseList, operate over full data set
if isempty(parseList)
    x=D.(dataField);
    %% PUT IN BY BRIA because no trim fun here when global !!
    trimfun=@(x) zscore(x);
    sprintf('WARNING!!:: USING ZSCORE BECAUSE NO PARSE LIST!!')
    [xout,xkeep,xdrop]=trim_data(x,SD,trimfun);
    D.trimData=x;
    D.outlier=double(xout);
    
% if there is a parseList, the operate over parsed data sets    
else
    
    % determine number of parses, and unique levels of each variable
    P=[];
    N=[];
    for p=1:length(parseList)
        P{p}=unique(D.(parseList{p}));
        N=[N length(P{p})];
    end
    ff=fullfact([N]);
    
    % loop through subsets
    trimInfo=[];
    for i=1:size(ff,1)
        
        % get filter values
        fv=[];
        for j=1:length(P)
            fv(j)=P{j}(ff(i,j));
        end
        
        % apply filter values, grab relevant subset of data
        useThese=ones(size(D.(dataField))); % start by using all
        for j=1:length(P)
            useThese=useThese .* D.(parseList{j})==fv(j); % by multiplying, we drop trials that fail 1 or more filters
        end
        x=D.(dataField)(useThese);
        
        % now trim outliers for these data
        switch trimMethod
            case {'ZScore'}
                trimfun=@(x) zscore(x);
            case {'MAD'}
                trimfun=@(x) [x-median(x)] / [1.4826 * median( abs(x-median(x)) )];
                
            case {'MDM'}
                trimfun=@(x) [x-median(x)] / compute_mdm(x);
        end
        
        [xout,xkeep,xdrop]=trim_data(x,SD,trimfun);
        D.trimData(useThese)=x;
        D.outlier(useThese)=double(xout);
    end
    
end

% finally drop those outliers!
% -----------------------------------
dropThese=D.outlier==1;
trimData=D;
fieldNames=fieldnames(trimData);
for f=1:length(fieldNames)
  if strcmp(fieldNames{f},'currImNum')
    trimData.(fieldNames{f})(dropThese,:)=[];
  else
    trimData.(fieldNames{f})(dropThese)=[];
  end
end

% save it
% -----------------------------------

dwrite(trimData, saveName);


% -----------------------------------
% *** SUBFUNCTIONS ***
% -----------------------------------

function MDM=compute_mdm(x)
d=[];
for i=1:length(x)
    c=0;
    for j=1:length(x)
        if i~=j
            c=c+1;
            d(i,c)=x(i)-x(j);
        end
    end
end
MDM = 1.1926 * median(median(abs(d),2));

function [xout,xkeep,xdrop] = trim_data(x,SD,trimfun)  
xout=logical(zeros(size(x))); % outilers, initially none
xkeep=x; % data to keep
xdrop=[]; % data to drop

z=trimfun(xkeep);
while max(abs(z)>SD)
    % find the outlier in the remaining data set, then drop it
    idx=find(abs(z)==max(abs(z)));
    dropval=xkeep(idx(1));
    xkeep(idx)=[];
    
    % find that value in the full data set, mark it as dropped
    xout(x==dropval)=1;
    xdrop=[xdrop dropval];
    
    % update 
    z=trimfun(xkeep);
end

function [D] = dload(fn)
%------------------------------------------------------------------------
% function [D] = dload(fn)
%
% load data from a comma separated file
% first line is all headers (strings)
% outputs D struct, with headers as field names
%
% EXAMPLE: D = dload('SampleData.csv')

% tkonkle@mit.edu
% 30 april 2009
% clear all
%------------------------------------------------------------------------

% try
    
% open file
%------------------
fid = fopen(fn);
sep = sprintf(',');

% line one: header:
%------------------
tline = fgetl(fid);
sepIdx = [0 strfind(tline,sep) length(tline)+1];
for i=2:length(sepIdx)
    fieldname = tline(sepIdx(i-1)+1:sepIdx(i)-1);
    D.(fieldname) = [];
end
headers = fieldnames(D);

% get rest of lines
%------------------
thisLine = 0;  % ignore header line in the count of the lines...
while 1
    % get next line
    tline = fgetl(fid);
    if ~ischar(tline),   break,   end % checks for end of file
    thisLine = thisLine+1; 
    sepIdx = [0 strfind(tline,sep) length(tline)+1];
    for i=2:length(sepIdx)
        cellData = tline(sepIdx(i-1)+1:sepIdx(i)-1);

        % detect type of cell data
        % algorithm: see if it has a special character, if so make string;
        % convert to a number; if it's empty, then it was a string.
        
        if (find(cellData==':'))
            % charactor
            D.(headers{i-1}){thisLine} = cellData;
        elseif ~isempty(str2num(cellData))
            % numeric
            cellData = str2num(cellData);
            D.(headers{i-1})(thisLine) = cellData;
        else
            % charactor
            D.(headers{i-1}){thisLine} = cellData;
        end
    end

end

% close file
%------------------
fclose(fid);

function dwrite(D, fname)
%------------------------------------------------------------------------
% function dwrite(D, fname)
%
% writes a comma separated file from a Data struct
% (inverse of dload function)
%
% EXAMPLE: dwrite(D, 'SampleData.csv')

% tkonkle@mit.edu
% 30 april 2009
% clear all
%------------------------------------------------------------------------


% open file
fid = fopen(fname, 'w');
sep = ',';

% headers
headers = fieldnames(D);
for i=1:length(headers)
    fprintf(fid, ['%s' sep] , headers{i});
end;
fprintf(fid, '\n');

% assume that the last field has the proper length
totalTrials = length(D.(headers{end}));

% data
for t=1:totalTrials
    for h=1:length(headers)
        entry = D.(headers{h})(t);
        if ischar(entry)
            fprintf(fid, ['%s' sep], entry);
        elseif isnumeric(entry)
            fprintf(fid, ['%s' sep], num2str(entry(1)));
        elseif iscell(entry)
            fprintf(fid, ['%s' sep], num2str(entry{1}));
        else
            disp('wrong type')
            keyboard
        end;
    end;
    fprintf(fid, '\n');
end;

%close file
fclose(fid);

