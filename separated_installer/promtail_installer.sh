#!/bin/bash

hostname=$(hostname)

# Define log paths and labels
declare -A log_paths=(
  ["cronjob"]="/var/log/cron"
  ["authentication_activity"]="/var/log/secure"
  ["syslog"]="/var/log/messages"
)

declare -A whm_log_paths=(
  ["session_log"]="/usr/local/cpanel/logs/session_log"
  ["api_tokens_log"]="/usr/local/cpanel/logs/api_tokens_log"
  ["login_log"]="/usr/local/cpanel/logs/login_log"
  ["accounting_log"]="/var/cpanel/accounting.log"
)

echo "Installing Promtail..."

# Add Grafana repository
wget -q -O gpg.key https://rpm.grafana.com/gpg.key

# Import the GPG key
rpm --import gpg.key

# Add the Grafana repository
echo '[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt' > /etc/yum.repos.d/grafana.repo

# Install Promtail
dnf install -y promtail

# Enable and start Promtail service
systemctl enable --now promtail

# Create Promtail configuration directory if it doesn't exist
mkdir -p /etc/promtail

# Configure Promtail
cat <<EOF > /etc/promtail/config.yml
# Minimal config scrapes specific log files.
# https://github.com/grafana/loki/issues/11398

server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
- url: http://grafa.idcloudhost-tutorial.my.id:3100/loki/api/v1/push

scrape_configs:
EOF

# Add general logs
for job in "${!log_paths[@]}"; do
  cat <<EOF >> /etc/promtail/config.yml
- job_name: ${job}
  static_configs:
  - targets:
      - localhost
    labels:
      job: ${job}
      host: ${hostname}:9100
      __path__: ${log_paths[$job]}
EOF
done

# Add WHM logs
cat <<EOF >> /etc/promtail/config.yml
- job_name: whm_log
  static_configs:
EOF

for job in "${!whm_log_paths[@]}"; do
  cat <<EOF >> /etc/promtail/config.yml
  - targets:
      - localhost
    labels:
      job: ${job}
      host: ${hostname}:9100
      __path__: ${whm_log_paths[$job]}
EOF
done

# Set ACL permissions for Promtail to read logs
for path in "${log_paths[@]}" "${whm_log_paths[@]}"; do
  setfacl -m u:promtail:r ${path}
done

# Restart Promtail service
systemctl restart promtail

echo "Promtail installation and configuration completed."