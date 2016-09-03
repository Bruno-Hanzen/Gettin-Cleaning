## run_analysis.R: Script written for the assignment project of the
## Coursera "Getting and Cleaning Data" Course

#load the libraries

library(data.table)
library(dplyr)

## For each record it is provided:
# ======================================
#     
# - Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
# - Triaxial Angular velocity from the gyroscope. 
# - A 561-feature vector with time and frequency domain variables. 
# - Its activity label. 
# - An identifier of the subject who carried out the experiment.
# We are going to merge all those data sets for both test and train samples into one single dataset

## Merges the training and the test sets to create one data set.

## Get the data in R

# We start with some initialisations

# Root directory of the data
data_root<- "Z:/Professionnel/Cours/R Code/Assignment 4"
# this is obviously specific to my setup. Please modify according to yours.
# Get the data from the internet site, unzip the data and point 
# the working directory to the unzipped data

setwd(data_root)
## Read the data from the web and unzip them
#download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "data.zip")
#unzip("data.zip")
data_root<-paste(data_root, "/UCI HAR Dataset", sep="")
setwd(data_root)
# Get the features names
features<-read.table("features.txt")[,2]

#Get the activity labels
activities<-read.table("activity_labels.txt")[,2]


# This function reads the data for a sample (train or test) and gathers them
# in a single frame. It also adds a column indentifying the sample to the frame.
dataset <- function(sample, datapath){

    #set the working directory
    samplepath <- paste(datapath, "/", sample, sep="")
    setwd(samplepath)
    
    # all files have the same number of lines, so we can safely assume that each 
    # line contain the data specific to one observation and that we can merge the 
    # data using the line number.
    
    # Get the test labels
    # Read the file
    labels<-read.table(paste("y_", sample, ".txt", sep = ""))
    # Assign a significant name to the variable
    names(labels)[1]<-"activity"
    
    # Get the subjects
    # Read the file
    subjects<-read.table(paste("subject_", sample, ".txt", sep = ""))
    # Assign a significant name to the variable
    names(subjects)[1]<-"subjects"
    
    # Get the test set
    # Read the file (use data.table due to memory efficiency)
    # Use "features" to provide variables names
    data_set<-fread(paste("X_", sample,".txt", sep = ""), header = FALSE, col.names = as.vector(features))
    
    #Get the inertial signals
    
    inertialpath<-paste(samplepath, "/Inertial Signals", sep="")
    setwd(inertialpath)
    
    body_acc_x<-fread(paste("body_acc_x_", sample, ".txt", sep=""), col.names = paste(rep("body_acc_x", 128), as.character(1:128), sep="_"))
    body_acc_y<-fread(paste("body_acc_y_", sample, ".txt", sep=""), col.names = paste(rep("body_acc_y", 128), as.character(1:128), sep="_"))
    body_acc_z<-fread(paste("body_acc_z_", sample, ".txt", sep=""), col.names = paste(rep("body_acc_z", 128), as.character(1:128), sep="_"))
    body_gyro_x<-fread(paste("body_gyro_x_", sample, ".txt",sep=""), col.names = paste(rep("body_gyro_x", 128), as.character(1:128), sep="_"))
    body_gyro_y<-fread(paste("body_gyro_y_", sample, ".txt",sep=""), col.names = paste(rep("body_gyro_y", 128), as.character(1:128), sep="_"))
    body_gyro_z<-fread(paste("body_gyro_z_", sample, ".txt",sep=""), col.names = paste(rep("body_gyro_z", 128), as.character(1:128), sep="_"))
    total_acc_x<-fread(paste("total_acc_x_", sample, ".txt",sep=""), col.names = paste(rep("total_acc_x", 128), as.character(1:128), sep="_"))
    total_acc_y<-fread(paste("total_acc_y_", sample, ".txt",sep=""), col.names = paste(rep("total_acc_y", 128), as.character(1:128), sep="_"))
    total_acc_z<-fread(paste("total_acc_z_", sample, ".txt",sep=""), col.names = paste(rep("total_acc_z", 128), as.character(1:128), sep="_"))
    
    # merge the datasets:
    # subjects
    # labels
    # datasets
    # the 9 datasets with inertial signals
    # as they all have the same number of columns, we use cbind
    
    grouped <- cbind(subjects, labels, data_set, body_acc_x, body_acc_y, body_acc_z, body_gyro_x, body_gyro_y, body_gyro_z, total_acc_x, total_acc_y, total_acc_z)
    
    # adds a column with the name of the sample repeated for each sample
    grouped$sample <- sample
    # returns the data
    grouped
}


# prepare the test data

test_data <- dataset("test", data_root)

# prepare the train data

train_data <- dataset("train", data_root)

# merge test and train data

data <- rbind(test_data, train_data)

# Get the activity names instead of codes

data$activity<-activities[data$activity]

# set the working directory tot he output directory

setwd(data_root)

# Write the merged data to a .csv file (MergedData.csv)

write.csv(data, file = "MergedData.csv", row.names = FALSE)

#we prepare the file restricted to mean and std of each measurement

SummarizedData<- data[c(match("subjects", names(data)), match("activity", names(data)), match("sample", names(data)), grep ("mean\\()|std\\()" , names(data)))]

write.csv(SummarizedData, file = "SummarizedData.csv", row.names = FALSE)

# calculate the averages of the observations of SummarizedData, for each user 
# and each activity, and write the results to a file

AverageddData <-SummarizedData %>% select(-sample) %>% group_by(subjects, activity) %>% summarize_all(funs(mean(.)))

write.csv(AverageddData, file = "AveragedData.csv", row.names = FALSE)

# data are available as text files (.txt), fixed length, some of them 
# "Unix style" (lines terminated by "LF") and wome other ones "Windows style"
# (lines terminated by "CR" "LF")

## Extracts only the measurements on the mean and standard deviation for each measurement.
## Uses descriptive activity names to name the activities in the data set
## Appropriately labels the data set with descriptive variable names.
## From the data set in step 4, creates a second, independent tidy 
## data set with the average of each variable for each activity and each subject.