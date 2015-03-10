function Experiment3()

% -------------------------------------------------------------------------
% Display a sequence of images
% -------------------------------------------------------------------------
dbstop if error;

% clear all variables
clear all;

% clear command window
clc;

Screen('Preference', 'SkipSyncTests', 1);

% move cursor to the command window
commandwindow;

% % get subject ID

subID = input('enter subject ID:', 's');
responsegroup = input('enter response group:', 's');
uniqueID = [subID '_' responsegroup '_' datestr(now,30)];

%--------------------------------------------------------------------------
% Step 1: Open a Psychtoolbox window
%-------------------------------------------------------------------------- 
window = openMainScreen;
Screen('FillRect', window.onScreen, [1000 1000 1000]);               

% open a data file
fileName=fullfile('DataFiles',['Data_' uniqueID '.txt']);
fid=fopen(fileName,'w');

% save your D struct in a .mat file in the DataFiles folder
matFileName=fullfile('DataFiles',['Data_' uniqueID '.mat']);
csvFileName=fullfile('DataFiles',['Data_' uniqueID '.csv']);

%--------------------------------------------------------------------------
% Step 2: Set some presentation parameters
%--------------------------------------------------------------------------
screenRect=window.screenRect;
screenCenterY = screenRect(4)/2;
displayWidth =  600;
displayHeight = 600;
rotationAngle = 0;
prefs.itemSize=600;


%--------------------------------------------------------------------------

% Step 3: Get information about images
%--------------------------------------------------------------------------

% load words
TestWords=loadTestWords();
PracWords=loadPracWords();

% load images
[ImageTex,prefs]=loadSomeImages(window,prefs); %changed to use pngs and window
[PracTex,prefs]=loadPracticeImages(window,prefs);


% determine number of images PER CATEGORY
numImages=size(ImageTex,1) 
pracImages=size(PracTex,1)

%% Figure out how to randomize trials
[ff(:,1),ff(:,2),ff(:,3), ff(:,4)]=BalanceFactors(4,1,[1 2],[1:numImages],[1 2], [1 2]) %640 trials in all for 20 images per category  
[pp(:,1),pp(:,2),pp(:,3),pp(:,4)]=BalanceFactors(1,1,[1 2],[1:pracImages],[1 2],[1 2])
pracTrials= pp(randsample(size(pp,1),10),:);

% keyboard --> to debug (dbquit to exit debug mode) 
%% ff(:,1): prime category (animal or object): refers to first factor of
%% row in image tex
%% ff(:,2): prime category number:  refers to the column of image tex
%% ff(:,3): target number: refers to the row of the test words
%% ff(:,4):left or right side of screen 

ff=[pracTrials;ff]
numTrials=size(ff,1); 

HideCursor;

%--------------------------------------------------------------------------
% Step 4: Present message, wait for keypress
%--------------------------------------------------------------------------

% create string with text message
textDirections='On each trial, a WORD and a PICTURE will appear on the screen. \n \n Please press the "Q" key \n if the WORD refers to an ANIMAL. \n \n Please press the "P" key \n if the WORD refers to an OBJECT. \n\n Please try to respond within 2 seconds. \n \n \n You will start with a practice block. \n \n Press any key to begin.'
% set screen TextSize to be 40
Screen ('TextSize', window.onScreen, 30); 
% draw formatted text window.onScreen
DrawFormattedText(window.onScreen, textDirections, 'center', 'center', [0 0 0]) %, [], [], [], [1])
%DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft][, winRect] 
% flip window.onScreen 
Screen ('Flip', window.onScreen);

% wait for a keypress
while ~KbCheck() end

% empty screen before trials begin  
Screen('FillRect', window.onScreen, [1000 1000 1000]);
Screen('Flip', window.onScreen);
pause(.1); 


%--------------------------------------------------------------------------
% Step 5: Display images in random order
%--------------------------------------------------------------------------

% Blocking 
currBlock=0; 

