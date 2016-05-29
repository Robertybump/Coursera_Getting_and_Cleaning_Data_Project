## Installing and loading "reshape2" package
install.packages("reshape")
library(reshape2)

projectfile <- "getdata_dataset.zip"

## Download and unzip the dataset if it is not already downloaded:
if (!file.exists(projectfile)){
  projectfileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(projectfileURL, projectfile, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(projectfile) 
}

# Load activity labels + features from the dataset
LabelsAct <- read.table("UCI HAR Dataset/activity_labels.txt")
LabelsAct[,2] <- as.character(LabelsAct[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Calculate and extract the mean and standard deviation of data
wantedFeature <- grep(".*mean.*|.*std.*", features[,2])
wantedFeature.names <- features[wantedFeature,2]
wantedFeature.names = gsub('-mean', 'Mean', wantedFeature.names)
wantedFeature.names = gsub('-std', 'Std', wantedFeature.names)
wantedFeature.names <- gsub('[-()]', '', wantedFeature.names)


# Load the datasets
training <- read.table("UCI HAR Dataset/train/X_train.txt")[wantedFeature]
trainingActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainingSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
training <- cbind(trainingSubjects, trainingActivities, training)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[wantedFeature]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge the datasets together and add the required labels
allData <- rbind(training, test)
colnames(allData) <- c("subject", "activity", wantedFeature.names)

# turn the activities and subjects into factors
allData$activity <- factor(allData$activity, levels = LabelsAct[,1], labels = LabelsAct[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
