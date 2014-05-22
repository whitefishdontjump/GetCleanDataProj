GetCleanDataProj
================

Getting and Cleaning Data Course Project

README.MD Course Project - Getting and Cleaning Data
========================================================
Prepared by John Raphael, May 2014
(needs revision to formatted markdown, RStudio didn't do it)
The entire execution of the project assignment, including data downloading and creation of
datasets is contained in the file "run_analysis.R"

The contents of run_analysis.R, define a function, run_analysis() which requires
no arguments. 

The function exports a final data frame, 'wmeandf' which is
180 rows by 32 columns.  Each row contains an activity name, a user id (1 to 30), and
the mean of observed means and standard deviations for that activity for that user.

Due to memory limitations of my PC, I inverted steps 1 and 2 as in the assignment.
I completed subsetting of the test and train datasets, including initial labels, separately.
Then I merged the two sets.
Specifically:
    
    1A. The test data were read into a data.frame, 
        the activity and user lists were column bound to the data,
        and the means and std deviation features were subsetted.
        
    1B. The training data followed the same path as the test data in 1A.
    
    2.  The two train and test datasets, already subsetted, were joined
        with rbind.

If the reviewer wants to examine intermediate data, the scripts writes multiple
text files during its execution and these are included in the repo.
Here is the list of files in the order they are created in the script:

    * sourceinfo.txt             
        documents the date, time, and file url of downloaded data
    
    * featuremeanstdlabels.txt   
        contains the features list used for means and std devs
    
    * mstestdata.txt             
        contains only mean and std dev features of test data
        
    * mstraindata.txt            
        contains only mean and std dev features of train data

    * msdata.txt                 
        contains the merged dataset, evidence of step 2 completed

    * step4tidydata.txt          
        result of renaming msdata, evidence of step 4 completed

    * tidy_means_of_observations.txt 
        evidence for step 5 completed.

The run_analysis.R file includes comments to assist in readers in following
the operations and creation of the text files written.

The specific manipulations of the raw data are summarized in the CodeBook.MD file.

Thanks for taking a look at my work.  Please feel free to leave comments in the commit on github.