for currTrial=1:numTrials 
    
     %GET VARIABLES!
     % Get current WORD variables
      currWordCategory=ff(currTrial,3); 
      if currTrial<11
      ff(currTrial,5)=randsample(size(PracWords,2),1); 
      else
      ff(currTrial,5)=randsample(size(TestWords,2),1);
      end 
      currWordNumber=ff(currTrial,5);      
     % Get current IMAGE variables
      currImageCategory=ff(currTrial,1);
      currImageNumber=ff(currTrial,2);
      %Get IDENTITY TRIAL
      % IdentityTrial=(currImageNumber==currWordNumber); %%% THIS NEEDS IMAGE NUMBERS AND NAMES TO MATCH
      RightorLeft=ff(currTrial,4); %%Whether word is on left or right
  
   
      %%Image and Word Presentation Parameters
      if RightorLeft==1
          randomwordPosition=[screenRect(3)*0.50 0 screenRect(3) screenRect(4)] %[left top right bottom]
          randompicPosition=0.25
      elseif RightorLeft==2
          randomwordPosition=[0 0 screenRect(3)*0.50 screenRect(4)] %[left top right bottom]
          randompicPosition=0.75
      end 

     screenPic = screenRect(3)*randompicPosition
     destinationPicRect = CenterRectOnPoint([0 0 displayWidth displayHeight], screenPic, screenCenterY)
    %destinationWordRect = CenterRectOnPoint([0 0 displayWidth displayHeight], screenWord, screenCenterY)
      
     %FIXATION CROSS %% jitter before trial 
     %timeoffset = 0:0.05:0.1;
     %wait=1+randsample(timeoffset,1)
     Screen ('FillRect', window.onScreen, [1000 1000 1000]);
     Screen ('TextSize', window.onScreen, 100); 
     DrawFormattedText(window.onScreen, '+', 'center', 'center', [0 0 0]) 
     Screen ('Flip', window.onScreen);
     pause(0.0001); %jitter how long the fixation cross is on  before picture
  
 
    
     % Word
     Screen ('FillRect', window.onScreen, [1000 1000 1000]);
     Screen ('TextSize', window.onScreen, 54);
     % DrawFormattedText(window.onScreen, TestWords{currWordCategory,currWordNumber},'center', 'center', [0 0 0]);
     if currTrial<11
         DrawFormattedText(window.onScreen, PracWords{currWordCategory,currWordNumber},'center', 'center', [0 0 0], [], [], [], [], [], randomwordPosition);
         Screen('DrawTexture', window.onScreen, PracTex(currImageNumber,currImageCategory),[], destinationPicRect, rotationAngle);
     else
        DrawFormattedText(window.onScreen, TestWords{currWordCategory,currWordNumber},'center', 'center', [0 0 0], [], [], [], [], [], randomwordPosition);
     % DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft][, winRect])
     % Picture 
        Screen('DrawTexture', window.onScreen, ImageTex(currImageNumber,currImageCategory),[], destinationPicRect, rotationAngle);
     end
     %Flip on Screen 
     stuffOnScreen=Screen('Flip', window.onScreen);
        
   %wait for a response
    keys=[KbName('q') KbName('p')];
    [keyIsDown, ~, keyCode, deltaSecs] = KbCheck();
     while ~any(keyCode(keys))
         if GetSecs-stuffOnScreen>0.001
             break 
         end 
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
     end

   %Reaction Time
    currRT=GetSecs-stuffOnScreen;
    if currRT<0.0001
        while KbCheck() end; % wait for key to be released
        % get what key they pressed
        pressedKeyNum=find(keyCode);
        pressedKeyNum=pressedKeyNum(1); % in case 2 keys pressed, only accept first
        pressedKeyName=KbName(pressedKeyNum);
    elseif GetSecs-stuffOnScreen>0.0001
       %dummy variables
       currRT=888
       pressedKeyNum=888
       pressedKeyName=888
       %nextscreen
       Screen('FillRect', window.onScreen, [1000 1000 1000]);      
       Screen('Flip', window.onScreen); 
       pause(.0001)
    end
     
     % record reaction time
    D.RT(currTrial)=currRT
   
     % see if correct answer
     if (currWordCategory==1) % word referred to animal
        if (pressedKeyNum==KbName('q')) % "animal" pressed
            respError=0;
        elseif (pressedKeyNum==KbName('p'))
            respError=1;
        else
            respError=888;
        end
     elseif (currWordCategory==2)
        if (pressedKeyNum==KbName('p')) % "object" pressed
            respError=0;
        elseif (pressedKeyNum==KbName('q'))
            respError=1;
        else
            respError=888;
        end 
     else %check to make sure one of two categories 
        disp('error!!')
        assert(0,'wordCategories off!!')
     end
     
       % empty screen after trial 
       Screen('FillRect', window.onScreen, [1000 1000 1000]);      
       Screen('Flip', window.onScreen); 
       pause(.01) %% this doesn't need to be that long I don't think;
       
       %Error
       if respError==1
         textMessage='INCORRECT.'
         Screen ('TextSize', window.onScreen, 30);
         DrawFormattedText(window.onScreen, textMessage, 'center', 'center', [255 0 0])
         Screen ('Flip', window.onScreen);
         WaitSecs(0.0001);
      elseif respError==888
        textMessage='TIME IS UP. \n \n Please respond within 2 seconds.'
        Screen ('TextSize', window.onScreen, 30);
        DrawFormattedText(window.onScreen, textMessage, 'center', 'center', [255 0 0])
        Screen ('Flip', window.onScreen);
        WaitSecs(0.0001);
      end 
      
       
       %Save to the D.Structure 
       D.expName{currTrial}='Experiment4Metamer_AutoRun.m';
       D.currWordCategory(currTrial)=currWordCategory;
       D.currWordNumber(currTrial)=currWordNumber;
       D.currImageCategory(currTrial)=currImageCategory;
       D.currImageNumber(currTrial)=currImageNumber;
       % D.IdentityTrial(currTrial)=IdentityTrial;
       D.pressedKeyNum(currTrial)=pressedKeyNum;
       D.pressedKeyName{currTrial}=pressedKeyName;
       D.error(currTrial)=respError;
       
 
    %Practice Block        
    if (currTrial==10)
        textMessage = ['You are now done with the practice block. \n \n Please press the spacebar to continue']
        Screen ('TextSize', window.onScreen, 30); 
        DrawFormattedText(window.onScreen, textMessage, 'center', 'center', [1 1 1], [], [], [], [1])
        Screen ('Flip', window.onScreen);
        
        keys=[KbName('space')];
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
        while ~any(keyCode(keys))
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
        end
        while KbCheck(); end; % wait for key to be released;
        
     % end of study message
    elseif (currTrial==numTrials)
        textMessage = ['You are now done with the study! \n \n Please press the spacebar to exit out. \n \n Thank you for participating!']
        Screen ('TextSize', window.onScreen, 30); 
        DrawFormattedText(window.onScreen, textMessage, 'center', 'center', [1 1 1], [], [], [], [1])
        Screen ('Flip', window.onScreen);
        keys=[KbName('space')];
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
        while ~any(keyCode(keys))
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
        end
        while KbCheck() end; % wait for key to be released;
        
     %Blocks     
    elseif (mod(currTrial,65)==0) % 65 trials in a block, 10 blocks
        currBlock = currBlock + 1;
        textMessage = ['You have completed ' num2str(currBlock) ' out of 10 blocks. \n \n Feel free to take a break before starting the next block. \n \n Please press the spacebar when you are ready to continue.']
        Screen ('TextSize', window.onScreen, 30); 
        DrawFormattedText(window.onScreen, textMessage, 'center', 'center', [1 1 1], [], [], [], [1])
        Screen ('Flip', window.onScreen);
        
        keys=[KbName('space')];
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
        while ~any(keyCode(keys))
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
        end
        while KbCheck() end; % wait for key to be released;
     
    %%Intertrials     
    else
         
        textMessage='Press the spacebar to go on to the next trial.'
        Screen ('TextSize', window.onScreen, 30); 
        DrawFormattedText(window.onScreen, textMessage, 'center', 'center', [1 1 1])
        pause(.0001)

