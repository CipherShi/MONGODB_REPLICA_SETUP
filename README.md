# AWS EC2 mongodb setup
The main goal for this README is to show you how to setup mongodb on AWS EC2 instance. You will need to have the instance up and running to continue. Please see AWS documentation for how to setup an a new EC2 intance. We are running an Ubuntu 20.04 LTS machine.

# 
Connect to the new intance you just created above. There are various ways in which you can connect to the instance. Syntax for SSH into the instance is below:
 
 bash
 ```
 ssh -i <your-key-pair-here>.pem <public-IPv4-DNS-here>
 ```
 First we are going to run 
  ```
 sudo apt update -y
  ```
Create a file using the following command

 ```
 vi /etc/yum.repos.d/mongodb-org-4.2.repo
  ```
  paste the following code into the vi editor and save.

 ```
[mongodb-org-4.2]
name=MongoDB Repository 
baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/4.2/x86_64/ 
gpgcheck=1 
enabled=1 
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc 
 ```
 
 Now run this to install mongodb on the machine
 ```
 sudo yum install -y mongodb-org
  ```
  
  
  
