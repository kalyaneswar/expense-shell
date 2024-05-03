#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
# R=$(tput setaf 1)
# G=$(tput setaf 2)
# N=$(tput sgr0)
# Y=$(tput setaf 3)

echo "Please enter DB password:"
read -s mysql_root_password

VALIDATE(){
    # echo "Exist status: $1"
    # echo "What are you doing : $2"
    if [ $1 -ne 0 ]
    then
        echo "$2..$R FAILURE $N"
        exit 1
    else
        echo "$2..$G SUCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE  $? "Disabling default NodeJS"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE  $? "enabling default NodeJS"

dnf install nodejs -y &>>$LOGFILE
VALIDATE  $? "Installing NodeJS"

id expense
if [ $? -ne 0 ]
then
    useradd expense 
    useradd expense &>>$LOGFILE
else
    echo -e "expense user already exist..$Y SKIPPING $N"
fi
VALIDATE  $? "Create user expense"
mkdir /app
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
cd /app
unzip /tmp/backend.zip
cd /app
npm install
