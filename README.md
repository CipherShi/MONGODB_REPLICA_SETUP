# EC2_mongodb_setup
The main goal for this README is to show you how to setup mongodb on AWS EC2 instance. You will need to have the instance up and running to continue. Please see AWS documentation for how to setup an a new EC2 intance. We are running an Ubuntu 20.04 machine.

# SSH
Connect to the new intance you just created above. There are various ways in which you can connect to the instance. Syntax for SSH into the instance is below:
 
 bash
 ```
 ssh -i <your-key-pair-here>.pem <public-IPv4-DNS-here>
 ```
 First we are going to run 
  ```
 sudo yum update -y
  ```
