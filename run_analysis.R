##  run_analysis.R
##  prepared for Course Project, Getting and Cleaning Data, by John Raphael, May 2014
##  
##  Objective: Prepare and document a tidy data set, per assignment instructions

##  created and tested with RStudio 0.98.507 Mozilla/5.0 (Windows NT 6.0)
##                          and R 3.10 for Windows 32-bit.

##  The source data is downloaded, then unzipped in the working directory, 
##  using the folder structure in the zip file. As a result, all files in
##  folder "UCI HAR Dataset" can be referenced from a filelist than includes
##  the complete path to the file.

##  The complete dataset is available at 
##  http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

##  NOTE: for Peer Reviewer, I inverted steps 1 and 2 of assignment,
##  due to limitations of my computer memory and speed.
##  
##  First, I read and subsetted each of the two raw datasets(train and test)
##  for std deviation and mean values, adding subjects and activities to each.
##  Second, I combined the two data sets into one.

##  DF and other object naming conventions:
##  ms* refers to objects containing means and standard deviations data only.
##  *train* refers to objects containing or related to training data only.
##  *test*  refers to objects containing or related to test data only.
##  'msmeans' indicates the object contains means of means and std dev.

run_analysis <- function(){

## loading libraries to support data frame manipulations

        library("reshape2")

    ##    library("plyr")  ## didn't use plyr in final revision

##  Acquire the Data
##  =========================================================
##  get the data and unzip it, record date and time acquired
    
    if(!file.exists("dataset.zip")) {
        fileurl=
          "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        
        download.file(fileurl, destfile="dataset.zip")
        
        sourceinfo <- c(date(), Sys.timezone(), fileurl)
        write.table(sourceinfo, file="sourceinfo.txt", row.names = F, col.names = F)
        
    }
        
        unzip("dataset.zip")

## build the file path and list of file names with complete paths,
    
        filepath <- paste(getwd(),"/UCI HAR Dataset/", sep="")
      
        filelist <- list.files(filepath, "all.files"=FALSE, recursive = T,)
        
        filelist <- paste(filepath,filelist, sep="")
    
    
### beginning to assemble data, first by reading existing labels, indexes
    
        activitylabels <- read.table(file=filelist[1], as.is=TRUE) ## activity_labels.txt
    
        names(activitylabels) <- c("actindex", "activityname" )
        activitylabels$activityname <- tolower(activitylabels$activityname)
        activitylabels$activityname <- gsub("[^[:alnum:]]","",
                                            activitylabels$activityname)
    
        featurelabels <- read.table(file=filelist[2], as.is=TRUE) ## features.txt
    
        names(featurelabels) <- c("featindex", "featurename")
    

##      Subsetting to get only mean and std variables in lists
##      ======================================================
    
###     I will make a subsetted df that will contain both name and index 
###     to allow subsetting the measured results for mean and std.
###     
###     The means and std features need to be of the same units.
###     While all values have been 'normalized', some mean statistics are
###     dimensionless. I will restrict the set to means with physical dimensions
###     and their associated standard deviations.
    
###     examples:   dimensioned mean: any X, Y, or Z force, such as gravity.
###                 dimensionless mean: any FFT transform (all begin with f)
###                                     any magnitude (MAG); it is a scalar    

###     The features containing "Mean" with initial cap are also excluded because
###     these are variables calculated from a mean, but are not a mean per se.
    
###     example: "angle(X,gravityMean)' is an angle calculated from gravityMean.

###     as a result, grep is used with the default (match case), for 'mean',
###     to avoid capturing these non-mean features with 'Mean' in their name.    
    
        featuremeanlabels <- featurelabels[(grep("mean", featurelabels[,2])),]
    
        featurestdlabels <- featurelabels[(grep("std", featurelabels[,2])),]
    
    
        featuremeanlabels <- featuremeanlabels[(grep("Mag", 
                                                    featuremeanlabels[,2], 
                                                    invert=TRUE)),]
      
        featuremeanlabels <- featuremeanlabels[(grep("fBody", 
                                                     featuremeanlabels[,2],
                                                     invert=TRUE)),]
      
        featurestdlabels <- featurestdlabels[(grep("Mag", 
                                                    featurestdlabels[,2], 
                                                    invert=TRUE)),]
      
        featurestdlabels <- featurestdlabels[(grep("fBody", 
                                                featurestdlabels[,2], 
                                                invert=TRUE)),]
    
    ### combine mean and std features list, then sort features by feature index
        
      featuremeanstdlabels <- rbind(featuremeanlabels,featurestdlabels)
    
      featuremeanstdlabels <- featuremeanstdlabels[order(featuremeanstdlabels$featindex),]
    
    
### For reference and repeatability, store featuremeanstdlabels
    
    write.table(featuremeanstdlabels, file="featuremeanstdlabels.txt")
    
### clean featurelabels, remove non alpha characters, make all lower case
###      will be used for future column names
    
    cleanfeaturelabels <- tolower(featuremeanstdlabels$featurename)
    cleanfeaturelabels <- gsub("[^[:alnum:]]","",
                               cleanfeaturelabels)
    
    

### start reading the data
    
    subjecttest <- read.table(filelist[14])  ## subject_text.txt
        names(subjecttest) <- "subject"
      
    subjecttrain <- read.table(filelist[26])  ## subject_train.txt
        names(subjecttrain) <- "subject"
      
    activitytest <- read.table(filelist[16])  ## y_test.txt
        names(activitytest) <- "activity"
      
    activitytrain <- read.table(filelist[28]) ## y_train.txt
        names(activitytrain) <- "activity"
    
    testdata <- read.table(file=filelist[15])  ## x_test.txt
    
### for brevity in variable names, variable names beginning with 'ms'
### will be used to refer to data frames only containing the measured
### means and std deviations.
    
### subsetting test data to the columns numbers in
### featuremeanstdlabels$featindex, assigning column names
    
    mstestdata <- testdata[, featuremeanstdlabels$featindex]
      
    names(mstestdata) <- featuremeanstdlabels$featurename
    
### binding subjects, activities to mstestdata
    mstestdata <- cbind(mstestdata, subjecttest, activitytest)
    
### remove larger df, save mstestdata, before working training data.
    rm(testdata)
    write.table(mstestdata, file="mstestdata.txt")
    
### read training data, prepare a df in similar manner to test data
    
    traindata <- read.table(file=filelist[27])  ## x_train.txt
    
    mstraindata <- traindata[, featuremeanstdlabels$featindex]
    
    names(mstraindata) <- featuremeanstdlabels$featurename
    
### binding subjects, activities to mstraindata
    
    mstraindata <- cbind(mstraindata, subjecttrain, activitytrain)    
    
#### cleanup, save
        rm(traindata)
    
        write.table(mstraindata, file="mstraindata.txt")
    
#### merge the two dfs via rbind, preserving existing column names
    
        msdata <- rbind(mstraindata, mstestdata)

#### replace activity index numbers with text

        msdata$activity <- activitylabels[msdata$activity,"activityname"]

    
#### Steps 1 and 2 evidence: save the unmodified, merged dataset
#### ===========================================================    
    
        write.table(msdata, file="msdata.txt")
    
#### cleaning/formatting labels and var names
    
        activitylabels$activityname <- tolower(activitylabels$activityname)
        activitylabels$activityname <- gsub("[^[:alnum:]]","",
                                            activitylabels$activityname)
    
        names(msdata) <- c(cleanfeaturelabels, "subject", "activity")

#### Steps 3 and 4 evidence: save the first tidy dataset (before step 5)
#### ===================================================================    
    
            write.table(msdata,file="step4tidydata.txt")
      
#### Step 5: Prepare a tidy data set with the average of each . . .
#### ===================================================================    
    

#### melt and dcast to wide format
    
        idcols <- colnames(msdata[,1:30])
        df <- melt(msdata, id.vars=c("activity","subject"), measure.vars=idcols)
        wmeandf <- dcast(df, activity + subject ~ variable, mean)
    
        write.table(wmeandf, file="tidy_means_of_observations.txt")
    
        rm(df, mstestdata, mstraindata)

        wmeandf <<- wmeandf

        message("analysis completed, wmeandf exported to calling environment")
    
    
    
    
}




