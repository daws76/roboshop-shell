#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE 

VALIDATE(){
  if [ $1 -ne 0 ]
  then 
    echo -e "$2 .. $R Failed $N"
  else 
    echo -e "$2 .. $G Success $N"  
   fi    
} 

if [ $ID -ne 0 ]
then 
  echo -e "$R Error please run with root user $N"
  exit 1
else
  echo "you are root user"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied mongodb repo"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "Installing Mongodb"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enabled Mongodb"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "Started Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Remote access to Mongodb"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarting Mongodb"





