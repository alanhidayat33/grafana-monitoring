#!/bin/bash

echo "Configuring Node Exporter Textfile"

# Create systemd service file
sudo bash -c 'cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --collector.textfile.directory=/usr/local/bin/node_exporter_textfile/textfile

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

# Create directory for Node Exporter collector
sudo mkdir -p /usr/local/bin/node_exporter_textfile/textfile

# Create Node Exporter collector file directory
sudo mkdir -p /usr/local/bin/node_exporter_textfile/script

#  Copy all scripts from /textfile_custom_metrics to /usr/local/bin/node_exporter_textfile/script
sudo cp -r ./textfile_custom_metrics/* /usr/local/bin/node_exporter_textfile/script

# Create trigger script to run the collector every 10 seconds
echo '# Jalankan setiap 10 detik
#!/bin/bash

# Jalankan semua file collector setiap 10 detik dalam 1 menit
for ((i=0; i<6; i++)); do
  for script in /usr/local/bin/node_exporter_textfile/script/*; do
    if [[ -x "$script" ]]; then
      "$script" &
    fi
  done
  sleep 10
done' | sudo tee /usr/local/bin/node_exporter_textfile/script/trigger.sh > /dev/null

# Berikan hak akses eksekusi pada file trigger
sudo chmod +x /usr/local/bin/node_exporter_textfile/script/trigger.sh

# Berikan hak akses pada direktori dan file
sudo chown -R node_exporter:node_exporter /usr/local/bin/node_exporter_textfile

# Add cron job to run the collector script every 10 seconds
(crontab -l 2>/dev/null; echo "* * * * * /usr/local/bin/node_exporter_textfile/script/trigger.sh") | crontab -

# Restart the Node Exporter service
sudo systemctl restart node_exporter