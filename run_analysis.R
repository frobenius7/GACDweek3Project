#R script for course project - reading and cleaning data
library(reshape2)
library(data.table)

axelSubTrain<-read.table("./train/subject_train.txt")
axelLabTrain<-read.table("./train/y_train.txt")
axelTrain<-read.table("./train/X_train.txt")

axelSubTest<-read.table("./test/subject_test.txt")
axelLabTest<-read.table("./test/y_test.txt")
axelTest<-read.table("./test/X_test.txt")

axelSub<-rbind(axelSubTrain,axelSubTest)
axelLab<-rbind(axelLabTrain,axelLabTest)
axel<-rbind(axelTrain,axelTest)

setnames(axelSub,"V1","Subject")
setnames(axelLab,"V1","ActivityLab")

axelSub<-cbind(axelSub,axelLab)
axel<-cbind(axelSub,axel)

axelFeatures<-read.table("./features.txt")
#subset only features that contain "mean" or "std" for standart deviation
#axelFeatures[1,2]
axelFeaturesSel<-axelFeatures[grepl("mean\\(\\)|std\\(\\)",axelFeatures[,2]),]
setnames(axelFeaturesSel, names(axelFeaturesSel), c("featureCode", "featureName"))
#paste "V" in front of code to match auto-naming
axelFeaturesSel$featureCode<-paste0("V",axelFeaturesSel[,1])

#Ectract only the measurements on the mean and std for each measurement
axelSel<-axel[,axelFeaturesSel[,1]]
axelSel<-cbind(axel[,1:2],axelSel)

#Use descriptive activity names to name the activities in the data set
axelActivityNames<-read.table("./activity_labels.txt")
setnames(axelActivityNames,names(axelActivityNames),c("ActivityLab","activityName"))

axelSel<-merge(axelSel,axelActivityNames,by="ActivityLab",all.x=TRUE)

#Appropriately labels the data set with descriptive variable names. 
#axelFeaturesSel[[2]]-vector of names (integer)
setnames(axelSel,names(axelSel)[3:68],c(as.character(axelFeaturesSel[[2]])))

#Creates a second, independent tidy data set with the average of each variable 
#for each activity and each subject. 
meltSet<-melt(axelSel,id=c("ActivityLab","Subject","activityName"))
ResultTable<-dcast(meltSet,activityName+Subject~variable,mean)
write.table(ResultTable,"./TidyDataset.txt")
