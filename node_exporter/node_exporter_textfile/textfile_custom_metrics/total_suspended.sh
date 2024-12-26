#!/bin/bash

# Path for saving prom result
suspended_account="/usr/local/bin/node_exporter_textfile/textfile/total_suspended_account.prom"

# Caputre the output of the ls command into the variable 'total'
total=$(ls -ll /var/cpanel/suspended/ | head -n 1 | awk '{print $2}')

# Save the total number of suspended hosting account to a textfile
echo "suspended_hosting_account $total" > "$suspended_account"