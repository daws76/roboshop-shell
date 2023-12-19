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

dnf install maven -y &>> $LOGFILE 

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE 

VALIDATE $? "Downloading shipping"

cd /app

VALIDATE $? "moving to app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE 

VALIDATE $? "Unzipping shipping"

cd /app

mvn clean package &>> $LOGFILE 

VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE 

VALIDATE $? "renaming jar files"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE 

VALIDATE $? "Coping shipping service"

systemctl daemon-reload &>> $LOGFILE 

VALIDATE $? "Deemon reload"

systemctl enable shipping &>> $LOGFILE 

VALIDATE $? "Enabling shipping"

systemctl start shipping &>> $LOGFILE 

VALIDATE $? "Starting shipping"

dnf install mysql -y &>> $LOGFILE 

VALIDATE $? "Installing mysql client"

mysql -h mysql.daws76.site -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE 

VALIDATE $? "Loading the shipping data"

systemctl restart shipping &>> $LOGFILE 

VALIDATE $? "restarting shipping"



