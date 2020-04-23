# R script with performed analysis

# libraries used
library(data.table)
library(dplyr)
library(tidyr)

 
# getting data
path <- getwd()
url_data <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url_data, file.path(path, "data.zip"))
unzip("data.zip")

# loading activities data
list.files(path)
path.act <- paste(path, "/", "UCI HAR Dataset", sep = "")
list.files(path.act)
activities <- fread(file.path(path.act, "activity_labels.txt"), col.names = c("labels", "activity"))
features <- fread(file.path(path.act, "features.txt"), col.names = c("number", "feature"))
features_mean_std <- grep("(mean|std)\\(\\)", features[, feature])
measurements <- features[features_mean_std[TRUE], feature]


# loading train data set
path.train <- paste(path.act, "/", "train", sep = "")
list.files(path.train)
subject_train <- fread(file.path(path.train, "subject_train.txt"), col.names = "subjectN")
train <- fread(file.path(path.train, "X_train.txt"), select = features_mean_std, col.names = measurements)
train_activities <- fread(file.path(path.train, "Y_train.txt"), col.names = c("activity"))
train <- cbind(subject_train, train_activities, train)

# Loading test data set
path.test <- paste(path.act, "/", "test", sep = "")
list.files(path.test)
subject_test <- fread(file.path(path.test, "subject_test.txt"), col.names = "subjectN")
test <- fread(file.path(path.test, "X_test.txt"), select = features_mean_std, col.names = measurements)
test_activity <- fread(file.path(path.test, "Y_test.txt"), col.names = "activity")
test <- cbind(subject_test, test_activity, test)

# Merging both data sets
merge <- rbind(train, test)

# Uses descriptive activity names
merge[["activity"]] <- factor(merge[, activity], levels = activities[["labels"]], labels = activities[["activity"]])

# Grouping data to calculate mean
merge2 <- as.data.table(
    merge %>%
    group_by(subjectN, activity) %>%
    summarize_each(funs(mean)) 
    )

write.table(x = merge2, file = "tidyData.txt", quote = FALSE, row.name=FALSE)





