#!/bin/sh

echo "Uninstalling wal2json plugin for postgres."

dpkg --list | grep wal2json

if [ $? -eq 0 ]; then
	echo "Y" | sudo apt remove postgresql-10-wal2json
        echo "wal2json is installed."
	echo "Stoping postgres to reflect changes."
	sudo systemctl stop postgresql
	echo "Starting postgres."
	sudo systemctl start postgresql
	echo "Show status."
	sudo systemctl status postgresql
else
	echo "wal2json is not installed."
fi
