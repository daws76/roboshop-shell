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

dnf install nginx -y &>> $LOGFILE 

VALIDATE $? "Installing nginx"

systemctl enable nginx &>> $LOGFILE 

VALIDATE $? "Enabling nginx"

systemctl start nginx &>> $LOGFILE 

VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE 

VALIDATE $? "removing default files"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE 

VALIDATE $? "Downloading web application"

cd /usr/share/nginx/html &>> $LOGFILE 

VALIDATE $? "Moving to nginx directory"

unzip -o /tmp/web.zip &>> $LOGFILE 

VALIDATE $? "unziping web application"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE 

VALIDATE $? "Copied roboshop revers proxy config"

systemctl restart nginx &>> $LOGFILE 

VALIDATE $? "restarting nginx"

