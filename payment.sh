#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST="mongodb.daws76.site"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"


echo "Script started executing at $TIMESTAMP" &>> $LOGFILE 

VALIDATE(){
  if [ $1 -ne 0 ]
  then 
    echo -e "$2 .. $R Failed $N"
    exit 1
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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

id roboshop
if [ $? -ne 0 ]
then 
   useradd roboshop &>> $LOGFILE
   VALIDATE $? "roboshop user creation"
else 
   echo -e "roboshop user is already exist $Y Skipping $N"  
fi 

mkdir -p /app &>> $LOGFILE

VALIDATE $? "Creating  app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "Download the application code to created app directory"

cd /app &>> $LOGFILE

VALIDATE $? "Moving to app directory"

unzip -o /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "Unziping payment"

cd /app 

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "downloading the dependencies"

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "Copying payment serice"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon reload"

systemctl enable payment &>> $LOGFILE

VALIDATE $? "Enabling payment"

systemctl start payment &>> $LOGFILE

VALIDATE $? "Starting payment"

