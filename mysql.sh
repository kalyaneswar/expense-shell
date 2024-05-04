#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
# R="\e[31m"
# G="\e[32m"
# N="\e[0m"
# Y="\e[33m"
R=$(tput setaf 1)
G=$(tput setaf 2)
N=$(tput sgr0)
Y=$(tput setaf 3)

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

# Install MySQL Server 8.0.x
dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MySql server"

# Start MySQL Service
systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MySql server"
systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Start MySql server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up root  MySql passwd"

# Below code is useful for idempotency nature
mysql -h db.kalyaneswar.online -uroot -p${mysql_root_password} -e 'SHOW DATABASES;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "Setting up root password"
else
    echo -e "MySQL root password is already setup..$Y SKIPPING $N"
fi


