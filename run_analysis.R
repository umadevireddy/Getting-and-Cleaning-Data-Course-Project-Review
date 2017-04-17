install.packages("reshape2")
library(reshape2)
#Assign the filename
dsname <- "getdata_dataset.zip"
#Download and un-zip the dataset 
if (!file.exists(dsname)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, dsname)
} 
if (!file.exists("UCI HAR Dataset")) { 
  unzip(dsname) 
}

# Load Lables & Features: Load labels and features from files
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extraxt Relevant Features: Extract only the features on mean and standard deviation
featuresRequired <- grep(".*mean.*|.*std.*", features[,2])
featuresRequired.names <- features[featuresRequired,2]
featuresRequired.names = gsub('-mean', 'Mean', featuresRequired.names)
featuresRequired.names = gsub('-std', 'Std', featuresRequired.names)
featuresRequired.names <- gsub('[-()]', '', featuresRequired.names)

# Load the datasets for Relevant features & Lables
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresRequired]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresRequired]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge Train and Test datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresRequired.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)

