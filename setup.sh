#! /bin/bash

HELP=$(base64 -d <<< "H4sIAAAAAAAAA6VUbW+bSBD+jsR/GOXTVap58SmK5G8kpj2qGiPwSa2aqlpgbVbCwO0ujdI4/e03u4Bjg5MPd04szfs888ysTQPgx/DRIgxCb4ITqzVYLuZor2mAPfhtLR7wew/3ffQ9ai/WQy9dztFeLPiSq3zwG2CQDzCyHgtezBkK2tB/7hUc+KoRaONhbD1DOMnpC9pHMmzd+HCUptaDklTu615EOPSyp9Jr1je8pmEaD5xJSStIH0EUdcFMQxS0LBdgp6yyUyIK05BMlnQBq3X4cb28hcTf/B1BchcH0cY0flIuWF0twLUcyzGNpk1LJgrUr61PbWnNnfncNLBms4BvMCuQttlMqfDdNFpBdlTZ60ZiEQHfn2CW6hBsn8Mzqo1Wm5pLeFaIYz/6HNx5Csaio+RYZcZ1LKdNyTKiGih3TkW2AL8iaUlh8Akq+6aA//u62tV5CqwSklQZBbKVlKugtumK9AAX4LwHF54c2NYcPpBSUKUrZcNb+mzBkm5JW0pwrC6Rt4q7Lp2UZ/Ah9Fb+ZAahZ8DWFdnT8xmC7SX8TGhN1nh9ssBdNkQIJZ0F62oPBcsKeGBlCSnFnjRXix9Pb41GTiRn1Q6eVuQRY7KyzSlU7T7FzQPBLZUUTwjluiofkYAaqloeA0VDM0ZKyArCSabiTkiKE/cVmoIw2AAeWxAmGy+888FLYPOXD1EcrLz4K4TrpQ/rUNveugim2WQVkwiC/RoT+mIf80U6ChvO9oQ/4kj5cBWTYykwNqVIvL6XMXv/92Bug3B5fHubNQQReMtl7CfJZNiTl3M25q2yTGDjwagJ9YK2DE8BK5M851SI8Qzu/Ea9bss9hdv9nYLm9J+WcZpPQUfreLqbk5f9X+CqxDHQPx3HecE4v3Hcm1cQmob/xVtFn4cHaNnd9kShfkZc9Q6v4u4eHPdKHZKrCD4yoeBfY7c3spMuz5nmXTvX07yLxU0j8X195SsvhMj76MMfhZSNWNj2jsmiTa2s3turB1Lt2Ipwib/aPXU/dOl38GEd4ypifC7RJliHCXi4m3745F/bvxyz6gcAAA==" | gunzip)

HEADER=$(base64 -d <<< "H4sIAAAAAAAAA31QTU+DQBS8b7L/YY56gK1NvHBDi7VGPlJqopGmAUuAhAJhFxsj+ttdNtBqP3zJJvNmdua9XUqA1VAKYgA9hV+sPjAnPUqlBGzQmYKtPAGC/nYguz3b9ui0R6kycO/tNHwDA25xwO4CT3qGQIa+gm4dvKgNFNkesn82PPL0gWz3GUwNbnfomG071HnPq3LDYRY7RufYf1RKKNnWmRBxgegDPC3TjBKexnlugEVZwaKQp5SITOSxAdt1pu7kBr61ePLg385n3oKS97jmWVkYuNJH+oiSqonyjKeyv9Yfmlwfj8ZjSmRmZeAVWiq/TdO6FktKGh4mcceXlZAhHMtPaJG6Isev8SXbSrVVWQt8dRv7loXFvQXbdOCZUwsXqRAVNxhLMpE2kf5Wbpi9DYsks8NayFdsyiIp19GKx6KpLnHnzuVb5hZcbzFzHR+mM4H1bNreo+X/AH5aJn36AgAA" | gunzip)

echo "${HEADER}"

help()
{
    echo "${HELP}"
    exit 2
}

SHORT=r:,s:,b:,p:,i:,h
LONG=replica::,setname::,bind:,port:,initialize::,help
OPTS=$(getopt -a -n mongodbSetup --options $SHORT --longoptions $LONG -- "$@")

