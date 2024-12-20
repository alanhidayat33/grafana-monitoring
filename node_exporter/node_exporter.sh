#!/bin/bash

NODE_EXPORTER_VERSION="1.8.2"

echo "Installing Node Exporter..."

# Download and extract Node Exporter
cd /usr/src || exit
wget https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz

tar -xf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
mv node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter /usr/local/bin/

# Create Node Exporter user
sudo adduser -M -r -s /sbin/nologin node_exporter

# Create systemd service file
sudo bash -c 'cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd, enable start the service
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

# Restart the Node Exporter service
sudo systemctl restart node_exporter