import os
import glob
import random
import numpy.random

numItems=range(0,20);

def make_trials(out):
	path="ImageFiles"
	textpath="TextImageFiles"
	cats=[f for f in os.listdir(path) if os.path.isdir(os.path.join(path, f))]
	i = 0
	for cat in cats: ## for both animals and objects
	    for item in range(0,20): # for all items
	    	for ImageScreenSide in range(0,2): # for left and right side of the screen
					# alterante image and word screen sides
					if ImageScreenSide==0:
						wordScreenSide=1;
					elif ImageScreenSide==1:
						wordScreenSide=0;
						
					imagePath=os.path.join(path, cat);
					currTargFiles=listdir_nohidden(imagePath);
					currFile=currTargFiles[item];
					
					## For congruent trials
					if cat=='Animals':
						wordCat=cat;
						wordCatInd=1;
					elif cat=='Objects':
						wordCat=cat;
						wordCatInd=2;
					
					whichTest=1
					CongruentOrNot='Congruent'
					##
					wordPath=os.path.join(textpath, wordCat);
					currWordFiles=listdir_nohidden(wordPath);
					wordTargetInd=random.sample(numItems,1);
					thisWordFile=currWordFiles[wordTargetInd[0]];
					
					trial = {'cat': cat, 'i':i+1, 'trialType': whichTest, 'item': item,'ImageScreenSide': ImageScreenSide,'wordScreenSide': wordScreenSide,'wordCat': wordCat,'wordCatInd': wordCatInd}		
					trial['Filename'] = currFile;
					trial['TargetWord'] = thisWordFile;

					i=i+1
					print_trial(out, trial)
	
					## For incongruent trials
					whichTest=2
					CongruentOrNot='Incongruent'
					# Reverse pairings when incongruent
					if cat=='Animals':
						wordCat='Objects';
						wordCatInd=2;
					elif cat=='Objects':
						wordCat='Animals';
						wordCatInd=1;
					
					wordPath=os.path.join(textpath, wordCat);
					currWordFiles=listdir_nohidden(wordPath);
					wordTargetInd=random.sample(numItems,1);
					thisWordFile=currWordFiles[wordTargetInd[0]];
					
					# Build out trial
					trial = {'cat': cat, 'i':i+1, 'trialType': whichTest, 'item': item,'ImageScreenSide': ImageScreenSide,'wordScreenSide': wordScreenSide,'wordCat': wordCat,'wordCatInd': wordCatInd}		
					trial['Filename'] = currFile;
					trial['TargetWord'] = thisWordFile;

					i=i+1
					print_trial(out, trial)
                                     

                

def print_trial(out, trial):
    out.write("""
	<input type="hidden" name="t%(i)d_whichDisplay" id="t%(i)d_whichDisplay" value="%(i)d">
    <input type="hidden" name="t%(i)d_trialType"    id="t%(i)d_trialType" value="%(trialType)d">
    <input type="hidden" name="t%(i)d_cat"     id="t%(i)d_cat" value="%(cat)s">
    <input type="hidden" name="t%(i)d_itemNum"      id="t%(i)d_itemNum" value="%(item)s">
    <input type="hidden" name="t%(i)d_filename"     id="t%(i)d_filename" value="%(Filename)s">
    <input type="hidden" name="t%(i)d_TargetWord"   id="t%(i)d_TargetWord" value="%(TargetWord)s">
    <input type="hidden" name="t%(i)d_ImageScreenSide" id="t%(i)d_ImageScreenSide" value="%(ImageScreenSide)d">
    <input type="hidden" name="t%(i)d_wordScreenSide"  id="t%(i)d_wordScreenSide" value="%(wordScreenSide)d">
    <input type="hidden" name="t%(i)d_wordCat"         id="t%(i)d_wordCat" value="%(wordCat)s">
    <input type="hidden" name="t%(i)d_wordCatInd"      id="t%(i)d_wordCatInd" value="%(wordCatInd)d">

	<input type="hidden" name="t%(i)d_rt" id="t%(i)d_rt" id="t%(i)d_rt" value="">
    <input type="hidden" name="t%(i)d_response" id="t%(i)d_response" id="t%(i)d_response" value="">
    <input type="hidden" name="t%(i)d_responseNum" id="t%(i)d_responseNum" id="t%(i)d_responseNum" value="">
    <input type="hidden" name="t%(i)d_currentTrial" id="t%(i)d_currentTrial" id="t%(i)d_currentTrial" value="">

	
    <img class="displays%(ImageScreenSide)d" src="http://people.fas.harvard.edu/~brialong/turk/MetamerPrime/AnimReplicate/%(Filename)s" id="t%(i)d_filenameImg">
    <img class="displays%(wordScreenSide)d" src="http://people.fas.harvard.edu/~brialong/turk/MetamerPrime/AnimReplicate/%(TargetWord)s" id="t%(i)d_TargetWordImg">

    """ % trial)
    
def build_filename(cat, imageNumber):
    return "ImageFiles/%s/%d.jpg" % (cat, imageNumber)
    # Want either e1_s2 or e2_s1
    
def build_filename_target(cat, imageNumber):
    return "TextImageFiles/%s/%d.jpg" % (cat, imageNumber)


def output_header(out):
    f = open('MetamerPrime_Header.html', 'r')
    out.write(f.read().replace('#NUMTRIALS#', '80'))

def output_footer(out):
    f = open('MetamerPrime_Footer.html', 'r')
    out.write(f.read().replace('#NUMTRIALS#', '80'))

def listdir_nohidden(path):
	return glob.glob(os.path.join(path, '*'))

# Create file! Main loop.
out = open('MetamerPrime_ReplicateTry.html', 'w')
output_header(out)
make_trials(out)
output_footer(out)
out.close()



