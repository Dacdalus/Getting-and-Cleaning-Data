---
title: "Getting and Cleaning Data Course Project"
author: "Dacdalus"
date: "23/4/2020"
output: html_document
---


## Libraries used

In the first place, the main libraries used to manipulate data were initialized.

```
library(data.table)
library(dplyr)
library(tidyr)
```


## Getting data

Messy data was downloaded from "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" in the project folder indicated by the path. Then, the downloaded file was unzipped. 

```
path <- getwd()
url_data <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url_data, file.path(path, "data.zip"))
unzip("data.zip")
```


## Loading activities data

By using list.files, we can observe and assign a path for the unzipped folder.

```
list.files(path)
path.act <- paste(path, "/", "UCI HAR Dataset", sep = "")
list.files(path.act)
```
Then, this path was used to import the data of activity labels and features. In the case of features, the function grep() was used to determine and isolate the features that contain mean and standard deviation (features_mean_std). The variables that contain the measurements of mean and standard deviation were assigned to "measurements".

```
activities <- fread(file.path(path.act, "activity_labels.txt"), col.names = c("labels", "activity"))
features <- fread(file.path(path.act, "features.txt"), col.names = c("number", "feature"))
features_mean_std <- grep("(mean|std)\\(\\)", features[, feature])
measurements <- features[features_mean_std[TRUE], feature]
```


## Loading train data set

To get the path of training data, past function was used to add the folder "train" to the unzipped folder path.  
Then, data corresponding to subject number (subjectN) and the activity (train_activities) were loaded.  
In the case the variables measured (X_traon.txt), only the measurements that contains mean and std were loaded. To do so, in the function fread, in select, the position of these variables in the data set were indicated (features_mean_std). The columns were named as the features corresponding to the measurements of mean and std loaded previously.

```
path.train <- paste(path.act, "/", "train", sep = "")
list.files(path.train)
subject_train <- fread(file.path(path.train, "subject_train.txt"), col.names = "subjectN")
train <- fread(file.path(path.train, "X_train.txt"), select = features_mean_std, col.names = measurements)
train_activities <- fread(file.path(path.train, "Y_train.txt"), col.names = c("activity"))
train <- cbind(subject_train, train_activities, train)
```


## Loading test data set

The same aproach used to load train data set was used to load test data ser.

```
path.test <- paste(path.act, "/", "test", sep = "")
list.files(path.test)
subject_test <- fread(file.path(path.test, "subject_test.txt"), col.names = "subjectN")
test <- fread(file.path(path.test, "X_test.txt"), select = features_mean_std, col.names = measurements)
test_activity <- fread(file.path(path.test, "Y_test.txt"), col.names = "activity")
test <- cbind(subject_test, test_activity, test)
```
Variables names were carefully assigned to properly merge both data sets later.



## Merging both data sets

Using rbind function the data rows corresponding to test data set were added to the ones corresponding to train data set.

```
merge <- rbind(train, test)
```


## Uses descriptive activity names

Using factor function, the levels taken by the variable activity were assigned to the labels according to the information assigned to "activities".

```
merge[["activity"]] <- factor(merge[, activity], levels = activities[["labels"]], labels = activities[["activity"]])
```


## Grouping data to calculate mean

Using dplyr package function group_by, variables of the merged data sets were grouped by the object number (subjectN) and the activity. Then, by sumarize_each, the mean of all groped variables was obtained. Then, resulting data was transformed in a data table and assigned to "merge2".

```
merge2 <- as.data.table(
    merge %>%
    group_by(subjectN, activity) %>%
    summarize_each(funs(mean)) 
    )
```
