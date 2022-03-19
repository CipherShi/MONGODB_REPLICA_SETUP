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
  Once the key has been imported, add the repository:
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
  Configure MongoDB to start during the operating system’s boot
  ```
  sudo systemctl start mongod
  ```
  Verify that MongoDB has started successfully.
  ```
  sudo systemctl status mongod
  ```
  #
  refer to https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
  #
  # Configure Mongodb Replica Set
  The MongoDB documentation recommends against using IP addresses when configuring a replica set, since IP addresses can change unexpectedly. Instead, MongoDB   recommends using logical DNS hostnames when configuring replica sets.

One way to do this is to configure subdomains for each replication member. Although configuring subdomains would be ideal for a production environment or another long-term solution, this tutorial will outline how to configure DNS resolution by editing each server’s respective hosts files.

#### Configuring DNS Resolution
hosts is a special file that allows you to assign human-readable hostnames to numerical IP addresses. This means that if the IP address of any of your servers ever changes, you’ll only have to update the hosts file on the three servers instead of reconfiguring the replica set.

On Linux and other Unix-like systems, hosts is stored in the /etc/ directory. On each of your three servers, edit the file with your preferred text editor.
```
sudo vi /etc/hosts
```
add this to the hosts file:
```
<add_node1_IP_address_here>   node1
<add_node2_IP_address_here>   node2
<add_node3_IP_address_here>   node3
```
#### Updating Each Server’s Firewall Configurations with UFW
Open port 27017/tcp and ssh on the firewall:
```
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 27017/tcp
```
Check the listen Address of MongoDB service:
```
ss -tunelp | grep -i mongo
```
```
tcp   LISTEN  0       128                <node_IP_Address>:27017          0.0.0.0:*      users:(("mongod",pid=15288,fd=11)) uid:111 ino:46927 sk:4 <->
```
#### Configure MongoDB Replica set
Now that we have everything needed ready, let’s proceed to configure MongoDB replica set.
Change MongoDB Listen Address from localhost IP on all nodes.
```
sudo vim /etc/mongod.conf
```
```
# node 1
# network interfaces
net:
  port: 27017
  bindIp: node1

# node 2
# network interfaces
net:
  port: 27017
  bindIp: node2

# node 3
# network interfaces
net:
  port: 27017
  bindIp: node3
```
Also make sure you have enabled replica set on all nodes before exiting your test editor.
```
replication:
  replSetName: "rs0"
```
Now restart mongod service
```
sudo systemctl restart mongod.service
```
Alternatively
```
sudo service mongod restart
```
#### Initiate MongoDB Replica Set
Our MongoDB Node1 (node1) will be the PRIMARY and the other two will act as SECONDARY
Login to the node1 server and start the mongo shell.
```
mongo
```
```
MongoDB shell version v5.0.0
connecting to: mongodb://<node1_IP_Address>:27017/test
MongoDB server version: 5.0.0
Welcome to the MongoDB shell.
For interactive help, type "help".
...
>
```
Initialize replica set on node1 by running below command:
```
rs.initiate()
```
```
{
        "info2" : "no configuration specified. Using a default configuration for the set",                                                           
        "me" : "<node1_IP_Address>:27017",
        "ok" : 1,
        "operationTime" : Timestamp(1534797235, 1),
        "$clusterTime" : {
                "clusterTime" : Timestamp(1534797235, 1),
                "signature" : {
                        "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),                                                                          
                        "keyId" : NumberLong(0)
                }
        }
}
```
Make sure you get 1 for ok state
#### Add secondary nodes
```
rs.add("node2")
```
```
{
        "ok" : 1,
        "operationTime" : Timestamp(1534797580, 1),
        "$clusterTime" : {
                "clusterTime" : Timestamp(1534797580, 1),
                "signature" : {
                        "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                        "keyId" : NumberLong(0)
                }
        }
}
```
Check replica set status using:
```
rs.status()
```
