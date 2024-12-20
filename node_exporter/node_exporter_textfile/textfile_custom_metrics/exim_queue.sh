#!/bin/bash

# Path for saving prom result
exim_queue="/usr/local/bin/node_exporter_textfile/textfile/exim_queue.prom"

# Get the total number of emails in the Exim queue
total=$(exim -bpc)

# Save the total number of emails in the Exim queue to a textfile
echo "exim_queue $total" > "$exim_queue"