%         Screen ('Flip', window.onScreen);
%         keys=[KbName('space')];
%         [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
%         while ~any(keyCode(keys))
%         [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
%         end
%         while KbCheck() end; % wait for key to be released;
        
    end 
        
    %Wait (empty screen) before next trial--JITTERED
     %timeoffsete = 0:0.05:0.1;
     %waite=randsample(timeoffsete,1)
     Screen('FillRect', window.onScreen, [1000 1000 1000]);      
     Screen('Flip', window.onScreen); 
     pause(0.0001); 
 
     % save each trial
      save(matFileName, 'D','prefs','window','ff'); %%%% THIS CHANGED 
      dwrite(D,csvFileName);
      
      
     end

%%
%--------------------------------------------------------------------------
% Step 6: Pause, Save and Close
%--------------------------------------------------------------------------

% erase screen 
Screen ('FillRect', window.onScreen, [1000 1000 1000]); 
Screen ('Flip', window.onScreen);

% pause
pause(2);

% close everything (data file, screen)
fclose('all');
Screen('CloseAll');




end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function imageFolders=getVisibleSubfolders(parentFolder)

allFolders=dir(parentFolder);
foldCount=0;
imageFolders=[];

for directoryInd=1:length(allFolders)
    if ~isempty(strfind(allFolders(directoryInd).name,'.'))
        disp('had a weird character')
    elseif isempty(strfind(allFolders(directoryInd).name,'.'))
        foldCount=foldCount+1;
        imageFolders(foldCount).name=allFolders(directoryInd).name
    end
end
end


% function files=getVisibleFiles(parentFolder)
% 
% allFolders=dir(parentFolder);
% foldCount=0;
% files=[];
% keyboard
% for directoryInd=1:length(allFolders)
%     if ~isempty(strfind(allFolders(directoryInd).name,'.'))
%         disp('had a weird character')
%     elseif isempty(strfind(allFolders(directoryInd).name,'.'))
%         foldCount=foldCount+1;
%         files(foldCount).name=allFolders(directoryInd).name
%     end
% end
% end

function [ImageTex,prefs]=loadSomeImages(window,prefs)



for ImageFolders=1:2
    
    if ImageFolders==1
        imagePath = './ImageFiles/Animals';
        ims = dir(fullfile(imagePath, '*.png'));
        numImages=length(ims);
        
    elseif ImageFolders==2 
        imagePath = './ImageFiles/Objects';
        ims = dir(fullfile(imagePath, '*.png'));
        numImages=length(ims);
        
    end
    
    for i=1:numImages
        
        % read in the image
        thisIm = imread(fullfile(imagePath, ims(i).name));
        
        % make a texture and put it on the scren
        %image matrix
        ImageTex(i, ImageFolders)=Screen('MakeTexture', window.onScreen, thisIm);
        ImageNames{i, ImageFolders}=ims(i).name; %THIS CHANGED
        
    end
    
prefs.ImageTex=ImageTex; %%THIS CHANGED
prefs.ImageNames=ImageNames; %%THIS CHANGED

assert(sum(sum(sum(prefs.ImageTex==0)))==0) %%THIS CHANGED
end

end


function [PracTex,prefs]=loadPracticeImages(window,prefs)

for ImageFolders=1:2
    
    if ImageFolders==1
        imagePath = './Practice/Anim';
        ims = dir(fullfile(imagePath, '*.png'));
        numPracImages=length(ims);
        
    elseif ImageFolders==2 
        imagePath = './Practice/Obj';
        ims = dir(fullfile(imagePath, '*.png'));
        numPracImages=length(ims);
        
    end
       for i=1:numPracImages %% for each individual image
        thisIm = imread(fullfile(imagePath, ims(i).name));
        
         PracTex(i, ImageFolders)=Screen('MakeTexture', window.onScreen, thisIm);
    end
 
end

end


function TestWords=loadTestWords()

TestWords={'BABOON'	'BISON'	'CHEETAH' 'COBRA' 'DOLPHIN'	'DONKEY' 'FERRET' 'KITTEN' 'LEMUR' 'LOBSTER' 'OSTRICH' 'PANDA'	'PARROT' 'RABBIT' 'RACCOON'	'RHINO'	'SEAGULL' 'SPIDER'	'TIGER'	'TURTLE'
; 'BATHTUB'	'BINDER' 'CANDLE' 'CANOE' 'COMPASS'	'EASEL'	'LADDER' 'LADLE' 'LIGHTER' 'MAILBOX' 'MIRROR' 'PERFUME'	'PIANO' 'PODIUM' 'RAZOR' 'SANDAL' 'SHOVEL'	'STAPLER' 'TABLE' 'TRACTOR'}
 

end

function PracWords=loadPracWords()
    
PracWords={'CAMEL' 'GIRAFFE' 'PANTHER' 'PUPPY' 'ZEBRA'; 'BOTTLE' 'BUCKET' 'HAMMER' 'SCISSORS' 'SOFA'}

end

function dwrite(D, fname)
% % %------------------------------------------------------------------------
% % % function dwrite(D, fname)
% % %
% % % writes a comma separated file from a Data struct
% % % (inverse of dload function)
% % %
% % % EXAMPLE: dwrite(D, 'SampleData.csv')
% % 
% % % tkonkle@mit.edu
% % % 30 april 2009
% % % clear all
% % %------------------------------------------------------------------------
 
%  % open file
fid = fopen(fname, 'w');
 
 % headers
 headers = fieldnames(D);
 for i=1:length(headers)
     fprintf(fid, '%s,', headers{i});
 end;
 fprintf(fid, '\n');
  
 % % assume that the last field has the proper length
 totalTrials = length(D.(headers{end}));
 
 % % data
 for t=1:totalTrials
     for h=1:length(headers)
          entry = D.(headers{h})(:,t);
          if ischar(entry)
              fprintf(fid, '%s,', entry);
          elseif isnumeric(entry)
              fprintf(fid, '%s,', num2str(entry(1)));
          elseif iscell(entry)
              fprintf(fid, '%s,', num2str(entry{1}));
          elseif islogical(entry)
              fprintf(fid, '%f,', double(entry));
          else
              disp('wrong type')
              keyboard
          end;
      end;
      fprintf(fid, '\n');
  end;
  
% % %close file
  fclose(fid);
  
  end


function window = openMainScreen

% display requirements (resolution and refresh rate)
window.requiredRes  = [];
window.requiredRefreshrate = [];

%basic drawing and screen variables
window.gray        = 200;
window.black       = 0;
window.white       = 255;
window.fontsize    = 32;
window.bcolor      = window.gray;

%open main screen, get basic information about the main screen
screens=Screen('Screens'); % how many screens attached to this computer?
window.screenNumber=0; % use highest value (usually the external monitor)
window.onScreen=Screen('OpenWindow',window.screenNumber, 0, [], 32, 2); % open main screen
%window.onScreen=Screen('OpenWindow',window.screenNumber, 0, [0 0 300 300], 32, 2); % open main screen

[window.screenX, window.screenY]=Screen('WindowSize', window.onScreen); % check resolution
window.screenDiag = sqrt(window.screenX^2 + window.screenY^2); % diagonal size
window.screenRect  =[0 0 window.screenX window.screenY]; % screen rect
window.centerX = window.screenRect(3)*.5; % center of screen in X direction
window.centerY = window.screenRect(4)*.5; % center of screen in Y direction

% set some screen preferences
[sourceFactorOld, destinationFactorOld]=Screen('BlendFunction', window.onScreen, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('Preference','SkipSyncTests', 1);
Screen('Preference','VisualDebugLevel', 0);

% get screen rate
[window.frameTime nrValidSamples stddev] =Screen('GetFlipInterval', window.onScreen, 60);
window.monitorRefreshRate=1/window.frameTime;

% paint mainscreen bcolor, show it
Screen('FillRect', window.onScreen, window.bcolor);
Screen('Flip', window.onScreen);
Screen('FillRect', window.onScreen, window.bcolor);
Screen('TextSize', window.onScreen, window.fontsize);

end






