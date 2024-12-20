#!/bin/bash

# run firewall script
./firewall/firewalld/whitelist.sh

# run the Node Exporter script
./node_exporter/main.sh

# run add Grafana repository script
./dependencies/grafana_repository.sh

# run promtail script
./promtail/main.sh