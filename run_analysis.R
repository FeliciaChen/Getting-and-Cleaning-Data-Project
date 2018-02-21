# List of packages for session
pkg <- c("plyr", "reshape2")

# Install CRAN packages (if not already installed)
inst_pkg <- pkg %in% installed.packages()
if (length(pkg[!inst_pkg]) > 0) 
  install.packages(pkg[!inst_pkg])

# Install CRAN packages (if not already installed)
lapply(pkg, require, character.only=TRUE)


# Download the dataset
filename <- "Dataset.zip"
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename)
}  

# Unzip the dataset
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename)  
}

# Import activity labels and features
ActivityLabels <- read.table("UCI HAR Dataset\\activity_labels.txt")
Features <- read.table("UCI HAR Dataset\\features.txt")

# Extracts only the data on the mean and standard deviation
Features_Mean_STD <- grep(".*mean.*|.*std.*", Features[,2])
Features_Mean_STD_Names <- as.character(Features[Features_Mean_STD,2])

# Import the training datasets
Train <- read.table("UCI HAR Dataset\\train\\X_train.txt") [Features_Mean_STD]
TrainActivityLabels <- read.table("UCI HAR Dataset\\train\\Y_train.txt")
TrainSubject <- read.table("UCI HAR Dataset\\train\\subject_train.txt")
TrainData <- cbind(TrainSubject, TrainActivityLabels, Train)

# Import the test datasets
Test <- read.table("UCI HAR Dataset\\test\\X_test.txt") [Features_Mean_STD]
TestActivityLabels <- read.table("UCI HAR Dataset\\test\\Y_test.txt")
TestSubject <- read.table("UCI HAR Dataset\\test\\subject_test.txt")
TestData <- cbind(TestSubject, TestActivityLabels, Test)

# Merge datasets and add labels
AllData <- rbind(TrainData, TestData)
colnames(AllData) <- c("Subject", "Activity", Features_Mean_STD_Names)
AllData$Activity <- factor(AllData$Activity, levels = ActivityLabels[,1], labels = ActivityLabels[,2])
AllDataMelt <- melt(AllData, id = c("Subject", "Activity")) #Convert an object into a molten data frame

# Calculate the mean of each variable
AllDataMean <- dcast(AllDataMelt, Subject + Activity ~ variable, mean)

# Export the result into txt file
write.table(AllDataMean, "tidy.txt", row.names = FALSE, quote = FALSE)