VALID_ARGS=$#

if [ $VALID_ARGS -eq 0 ];
then
    help
fi

eval set -- "$OPTS"

while :
do
    case "$1" in
        -r | --replica)
           replicaSet="$2"
           shift 2
           ;;
        -s | --setname)
           replicaSetName="$2"
           shift 2
           ;;
        -b | --bind)
           bindIP="$2"
           shift 2
           ;;
        -p | --port)
           bindPort="$2"
           shift 2
           ;;
        -i | --initialize)
           initializeReplicaSet="$2"
           shift 2
           ;;
        -h | --help)
           help
           ;;
        --)
           shift;
           break
           ;;
        *)
           echo "Unexpected option: $1"
           help
           ;;
    esac
done
echo ""
echo "Updating your system..."
(sudo apt-get update && sudo apt-get ugrade -y)
echo "Sytem update complete"
sleep 1
echo "Importing public key from mongodb.org..."
IMPORT_KEY=$(wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -)
echo "${IMPORT_KEY}"
sleep 1
echo "Fetching mongodb repo..."
MONGO_REPO_FETCH=$(echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list)
echo "${MONGO_REPO_FETCH}"
sleep 1
echo "Reloading local package database..."
RELOAD=$(sudo apt-get update)
sleep 2
echo "Installing Mongodb package..."
INSTALL_MONGODB=$(sudo apt-get install -y mongodb-org)
echo "${INSTALL_MONGODB}"
sleep 4
echo "Mongodb package installed successfully"
sleep 2
echo "Setting up Mongodb to start after boot"
(sudo systemctl enable mongod)
(sudo systemctl start mongod)
sleep 4
echo "Setup completed successfully"
sleep 2
(clear)
echo "${HEADER}"
echo ""
echo "Configuring Mongodb instance..."
sleep 2

if [ -n "$bindIP" ] && [ -n "$bindPort" ];
then
    CONFIG=$(sudo find / -name mongod.conf)
    if [ -n "$CONFIG" ];
    then
        CONFIG_BAK=$(sudo find / -name mongod.conf.bak)
        sleep 2
        if [ -z "$CONFIG_BAK" ];
        then
            (sudo cp $CONFIG $CONFIG.bak)
            echo "Back-up copy of $CONFIG created at $CONFIG.bak"
            sleep 2
        fi
        (sed -i -e "s/^  bindIp:.*/  bindIp:  $bindIP/" -i -e "s/^  port:.*/  port:  $bindPort/" $CONFIG)
        echo "Bind IP set to: $bindIP"
        echo "Bind port set to: $bindPort"
        if [ "$replicaSet" = "1" ];
        then
            echo "Configuring replica set..."
            sleep 2
            if [ -z "$replicaSetName" ];
            then
                (sudo sed -i -e "s/^#replication:.*/replication:/" -i -e "/replication:/a\\  replSetName:  RS1" $CONFIG)
                sleep 1
                echo "replica set(RS1) enabled and configured successfully"
            elif [ -n "$replicaSetName" ];
            then
                (sudo sed -i -e "s/^#replication:.*/replication:/" -i -e "/replication:/a\\  replSetName:  $replicaSetName" $CONFIG)
                sleep 1
                echo "replica set($replicaSetName) enabled and configured successfully"
            fi
            (sudo systemctl restart mongod)
            sleep 4
            if [ "$initializeReplicaSet" = "1" ];
            then
                echo "Initializing replica set..."
                INITIALIZING=$(mongo --host $bindIP --port $bindPort --eval 'rs.initiate()')
                echo "$INITIALIZING"
                sleep 2
                echo "Initializing replica set complete"
            fi
            echo "Replica set configuration done"
        fi
    elif [ -z "$CONFIG" ];
    then
        echo "mongod.conf file location not found!"
        exit 2
    fi
elif [ -z "$bindIP" ] || [ -z "$bindPort" ];
then
    echo "${HELP}"
    echo "Missing argument(s) error."
    exit 2
fi