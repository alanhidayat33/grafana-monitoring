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

# Create Node Exporter collector file
echo '#!/bin/bash

# Daftar nama layanan yang akan diperiksa
services=("lsws.service" "mysqld.service" "pdns.service" "exim.service")

# Lokasi file output untuk Textfile Collector
status_file="/usr/local/bin/node_exporter_textfile/textfile/service_status.prom"
uptime_file="/usr/local/bin/node_exporter_textfile/textfile/service_uptime.prom"

# Kosongkan isi file status dan uptime terlebih dahulu
> "$status_file"
> "$uptime_file"

# Loop untuk memeriksa status dan uptime setiap layanan
for service in "${services[@]}"; do
    # Nama layanan tanpa ".service" untuk output yang lebih bersih
    service_name=$(echo "$service" | sed 's/\.service//')

    # Cek status layanan
    if systemctl is-active --quiet "$service"; then
        echo "${service_name}_status 1" >> "$status_file"
    else
        echo "${service_name}_status 0" >> "$status_file"
    fi

    # Mendapatkan waktu uptime dari service
    UPTIME=$(systemctl show -p ActiveEnterTimestamp "$service" | sed 's/ActiveEnterTimestamp=//')

    # Mengonversi waktu uptime dan waktu sekarang ke detik sejak epoch (Unix timestamp)
    UPTIME_SECONDS=$(date -d "$UPTIME" +%s)
    CURRENT_TIME=$(date +%s)

    # Menghitung selisih waktu (uptime dalam detik)
    DIFFERENCE=$((CURRENT_TIME - UPTIME_SECONDS))

    # Menyimpan hasil uptime dalam format yang bisa dipahami oleh Prometheus
    echo "${service_name}_uptime_seconds $DIFFERENCE" >> "$uptime_file"
done' | sudo tee /usr/local/bin/node_exporter_textfile/script/collector.sh > /dev/null

# Berikan hak akses eksekusi pada file collector
sudo chmod +x /usr/local/bin/node_exporter_textfile/script/collector.sh

# Create trigger script to run the collector every 10 seconds
echo '# Jalankan setiap 10 detik
#!/bin/bash

# Jalankan file collector setiap 10 detik dalam 1 menit
for ((i=0; i<6; i++)); do
  /usr/local/bin/node_exporter_textfile/script/collector.sh &
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