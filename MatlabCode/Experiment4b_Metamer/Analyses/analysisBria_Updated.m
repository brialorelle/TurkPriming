
function analyzePrimingData()
%%
clear
clc
dbstop if error;
%%
dataSave=1;
loadData=1;

addpath(genpath('HelperCode'));
%% adds the trim_outliers and plotBarGraph functions
homedir=pwd; %% sets homedir to current directory
dataDir=[homedir filesep 'DataFiles'] %% data dir is this "fileseparator' and then the datafiles folder
FiguresDir=[homedir filesep 'Figures']
cd(dataDir) % change the working directory to the datafiles
dataFiles=dir(fullfile(dataDir, '*.mat'))   % load them until this variable
numSubs=length(dataFiles) %% get a variable of the number of subjects you have

%% adds the trim_outliers and plotBarGraph functions
addpath(genpath('HelperCode'))
%addpath(genpath('error-bars'));


%% load the data
if loadData==0
  %% if you're not doing this, load the .mat file that you saved before
  %% hand
  
  disp('enter average data file!')
  
elseif loadData==1
  for s=1:length(dataFiles)
    D=[];
    load(dataFiles(s).name) %% loads all the variables (really only need the D file) that you saved
    %% need to create this trial counter since it wasn't in the D file
    for t=1:length(D.RT)
      D.currTrial(t)=t;
      D.fileName{t}=dataFiles(s).name; 
      D.sid(t)=s; %% be careful the sid is now no longer matching the original subnum order, which is OK, you should just be aware
    end
    %% get average pc
    percorrect(s)=1-mean(D.error);
    %% average RT
    D.RT=D.RT*1000; %% multiply by 1000 so easier to think about
    avgRT(s)=mean(D.RT);
%     keyboard
    %% code for congruent or not by finding when  word/image category are
    %% equal
    % Make sure you use "double" which converts these to non-logical
    % expressions, otherwise the trim_outliers function won't work
    
    D.CongruentOrNot(D.currImageCategory==D.currWordCategory)=1 %% 1 when congruent
    D.CongruentOrNot(D.currImageCategory~=D.currWordCategory)=2; %% 2 when incongruent
    %D.IdentityTrial=double(D.IdentityTrial)
    
    % Trims the data: any trials that were incorrect, with RT's less than
    % 300 ms, or during practice are excluded
    % Saves the trimmed data in csv files
    Dtrim=[]; % always need to clear a variable if you are going to reuse it !
    Dtrim=trim_outliers(D,3,'RT','MDM',{'error==1','error==888','RT<300','currTrial<11'},{'currWordCategory','currImageCategory'},[dataFiles(s).name '_TrimmedNoEmpty.csv'])
    assert(sum(Dtrim.outlier)==0)
    allTrimmedData{s}=Dtrim;
  end
end

keyboard
%% average across the dimensions you care about
s=[];
for s=1:length(dataFiles) %% for each subject
  assert(sum(allTrimmedData{s}.outlier)==0,'outliers there')
  CongbyWordCat(s,:)=grpstats(allTrimmedData{s}.RT,{allTrimmedData{s}.currWordCategory,allTrimmedData{s}.CongruentOrNot})
  Cong(s,:)=grpstats(allTrimmedData{s}.RT,{allTrimmedData{s}.CongruentOrNot}) %% groupstats function across RT, by Congruency (will do this so that Congruency==0 is first, Congruency==1 is second)
end



%% save this data in a mat file
% if dataSave==1
%    saveData(allTrimmedData,homedir)
% end

%% plot this data


plotBarGraphwithError(CongbyWordCat,numSubs,{'CongruentAnim','Incongruent Anim','Congruent Obj','Incong Obj'} ,['Metamer Flanker Data, numSubs=' num2str(numSubs)],subfigure(1,3,1))
ylim([600 800])
% save the figures, both in matlab format (.fig) and .png format

%savefig([FiguresDir filesep num2str(numSubs) 'subs_Exp3_CongbyWordCat.fig']);
%savefig([FiguresDir filesep num2str(numSubs) 'subs_Exp3_CongbyWordCat.png']);


%% do some stats
levels=[2 2];
varNames={'Anim or Obj','Congruent with Word'};
teg_repeated_measures_ANOVA(CongbyWordCat(:,1:4),levels,varNames);




%% stop here
keyboard
end

%%%% SUBFUNCTIONS %%%%

function saveData(allTrimmedData,homedir)

fileName=[homedir filesep 'AvgData' filesep 'PrimingExperimentAllData' date '.mat'];
fileNameCSV=[homedir filesep 'AvgData' filesep 'PrimingExperimentAllData' date '.csv'];

save(fileName,'allTrimmedData');
DtrimCat=mergeDstructs(allTrimmedData);
dwrite(DtrimCat,fileNameCSV);
end



function DtrimCat=mergeDstructs(DtrimAll)
fieldNames=fieldnames(DtrimAll{1})

for sub=1:size(DtrimAll,2)

  for currField=1:length(fieldNames)
    currFieldName=fieldNames{currField};
    
    if sub==1
      DtrimCat.(currFieldName)(1,:)=DtrimAll{sub}.(currFieldName);
    else
      DtrimCat.(currFieldName)(1,end:(end-1+length(DtrimAll{sub}.RT)))=DtrimAll{sub}.(currFieldName);
    end
  end
end

end


