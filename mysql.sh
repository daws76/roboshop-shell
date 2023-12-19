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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disable current mysql version"

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "Coping mysql repos"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enabling mysql server"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "Starting mysql server"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "Setting mysql server password"


