import os
import glob
import random
import numpy.random

def make_trials(out):
	path="ImageFiles"
	cats=[f for f in os.listdir(path) if os.path.isdir(os.path.join(path, f))]
	i = 0
	testi = 1
	filleri = 1
	testCount=0
	for cat in cats: ## for both animals and objects
	    for item in range(1,25):
                whichTest=1
                relatedOrNot='Related'
                fillerornot=0
                trial = {'cat': cat, 'i':i+1, 'trialType': whichTest, 'fillerTrial': fillerornot, 'item': item}		
                trial['Filename'] = build_filename(cat,item) # original on left
                trial['TargetWord']=build_filename_target(cat,item,relatedOrNot)
                testi=testi+1
                i=i+1
                print_trial(out, trial)
    
    ##
                whichTest=2
                fillerornot=0
                relatedOrNot='Unrelated'
                trial = {'cat': cat, 'i':i+1, 'trialType': whichTest, 'fillerTrial': fillerornot, 'item': item}
                trial['Filename'] = build_filename(cat,item) # original on left
                trial['TargetWord']=build_filename_target(cat,item,relatedOrNot)
                testi=testi+1
                i=i+1
                print_trial(out, trial)
                
    ##
                whichTest=0
                fillerornot=1
                trial = {'cat': cat, 'i':i+1, 'trialType': whichTest, 'fillerTrial': fillerornot, 'item': item}		
                trial['Filename'] = build_filename(cat,item)
                randNonWord=numpy.random.randint(1,48)
                trial['TargetWord'] = build_filename_filler(randNonWord)
                filleri=filleri+1
                i=i+1
                print_trial(out, trial) 
    ##        
                whichTest=0
                fillerornot=1
                trial = {'cat': cat, 'i':i+1, 'trialType': whichTest, 'fillerTrial': fillerornot, 'item': item}
                randNonWord2=numpy.random.randint(1,48)		
                while randNonWord==randNonWord2:
                    randNonWord2=numpy.random.randint(1,48)
                trial['Filename'] = build_filename(cat,item)
                trial['TargetWord'] = build_filename_filler(randNonWord)
                filleri=filleri+1
                i=i+1
                print_trial(out, trial)                       

                

def print_trial(out, trial):
    out.write("""
	<input type="hidden" name="t%(i)d_whichDisplay" value="%(i)d">
	<input type="hidden" name="t%(i)d_fillerTrial" value="%(fillerTrial)d">
    <input type="hidden" name="t%(i)d_trialType" value="%(trialType)d">
    <input type="hidden" name="t%(i)d_category" value="%(cat)s">
    <input type="hidden" name="t%(i)d_itemNum" value="%(item)s">
    <input type="hidden" name="t%(i)d_filename" value="%(Filename)s">
    <input type="hidden" name="t%(i)d_TargetWord" value="%(TargetWord)s">
    
	<input type="hidden" name="t%(i)d_rt" id="t%(i)d_rt" value="">
    <input type="hidden" name="t%(i)d_response" id="t%(i)d_response" value="">
    <input type="hidden" name="t%(i)d_responseNum" id="t%(i)d_responseNum" value="">
    <input type="hidden" name="t%(i)d_currentTrial" id="t%(i)d_currentTrial" value="">



	
    <img class="displays" src="http://people.fas.harvard.edu/~brialong/turk/SemanticPrime/%(Filename)s" id="t%(i)d_filename">
    <img class="displays" src="http://people.fas.harvard.edu/~brialong/turk/SemanticPrime/%(TargetWord)s" id="t%(i)d_TargetWord">

    """ % trial)
    
def build_filename(cat, imageNumber):
    # Helper function: Create a filename given an exemplar/state
    return "ImageFiles/%s/%d.jpg" % (cat, imageNumber)
    # Want either e1_s2 or e2_s1
    
def build_filename_target(cat, imageNumber,relatedOrNot):
    # Helper function: Create a filename given an exemplar/state
    return "TextImageFiles/%s%s/%d.jpg" % (cat, relatedOrNot, imageNumber)
    # Want either e1_s2 or e2_s1
        
def build_filename_filler(i): 
    return "TextImageFiles/NonWords/%d.jpg" % (i)


def output_header(out):
    f = open('SemanticPrime_header_working_blockListTry_wordOnly.html', 'r')
    out.write(f.read().replace('#NUMTRIALS#', '192'))

def output_footer(out):
    f = open('SemanticPrime_footer.html', 'r')
    out.write(f.read().replace('#NUMTRIALS#', '192'))

# Create file! Main loop.
out = open('SemanticPrime_WordsOnly.html', 'w')
output_header(out)
make_trials(out)
output_footer(out)
out.close()



