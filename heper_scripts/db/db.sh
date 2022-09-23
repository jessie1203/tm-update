#!/bin/sh

echo "Uninstalling wal2json plugin for postgres."

sudo yum list installed | grep wal2json_12

if [ $? -eq 0 ]; then
	echo "Y" | sudo yum remove wal2json_12.x86_64
        echo "wal2json is installed."
	echo "Stoping postgres to reflect changes."
	sudo systemctl stop postgresql-12
	echo "Starting postgres."
	sudo systemctl start postgresql-12
	echo "Show status."
	sudo systemctl status postgresql-12
else
	echo "wal2json is not installed."
fi
