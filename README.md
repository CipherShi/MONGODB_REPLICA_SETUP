# AWS EC2 mongodb setup
The main goal for this README is to show you how to setup Mongodb with replica Set on an Ubuntu 20.04 AWS EC2 instance. You will need to have the instance up and running to continue. Please see AWS documentation for how to setup an a new EC2 intance. We are running an Ubuntu 20.04 LTS machine.

# 
#### 1. Connect to your newly created instance.
Connect to the new intance you just created above. There are various ways in which you can connect to the instance. Syntax for SSH into the instance is below:
 
 bash
 ```
 ssh -i <your-key-pair-here>.pem <public-IPv4-DNS-here>
 ```
 #### 2. Update all system packages.
 First we are going to run the command below to update all your packages.
  ```
 sudo apt update -y
  ```
  alternatively you can run
  ```
  sudo apt-get update -y
  ```
  #### 3. Import public key.
  Import the public key used by the package management system.
 ```
 wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
  ``` 
  #### 4. Add Mongodb repo
  Once the key has been imported, add the repository:
  ```
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
  ```
  Reload local package database
  ```
  sudo apt-get update
  ```
  #### 5. Install mongodb package
  Install the latest stable version of mongodb. Optional. Although you can specify any available version of MongoDB, apt-get will upgrade the packages when a newer version becomes available.
  ```
  sudo apt-get install -y mongodb-org
  ```
  #### 6. Configure systemctl.
  Configure MongoDB to start during the operating system’s boot
  ```
  sudo systemctl start mongod
  ```
  Verify that MongoDB has started successfully.
  ```
  sudo systemctl status mongod
  ```
  #
  For more about how to setup mongodb on ubuntu 20.04 please refer to https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
  #
  # Configure Nginx
  We will use nginx as our reverse proxy
  #### 1. Install Nginx
  ```
  sudo apt-get install -y nginx
  ```
  #### 2. Edit Nginx config file to route all incoming connections to mongodb
  You can find where nginx is installed using the below command
  ```
  whereis nginx
  ```
  output will look like:
  ```
  nginx: /usr/sbin/nginx /usr/lib/nginx /etc/nginx /usr/share/nginx /usr/share/man/man8/nginx.8.gz
  ```
  Next we will cd into /etc/nginx and open nginx.conf file in a text editor
  ```
  cd /etc/nginx
  sudo vi nginx.conf
  ```
  Alternatively you can run
  ```
  sudo vi /etc/nginx/nginx.conf
  ```
  Next we will add the following above the http config
  ```
  stream {
      server {
          listen <open-port>;
          proxy_pass stream_mongo_backend;
      }
  
      upstream stream_mongo_backend {
           server 0.0.0.0:<port>;
      }
  }
  ```
  Note the port nginx is listening to (ie. open-port) should be different with the port mongodb is running on (ie. port).
  #
  # Configure Mongodb Replica Set
  The MongoDB documentation recommends against using IP addresses when configuring a replica set, since IP addresses can change unexpectedly. Instead, MongoDB   recommends using logical DNS hostnames when configuring replica sets.

#### 1. Updating Each Server’s Firewall Configurations with UFW
Add your connection port and ssh port on the firewall.
Swap (open-port) with the port you just added to the nginx config file above.
```
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow <open-port>/tcp
```
Check the listen Address of MongoDB service:
```
sudo ss -ltnp | grep -i mongo
```
```
tcp   LISTEN  0       128                127.0.0.1:<port>          0.0.0.0:*      users:(("mongod",pid=15288,fd=11)) uid:111 ino:46927 sk:4 <->
```
As you can see above mongodb is currently bound to locahost ie. 127.0.0.1.
#### 2. Configure MongoDB Replica set
Now that we have everything needed ready, let’s proceed to configure MongoDB replica set.
Change MongoDB Listen Address from localhost IP on all nodes.
```
sudo vi /etc/mongod.conf
```
```
# node 1
# network interfaces
net:
  port: <port>
  bindIp: 0.0.0.0

# node 2
# network interfaces
net:
  port: <port>
  bindIp: 0.0.0.0

# node 3
# network interfaces
net:
  port: <port>
  bindIp: 0.0.0.0
```
Also make sure you have enabled replica set on all nodes before exiting your test editor.
```
replication:
  replSetName: rs0
```
Now restart mongod service
```
sudo systemctl restart mongod.service
```
Alternatively
```
sudo service mongod restart
```
If you now run
```
sudo ss -ltnp | grep -i mongo
```
you can see mongod is no longer bound to localhost ie 127.0.0.1.
#### 3. Initiate MongoDB Replica Set
Our MongoDB Node1 (node1) will be the PRIMARY and the other two will act as SECONDARY
Login to the node1 server and start the mongo shell.
```
mongo <node1_IP_Address>:<port>
```
```
MongoDB shell version v5.0.0
connecting to: mongodb://<node1_IP_Address>:<port>/test
MongoDB server version: 5.0.0
Welcome to the MongoDB shell.
For interactive help, type "help".
...
>
```
Initialize replica set on node1(Only run this on the PRIMARY node) by running below command:
```
rs.initiate()
```
```
{
        "info2" : "no configuration specified. Using a default configuration for the set",                                                           
        "me" : "<node1_IP_Address>:<port>",
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
#### 5. Add secondary nodes
```
rs.add("<node2_IP_Address>")
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
