# Project: Server Monitoring Automation with Node Exporter and Promtail

This project automates the installation and configuration of Node Exporter and Promtail to enable server monitoring and log management. The system collects service metrics using Prometheus Node Exporter and forwards log files to Grafana Loki via Promtail.


## Features

 - **Node Exporter Setup:**
	 - Collects service metrics such as status and uptime.
	 - Exposes metrics for Prometheus scraping.
 - **Promtail Setup:**
	 - Scrapes system logs and WHM-specific logs.
	 - Sends logs to Grafana Loki for centralized log management.
 - **Automated Cron Jobs:**
	 - Collects service statuses and uptimes every 10 seconds.
	 - Logs management runs continuously.

## Installation Steps
### Prerequisites
-   A Linux-based system (tested on CentOS/RHEL).
-   Sudo privileges.
-   Internet connection.

### Node Exporter Installation

 1. **Run the Installation Script:**

	    cd /opt
		git clone https://github.com/alanhidayat33/grafana-monitoring.git
		cd grafana-monitoring
		./main.sh
		

 2. **Verify Installation:**
		
	    systemctl status node_exporter
	    systemctl status promtail

## How It Works
 1. **Metrics Collection:**
	 - The services `lsws`, `mysqld`, `pdns`, and `exim` are monitored for status and uptime.
	 - Metrics are exposed at `/usr/local/bin/node_exporter_textfile/textfile` for Prometheus scraping.
 
 2. **Log Management:**
	 - Logs from WHM and system services are scraped using Promtail.
	 - Logs are forwarded to the Grafana Loki server.

## Configuration Details
#### Promtail Config (`/etc/promtail/config.yml`)
 - Custom job definitions for system and WHM logs.
 - Logs forwarded to the Grafana Loki API endpoint.

#### Node Exporter Systemd Service
 - Service definition for Node Exporter running as a systemd service.

## License
This project is open-source and available under the MIT License.

## Author
Alan Tri Arbani Hidayat