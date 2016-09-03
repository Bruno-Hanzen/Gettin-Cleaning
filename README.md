# Gettin-Cleaning
Assignment 4 of the Coursera "Getting &amp; Cleaning Data" course
# Content of the repository
## Code
the R code is stored in run_analysis.R. It contains a function (dataset)
that gathers the data from the 

*.Test Labels (later renamed as activity)
*.Subjects
*.Test Set: measurements calculated from the raw data (561 features)
*.Inertial Data: 128 raw data for each record
..Body acceleration (along the 3 axis)
..Body angular speed (along the 3 axis)
..Total acceleration (along the 3 axis)

It also adds a column to identify the sample

It produces a dataframe with 1716 variables

The function is called for respectively the test and training samples.
The test and training dataframes are then merged and the script produces the 
requested outputs:
. A file containing the merged data: MergedData.csv
. A file containing only the means() and std() of the measurements: SummarizedData.csv
. A file containing the averages on the data of SummarizedData.txt, by activity and subject
