
#!/bin/bash

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

    # Mengonversi waktu uptime dan waktu sekarang ke detik sejak epoch (Unix timestamp)                                                                                                                        p)
    UPTIME_SECONDS=$(date -d "$UPTIME" +%s)
    CURRENT_TIME=$(date +%s)

    # Menghitung selisih waktu (uptime dalam detik)
    DIFFERENCE=$((CURRENT_TIME - UPTIME_SECONDS))

    # Menyimpan hasil uptime dalam format yang bisa dipahami oleh Prometheus
    echo "${service_name}_uptime_seconds $DIFFERENCE" >> "$uptime_file"
done
