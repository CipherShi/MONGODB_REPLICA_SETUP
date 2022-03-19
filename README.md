# AWS EC2 mongodb setup
The main goal for this README is to show you how to setup mongodb on AWS EC2 instance. You will need to have the instance up and running to continue. Please see AWS documentation for how to setup an a new EC2 intance. We are running an Ubuntu 20.04 LTS machine.

# 
Connect to the new intance you just created above. There are various ways in which you can connect to the instance. Syntax for SSH into the instance is below:
 
 bash
 ```
 ssh -i <your-key-pair-here>.pem <public-IPv4-DNS-here>
 ```
 First we are going to run the command below to update all your packages.
  ```
 sudo apt update -y
  ```
  alternatively you can run
  ```
  sudo apt-get update -y
  ```
  Import the public key used by the package management system.
 ```
 wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
  ```
  refer to https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/#import-the-public-key-used-by-the-package-management-system
  Create a list file for MongoDB
  ```
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
  ```
  Reload local package database
  ```
  sudo apt-get update
  ```
  Install mongodb package
  ```
  sudo apt-get install -y mongodb-org
  ```
  Start mongodb
  ```
  sudo systemctl start mongod
  ```
  Verify that MongoDB has started successfully.
  ```
  sudo systemctl status mongod
  ```
  
