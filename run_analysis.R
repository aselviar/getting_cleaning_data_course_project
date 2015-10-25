# Clear up the workspace
rm(list=ls())

library(data.table)

# Download the file and put in in a folder data/Dataset_UCI.zip (the if statement checks if the folder "data" already exists and if not it creates a new folder "data")
if(!file.exists("./data")) {dir.create("./data")}
fileUrl<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile = "./data/Dataset_UCI.zip",method = "curl")

# Unzip the file in the "data" directory
unzip(zipfile = "./data/Dataset_UCI.zip",exdir = "./data")

# List the files of the folder that has been downloaded
path_UCI <- file.path("./data","UCI HAR Dataset")
files <- list.files(path_UCI,recursive = TRUE)

# Read the data files needed
features <- read.table("./data/UCI HAR Dataset/features.txt",header = FALSE)
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt",header = FALSE)

subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt",header = FALSE)
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")

subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt",header = FALSE)
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")

# Bind the data imported together by row
subject <- rbind(subject_train,subject_test)
activity <- rbind(y_train,y_test)
features_data <- rbind(x_train,x_test)

# set names to the variables (columns)
names(subject) <- c("subject")
names(activity) <- c("activity")
names(features_data) <- features$V2

# Combine the different columns of the data to form the tidy data
sub_act <- cbind(subject,activity)
data_combined <- cbind(features_data,sub_act)

# Select the names of features by measurements on the mean and standard deviation
sub_features <- features$V2[grep("mean\\(\\)|std\\(\\)", features$V2)]

# Subset the combined data and filter it according to the names of features selected above
selected <- c(as.character(sub_features),"subject","activity")
data_combined <- subset(data_combined,select = selected)

# Use descriptive variable names 
colNames <- colnames(data_combined)

for (i in 1:length(colNames)) 
{
        colNames[i] <- gsub("\\()","",colNames[i])
        colNames[i] <- gsub("-std$","StdDev",colNames[i])
        colNames[i] <- gsub("-mean","Mean",colNames[i])
        colNames[i] <- gsub("^(t)","time",colNames[i])
        colNames[i] <- gsub("^(f)","freq",colNames[i])
        colNames[i] <- gsub("([Gg]ravity)","Gravity",colNames[i])
        colNames[i] <- gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",colNames[i])
        colNames[i] <- gsub("[Gg]yro","Gyro",colNames[i])
        colNames[i] <- gsub("AccMag","AccMagnitude",colNames[i])
        colNames[i] <- gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",colNames[i])
        colNames[i] <- gsub("JerkMag","JerkMagnitude",colNames[i])
        colNames[i] <- gsub("GyroMag","GyroMagnitude",colNames[i])
}

colnames(data_combined) <- colNames

# Create a second tidy data set with the average of each variable for each activity and each subject
library(plyr)
data_combined_2 <- aggregate(. ~subject + activity, data_combined, mean)
data_combined_2 <- data_combined_2[order(data_combined_2$subject,data_combined_2$activity),]
write.table(data_combined_2,file = "tidydata.txt",row.names = FALSE)




